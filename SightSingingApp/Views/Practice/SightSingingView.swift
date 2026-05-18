import SwiftUI
import SwiftData

/// 视唱练习视图（集成谱式展示和音准指示器）
struct SightSingingView: View {
    let exercise: ExerciseType
    let module: ExerciseModule
    let viewModel: PracticeViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - 状态
    @State private var state: SightSingingState = .intro
    @State private var currentNoteIndex: Int = 0
    @State private var pitchScore: Int = 0
    @State private var rhythmScore: Int = 0
    @State private var totalScore: Int = 0
    @State private var noteScores: [Int] = []
    @State private var rhythmScores: [Int] = []
    @State private var startTime: Date = Date()
    @State private var permissionDenied: Bool = false
    @State private var singingTimer: Timer?

    @State private var melody: [MelodyNote] = []
    @State private var selectedNotation: NotationType = NotationPreferences.shared.preferredNotation

    private let pitchDetector = PitchDetector.shared

    init(exercise: ExerciseType, module: ExerciseModule, viewModel: PracticeViewModel) {
        self.exercise = exercise
        self.module = module
        self.viewModel = viewModel
        _melody = State(initialValue: generateMelody(for: exercise))
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            switch state {
            case .intro:
                introView
            case .playingDemo:
                demoPlayingView
            case .waitingToSing:
                waitingToSingView
            case .singing:
                singingView
            case .result:
                SightSingingResultView(
                    pitchScore: pitchScore,
                    rhythmScore: rhythmScore,
                    noteScores: noteScores,
                    melody: melody,
                    onRetry: resetPractice,
                    onSave: saveAndExit
                )
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
        .onDisappear {
            cleanup()
        }
    }

    // MARK: - Intro View

    private var introView: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "music.mic")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.primary)

            VStack(spacing: 12) {
                Text("视唱练习")
                    .font(.title)
                    .fontWeight(.bold)

                Text("跟着简谱演唱，系统实时评分")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            // 旋律预览
            SolfegeView(notes: melody.map { SolfegeNote(solfege: $0.solfege, octave: $0.octave, duration: .quarter) }, highlightedIndex: 0)
                .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    checkPermissionAndStart()
                } label: {
                    Text("开始练习")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    dismiss()
                } label: {
                    Text("取消")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Demo Playing View

    private var demoPlayingView: some View {
        VStack(spacing: 32) {
            Spacer()

            // 当前谱式展示
            notationDisplay

            Image(systemName: "waveform")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.primary)
                .symbolEffect(.variableColor.iterative.reversing)
                .padding()

            Text("正在播放示范...")
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()

            ProgressView()
                .scaleEffect(1.5)
                .padding(.bottom, 64)
        }
        .onAppear {
            playDemoMelody()
        }
    }

    /// 谱式展示
    private var notationDisplay: some View {
        VStack(spacing: 16) {
            // 谱式切换器
            CompactNotationSwitcher(selectedNotation: $selectedNotation, availableNotations: NotationType.allCases)
                .frame(width: 200)

            // 谱式内容
            Group {
                switch selectedNotation {
                case .tabWithSolfege:
                    // 六线谱+简谱组合视图
                    VStack(spacing: 12) {
                        GuitarTablatureView(
                            notes: guitarNotesForCurrent,
                            fretRange: 0...5
                        )
                        Divider()
                        SolfegeView(
                            notes: melody.map { SolfegeNote(solfege: $0.solfege, octave: $0.octave, duration: .quarter) },
                            highlightedIndex: currentNoteIndex
                        )
                    }
                case .staff:
                    StaffNotationView(notes: staffNotesForCurrent)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var guitarNotesForCurrent: [GuitarTabNote] {
        melody.prefix(4).enumerated().map { index, note in
            GuitarTabNote(
                string: 6 - (index % 6),
                fret: Int.random(in: 0...3),
                technique: nil
            )
        }
    }

    private var staffNotesForCurrent: [StaffNote] {
        melody.prefix(4).enumerated().map { index, note in
            StaffNote(
                pitch: StaffPitch(line: index * 2),
                duration: .quarter,
                accidental: nil
            )
        }
    }

    // MARK: - Waiting View

    private var waitingToSingView: some View {
        VStack(spacing: 32) {
            Spacer()

            notationDisplay

            VStack(spacing: 12) {
                Text("点击下方按钮开始演唱")
                    .font(.headline)

                Text("请对着麦克风模唱旋律")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                startSinging()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "mic.fill")
                        .font(.title2)
                    Text("开始演唱")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Singing View

    @State private var detectedFrequency: Double = 0
    @State private var centsDeviation: Double = 0

    private var singingView: some View {
        VStack(spacing: 0) {
            // 顶部进度
            HStack {
                Text("第 \(currentNoteIndex + 1) / \(melody.count) 音")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("演唱中...")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.primary)
            }
            .padding()
            .background(Color(.systemBackground))

            Divider()

            VStack(spacing: 24) {
                // 谱式展示
                notationDisplay

                // 音准指示器
                PitchMeterView(
                    centsDeviation: centsDeviation,
                    isActive: true,
                    targetNote: melody[currentNoteIndex].solfege,
                    octave: melody[currentNoteIndex].octave
                )

                // 当前目标音
                VStack(spacing: 4) {
                    Text("目标音")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(melody[currentNoteIndex].solfege)\(melody[currentNoteIndex].octave)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.primary)
                }
            }
            .frame(maxHeight: .infinity)
            .padding()

            // 停止按钮
            Button {
                stopSinging()
            } label: {
                Text("完成演唱")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.error)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    // MARK: - 权限检查

    private func checkPermissionAndStart() {
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

    // MARK: - 播放示范旋律

    private func playDemoMelody() {
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

    // MARK: - 演唱计时

    @State private var singingStartTime: Date = Date()
    @State private var currentNoteStartTime: Date = Date()

    private func startSinging() {
        pitchDetector.startDetection()
        state = .singing
        startTime = Date()
        singingStartTime = Date()
        currentNoteIndex = 0
        currentNoteStartTime = Date()
        noteScores = []
        rhythmScores = []

        singingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            guard self.state == .singing else {
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
                self.noteScores.append(self.pitchDetector.currentScore)
            }
        }
    }

    private func stopSinging() {
        singingTimer?.invalidate()
        singingTimer = nil
        pitchDetector.stopDetection()

        let avgPitchScore = noteScores.isEmpty ? 0 : noteScores.reduce(0, +) / noteScores.count
        pitchScore = avgPitchScore

        let currentNote = melody[currentNoteIndex]
        let elapsedTime = Date().timeIntervalSince(currentNoteStartTime)
        let finalRhythmScore = calculateRhythmScore(
            actualDuration: elapsedTime,
            expectedDuration: currentNote.duration
        )
        rhythmScores.append(finalRhythmScore)
        rhythmScore = rhythmScores.isEmpty ? 100 : rhythmScores.reduce(0, +) / rhythmScores.count

        totalScore = Int(Double(pitchScore) * 0.7 + Double(rhythmScore) * 0.3)
        state = .result
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

    // MARK: - 资源清理

    private func cleanup() {
        singingTimer?.invalidate()
        singingTimer = nil
        pitchDetector.stopDetection()
        pitchDetector.reset()
    }

    private func resetPractice() {
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

    private func saveAndExit() {
        viewModel.savePracticeRecord(
            module: module,
            exerciseType: exercise,
            score: totalScore,
            durationSeconds: Int(Date().timeIntervalSince(startTime))
        )
        dismiss()
    }

    private var targetFrequency: Double {
        guard currentNoteIndex < melody.count else { return 0 }
        let note = melody[currentNoteIndex]
        return MusicTheory.frequencyFromMIDI(
            MusicTheory.midiNote(from: note.solfege, octave: note.octave) ?? 60
        )
    }

    // MARK: - 旋律生成

    private func generateMelody(for exercise: ExerciseType) -> [MelodyNote] {
        switch exercise {
        case .intervalSinging:
            if let intervalQ = QuestionBank.intervalQuestions.randomElement() {
                let semitones = intervalQ.semitones
                let rootMIDI = 60
                let targetMIDI = rootMIDI + semitones
                let (targetSolfege, targetOctave) = midiToSolfege(targetMIDI)
                let (rootSolfege, rootOctave) = midiToSolfege(rootMIDI)
                return [
                    MelodyNote(solfege: rootSolfege, octave: rootOctave, duration: 1.0),
                    MelodyNote(solfege: targetSolfege, octave: targetOctave, duration: 2.0),
                ]
            }
            return defaultMelody()
        default:
            return defaultMelody()
        }
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

// MARK: - 扩展

extension SolfegeView {
    init(notes: [SolfegeNote], highlightedIndex: Int?) {
        self.init(notes: notes, keySignature: "1=C", timeSignature: "4/4", highlightedIndex: highlightedIndex)
    }
}

#Preview {
    NavigationStack {
        SightSingingView(
            exercise: .intervalSinging,
            module: .melody,
            viewModel: PracticeViewModel()
        )
    }
}
