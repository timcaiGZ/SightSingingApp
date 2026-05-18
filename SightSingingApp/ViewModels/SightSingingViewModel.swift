import Foundation
import SwiftUI
import Combine

/// 视唱练习状态
enum SightSingingState {
    case intro           // 介绍页
    case playingDemo    // 播放示范
    case waitingToSing   // 等待演唱
    case singing         // 演唱中
    case result          // 结果页
}

/// 视唱练习 ViewModel
@Observable
final class SightSingingViewModel {
    // MARK: - 状态

    var state: SightSingingState = .intro
    var currentNoteIndex: Int = 0
    var pitchScore: Int = 0
    var rhythmScore: Int = 0
    var totalScore: Int = 0
    var noteScores: [Int] = []
    var rhythmScores: [Int] = []
    var permissionDenied: Bool = false

    // 音高检测数据
    var detectedFrequency: Double = 0
    var centsDeviation: Double = 0
    var currentAmplitude: Float = 0

    // 旋律数据
    var melody: [MelodyNote] = []
    var selectedNotation: NotationType = .tabWithSolfege

    // MARK: - 私有属性

    private let pitchDetector = PitchDetector.shared
    private var singingTimer: Timer?
    private var singingStartTime: Date = Date()
    private var currentNoteStartTime: Date = Date()
    private var practiceStartTime: Date = Date()
    private var cancellables = Set<AnyCancellable>()

    // 回调
    var onPracticeComplete: ((Int, Int, Int) -> Void)?
    var onMelodyGenerated: (([MelodyNote]) -> Void)?

    // MARK: - 初始化

    init() {
        setupPitchDetectorCallback()
    }

    deinit {
        cleanup()
    }

    // MARK: - 公开方法

    /// 生成旋律
    func generateMelody(for exercise: ExerciseType) {
        switch exercise {
        case .intervalSinging:
            if let intervalQ = QuestionBank.intervalQuestions.randomElement() {
                let semitones = intervalQ.semitones
                let rootMIDI = 60
                let targetMIDI = rootMIDI + semitones
                let (targetSolfege, targetOctave) = midiToSolfege(targetMIDI)
                let (rootSolfege, rootOctave) = midiToSolfege(rootMIDI)
                melody = [
                    MelodyNote(solfege: rootSolfege, octave: rootOctave, duration: 1.0),
                    MelodyNote(solfege: targetSolfege, octave: targetOctave, duration: 2.0),
                ]
            } else {
                melody = defaultMelody()
            }
        default:
            melody = defaultMelody()
        }
        onMelodyGenerated?(melody)
    }

    /// 检查权限并开始
    func checkPermissionAndStart() {
        Task {
            let granted = await pitchDetector.requestMicrophonePermission()
            if granted {
                await MainActor.run {
                    state = .playingDemo
                }
            } else {
                await MainActor.run {
                    permissionDenied = true
                }
            }
        }
    }

