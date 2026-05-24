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

    /// 播放示范旋律（使用 PlaybackEngine 统一调度）
    func playDemoMelody() {
        let events = melody.enumerated().map { index, note in
            PlaybackEngine.TimedAudioEvent(
                beat: Double(index),
                midiNote: MusicTheory.midiNote(from: note.solfege, octave: note.octave) ?? 60,
                duration: note.duration
            )
        }

        Task {
            // 注册事件回调以更新 UI
            await PlaybackEngine.shared.onEvent { [weak self] event in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    // 找到对应的 melody 索引
                    if let idx = self.melody.firstIndex(where: {
                        MusicTheory.midiNote(from: $0.solfege, octave: $0.octave) == event.midiNote
                    }) {
                        self.currentNoteIndex = idx
                    }
                }
            }

            await PlaybackEngine.shared.prepare(timeline: events, bpm: 60)
            await PlaybackEngine.shared.play()

            // 等待播放完成后进入等待演唱状态
            let totalBeats = events.map { $0.beat + $0.duration }.max() ?? 0
            let waitSeconds = totalBeats / 60.0 * 60.0 / 60.0 + 0.5
            try? await Task.sleep(nanoseconds: UInt64(waitSeconds * 1_000_000_000))

            await MainActor.run {
                self.state = .waitingToSing
                self.currentNoteIndex = 0
            }
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

        // 通知体验引擎
        ExperienceEngine.shared.onUserAction(.practiceStarted)

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

                // 节奏反馈
                if rhythmNoteScore >= 85 {
                    ExperienceEngine.shared.onUserAction(.rhythmOnBeat(accuracy: Double(rhythmNoteScore) / 100.0))
                } else {
                    ExperienceEngine.shared.onUserAction(.rhythmOffBeat)
                }

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
                let score = self.pitchDetector.currentScore
                self.noteScores.append(score)

                // 音高反馈
                if score >= 85 {
                    ExperienceEngine.shared.onUserAction(.noteCorrect(deviation: abs(self.centsDeviation)))
                } else if score >= 50 {
                    ExperienceEngine.shared.onUserAction(.noteClose(deviation: abs(self.centsDeviation)))
                } else if self.currentAmplitude > 0.1 {
                    ExperienceEngine.shared.onUserAction(.noteMissed)
                }
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

        // 通知体验引擎练习完成
        let accuracy = Double(totalScore) / 100.0
        ExperienceEngine.shared.onUserAction(.practiceCompleted(accuracy: accuracy))

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
                self?.currentAmplitude = Float(result.amplitude)
            }
        }
    }

    /// 节奏评分（委托给 RhythmEngine）
    private func calculateRhythmScore(actualDuration: Double, expectedDuration: Double) -> Int {
        guard expectedDuration > 0 else { return 100 }
        // 将时长偏差转换为"拍"偏差（以 60 BPM = 1 拍/秒 为基准）
        let beatDeviation = abs(actualDuration - expectedDuration) / expectedDuration
        return RhythmEngine.evaluateTiming(actual: beatDeviation, expected: 0, tolerance: 0.1)
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