    /// 播放示范旋律
    func playDemoMelody() {
        var delay: Double = 0
        for (index, note) in melody.enumerated() {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                self.currentNoteIndex = index
                await AudioEngineManager.shared.playSolfege(note.solfege, octave: note.octave)
            }
            delay += note.duration
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64((delay + 0.5) * 1_000_000_000))
            self.state = .waitingToSing
            self.currentNoteIndex = 0
        }
    }

    /// 开始演唱
    func startSinging() {
        pitchDetector.startDetection()
        state = .singing
        practiceStartTime = Date()
        singingStartTime = Date()
        currentNoteIndex = 0
        currentNoteStartTime = Date()
        noteScores = []
        rhythmScores = []

        singingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self, self.state == .singing else {
                timer.invalidate()
                return
            }

            let currentNote = self.melody[self.currentNoteIndex]
            let elapsedTime = Date().timeIntervalSince(self.currentNoteStartTime)

            if elapsedTime >= currentNote.duration {
                let rhythmNoteScore = self.calculateRhythmScore(
                    actualDuration: elapsedTime,
                    expectedDuration: currentNote.duration
                )
                self.rhythmScores.append(rhythmNoteScore)

                if self.currentNoteIndex < self.melody.count - 1 {
                    self.currentNoteIndex += 1
                    self.currentNoteStartTime = Date()
                } else {
                    timer.invalidate()
                    DispatchQueue.main.async {
                        self.stopSinging()
                    }
                    return
                }
            }

            let note = self.melody[self.currentNoteIndex]
            self.pitchDetector.setTarget(solfege: note.solfege, octave: note.octave)

            DispatchQueue.main.async {
                self.detectedFrequency = self.pitchDetector.detectedFrequency
                self.centsDeviation = self.pitchDetector.centsDeviation
                self.currentAmplitude = self.pitchDetector.currentAmplitude
                self.noteScores.append(self.pitchDetector.currentScore)
            }
        }
    }

    /// 停止演唱
    func stopSinging() {
        singingTimer?.invalidate()
        singingTimer = nil
        pitchDetector.stopDetection()

        let avgPitchScore = noteScores.isEmpty ? 0 : noteScores.reduce(0, +) / noteScores.count
        pitchScore = avgPitchScore

        if currentNoteIndex < melody.count {
            let currentNote = melody[currentNoteIndex]
            let elapsedTime = Date().timeIntervalSince(currentNoteStartTime)
            let finalRhythmScore = calculateRhythmScore(
                actualDuration: elapsedTime,
                expectedDuration: currentNote.duration
            )
            rhythmScores.append(finalRhythmScore)
        }

        rhythmScore = rhythmScores.isEmpty ? 100 : rhythmScores.reduce(0, +) / rhythmScores.count
        totalScore = Int(Double(pitchScore) * 0.7 + Double(rhythmScore) * 0.3)

        state = .result
        onPracticeComplete?(pitchScore, rhythmScore, totalScore)
    }

    /// 重置练习
    func resetPractice() {
        singingTimer?.invalidate()
        singingTimer = nil
        pitchDetector.reset()
        noteScores = []
        rhythmScores = []
        currentNoteIndex = 0
        pitchScore = 0
        rhythmScore = 0
        totalScore = 0
        state = .playingDemo
    }

    /// 获取目标频率
    var targetFrequency: Double {
        guard currentNoteIndex < melody.count else { return 0 }
        let note = melody[currentNoteIndex]
        return MusicTheory.frequencyFromMIDI(
            MusicTheory.midiNote(from: note.solfege, octave: note.octave) ?? 60
        )
    }

    /// 清理资源
    func cleanup() {
        singingTimer?.invalidate()
        singingTimer = nil
        pitchDetector.stopDetection()
        pitchDetector.reset()
    }

    // MARK: - 私有方法

    private func setupPitchDetectorCallback() {
        pitchDetector.onPitchDetected = { [weak self] result in
            DispatchQueue.main.async {
                self?.detectedFrequency = Double(result.frequency)
                self?.centsDeviation = Double(result.cents)
                self?.currentAmplitude = result.amplitude
            }
        }
    }

    private func calculateRhythmScore(actualDuration: Double, expectedDuration: Double) -> Int {
        guard expectedDuration > 0 else { return 100 }
        let deviation = abs(actualDuration - expectedDuration) / expectedDuration
        if deviation <= 0.1 { return 100 }
        else if deviation <= 0.2 { return 85 }
        else if deviation <= 0.3 { return 70 }
        else if deviation <= 0.5 { return 50 }
        else { return 30 }
    }

    private func midiToSolfege(_ midi: Int) -> (String, Int) {
        let octave = (midi / 12) - 1
        let noteInOctave = midi % 12
        let mapping: [Int: String] = [
            0: "1", 1: "#1", 2: "2", 3: "#2", 4: "3",
            5: "4", 6: "#4", 7: "5", 8: "#5", 9: "6", 10: "#6", 11: "7"
        ]
        return (mapping[noteInOctave] ?? "1", octave)
    }

    private func defaultMelody() -> [MelodyNote] {
        [
            MelodyNote(solfege: "1", octave: 4, duration: 1.0),
            MelodyNote(solfege: "2", octave: 4, duration: 1.0),
            MelodyNote(solfege: "3", octave: 4, duration: 1.0),
            MelodyNote(solfege: "5", octave: 4, duration: 2.0),
        ]
    }
}

#Preview {
    Text("SightSingingViewModel")
}
