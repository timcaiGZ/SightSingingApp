import SwiftUI
import SwiftData

/// 视唱练习视图 — 完整闭环：展示简谱 → 播放示范 → 用户演唱 → 实时评分 → 结果展示
struct SightSingingView: View {
    let exercise: ExerciseType
    let module: ExerciseModule
    let viewModel: PracticeViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - 状态机
    @State private var state: SightSingingState = .intro
    @State private var currentNoteIndex: Int = 0
    @State private var pitchScore: Int = 0
    @State private var rhythmScore: Int = 0
    @State private var totalScore: Int = 0
    @State private var noteScores: [Int] = []
    @State private var rhythmScores: [Int] = []  // 每个音符的节奏得分
    @State private var startTime: Date = Date()
    @State private var permissionDenied: Bool = false
    @State private var singingTimer: Timer?  // 修复: 存储 Timer 引用以支持生命周期管理

    // 视唱旋律数据（根据 exercise 类型动态生成）
    @State private var melody: [MelodyNote] = []

    private let pitchDetector = PitchDetector.shared

    // MARK: - 初始化
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

    // MARK: - Intro 视图

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
            VStack(spacing: 8) {
                Text("本曲旋律")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 24) {
                    ForEach(Array(melody.enumerated()), id: \.offset) { index, note in
                        VStack(spacing: 4) {
                            Text(note.solfege)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundStyle(index == 0 ? AppColors.primary : .primary)
                            Text(noteDurationLabel(note.duration))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

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

    // MARK: - 播放示范视图

    private var demoPlayingView: some View {
        VStack(spacing: 32) {
            Spacer()

            // 简谱展示（播放时高亮当前音）
            SolfegeDisplayView(melody: melody, currentIndex: currentNoteIndex, isPlaying: true)

            // 动画波形
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

    // MARK: - 等待演唱视图

    private var waitingToSingView: some View {
        VStack(spacing: 32) {
            Spacer()

            SolfegeDisplayView(melody: melody, currentIndex: -1, isPlaying: false)

            VStack(spacing: 12) {
                Text("点击下方按钮开始演唱")
                    .font(.headline)

                Text("请对着麦克风模唱简谱旋律")
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
                .background(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    // MARK: - 演唱中视图

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

            // 简谱 + 当前音高亮
            VStack(spacing: 32) {
                SolfegeDisplayView(melody: melody, currentIndex: currentNoteIndex, isPlaying: false)

                // 实时音高指示器（使用 @State 变量确保线程安全）
                PitchIndicatorView(
                    detectedFrequency: detectedFrequency,
                    targetFrequency: targetFrequency,
                    centsDeviation: centsDeviation
                )

                // 当前目标音
                let currentNote = melody[currentNoteIndex]
                VStack(spacing: 4) {
                    Text("目标音")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(currentNote.solfege)\(currentNote.octave)")
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

        // 实时更新音高指示器和音索引
        singingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            guard self.state == .singing else {
                timer.invalidate()
                return
            }

            // 自动切换到下一个音（根据当前音的时值）
            let currentNote = self.melody[self.currentNoteIndex]
            let elapsedTime = Date().timeIntervalSince(self.currentNoteStartTime)

            // 如果当前音时值到期，自动切换到下一个
            if elapsedTime >= currentNote.duration {
                // 计算当前音符的节奏得分（实际时长与预期时值的偏差）
                let rhythmDeviation = abs(elapsedTime - currentNote.duration)
                let rhythmNoteScore = self.calculateRhythmScore(
                    actualDuration: elapsedTime,
                    expectedDuration: currentNote.duration
                )
                self.rhythmScores.append(rhythmNoteScore)

                if self.currentNoteIndex < self.melody.count - 1 {
                    self.currentNoteIndex += 1
                    self.currentNoteStartTime = Date()
                } else {
                    // 所有音符演唱完成，自动停止
                    timer.invalidate()
                    DispatchQueue.main.async {
                        self.stopSinging()
                    }
                    return
                }
            }

            // 更新目标音
            let note = self.melody[self.currentNoteIndex]
            self.pitchDetector.setTarget(solfege: note.solfege, octave: note.octave)

            // 主线程安全地获取检测结果
            DispatchQueue.main.async {
                self.detectedFrequency = self.pitchDetector.detectedFrequency
                self.centsDeviation = self.pitchDetector.centsDeviation
                self.noteScores.append(self.pitchDetector.currentScore)
            }
        }
    }

    // MARK: - 停止演唱 → 计算结果

    private func stopSinging() {
        singingTimer?.invalidate()
        singingTimer = nil
        pitchDetector.stopDetection()

        // 计算音准分
        let avgPitchScore = noteScores.isEmpty ? 0 : noteScores.reduce(0, +) / noteScores.count
        pitchScore = avgPitchScore

        // 计算节奏分（根据最后一个音符的实际演唱时长）
        let currentNote = melody[currentNoteIndex]
        let elapsedTime = Date().timeIntervalSince(currentNoteStartTime)
        let finalRhythmScore = calculateRhythmScore(
            actualDuration: elapsedTime,
            expectedDuration: currentNote.duration
        )
        rhythmScores.append(finalRhythmScore)
        rhythmScore = rhythmScores.isEmpty ? 100 : rhythmScores.reduce(0, +) / rhythmScores.count

        // 计算总分
        totalScore = Int(Double(pitchScore) * 0.7 + Double(rhythmScore) * 0.3)

        state = .result
    }

    /// 根据实际时长和预期时值计算节奏得分
    /// - Parameters:
    ///   - actualDuration: 用户演唱的实际持续时间
    ///   - expectedDuration: 预期的标准时值
    /// - Returns: 0-100 的节奏得分
    private func calculateRhythmScore(actualDuration: Double, expectedDuration: Double) -> Int {
        guard expectedDuration > 0 else { return 100 }

        let deviation = abs(actualDuration - expectedDuration) / expectedDuration

        // 偏差阈值评分
        if deviation <= 0.1 {  // ±10% 偏差内满分
            return 100
        } else if deviation <= 0.2 {  // ±20% 偏差内良好
            return 85
        } else if deviation <= 0.3 {  // ±30% 偏差内及格
            return 70
        } else if deviation <= 0.5 {  // ±50% 偏差内较差
            return 50
        } else {
            return 30
        }
    }

    // MARK: - 资源清理

    private func cleanup() {
        singingTimer?.invalidate()
        singingTimer = nil
        pitchDetector.stopDetection()
        pitchDetector.reset()
    }

    // MARK: - 重置

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

    // MARK: - 保存并退出

    private func saveAndExit() {
        viewModel.savePracticeRecord(
            module: module,
            exerciseType: exercise,
            score: totalScore,
            durationSeconds: Int(Date().timeIntervalSince(startTime))
        )
        dismiss()
    }

    // MARK: - Helpers

    private var targetFrequency: Double {
        guard currentNoteIndex < melody.count else { return 0 }
        let note = melody[currentNoteIndex]
        return MusicTheory.frequencyFromMIDI(
            MusicTheory.midiNote(from: note.solfege, octave: note.octave) ?? 60
        )
    }

    private func noteDurationLabel(_ duration: Double) -> String {
        switch duration {
        case 0.5: return "半拍"
        case 1.0: return "一拍"
        case 2.0: return "两拍"
        default: return "\(duration)拍"
        }
    }

    // MARK: - 旋律生成

    /// 根据 exercise 类型动态生成旋律（从题库随机抽取）
    private func generateMelody(for exercise: ExerciseType) -> [MelodyNote] {
        switch exercise {
        case .intervalSinging:
            // 音程视唱：选一个音程，随机上行或下行
            if let intervalQ = QuestionBank.intervalQuestions.randomElement() {
                let semitones = intervalQ.semitones
                let rootMIDI = 60 // C4
                let targetMIDI = rootMIDI + semitones
                let (targetSolfege, targetOctave) = midiToSolfege(targetMIDI)
                let (rootSolfege, rootOctave) = midiToSolfege(rootMIDI)
                let isUpward = Bool.random()
                if isUpward {
                    return [
                        MelodyNote(solfege: rootSolfege, octave: rootOctave, duration: 1.0),
                        MelodyNote(solfege: targetSolfege, octave: targetOctave, duration: 2.0),
                    ]
                } else {
                    return [
                        MelodyNote(solfege: targetSolfege, octave: targetOctave, duration: 1.0),
                        MelodyNote(solfege: rootSolfege, octave: rootOctave, duration: 2.0),
                    ]
                }
            }
            return defaultMelody()

        case .tablatureMelodySinging, .guitarMelodyRecognition, .harmonicRecognition:
            // 旋律视唱：从题库随机抽取旋律片段
            if let melodyQ = QuestionBank.melodyQuestions.randomElement() {
                let notes = melodyQ.solfege.split(separator: " ").map { String($0) }
                let octaves = guessOctaves(for: melodyQ.difficulty)
                return notes.enumerated().map { index, solfege in
                    let oct = octaves.count > index ? octaves[index] : 4
                    let isLast = index == notes.count - 1
                    return MelodyNote(
                        solfege: solfege,
                        octave: oct,
                        duration: isLast ? 2.0 : 1.0
                    )
                }
            }
            return defaultMelody()

        case .strummingPattern, .arpeggioPattern, .syncopationRecognition:
            // 节奏练习：从节奏题库取节奏型
            if let rhythmQ = QuestionBank.rhythmQuestions.randomElement() {
                // 根据节拍数生成对应音符
                return generateRhythmNotes(beats: rhythmQ.beats)
            }
            return [
                MelodyNote(solfege: "1", octave: 4, duration: 0.5),
                MelodyNote(solfege: "2", octave: 4, duration: 0.5),
                MelodyNote(solfege: "3", octave: 4, duration: 1.0),
                MelodyNote(solfege: "4", octave: 4, duration: 1.0),
                MelodyNote(solfege: "5", octave: 4, duration: 2.0),
            ]

        default:
            return defaultMelody()
        }
    }

    /// MIDI → (简谱, 八度)
    private func midiToSolfege(_ midi: Int) -> (String, Int) {
        let octave = (midi / 12) - 1
        let noteInOctave = midi % 12
        let mapping: [Int: String] = [
            0: "1", 1: "#1", 2: "2", 3: "#2", 4: "3",
            5: "4", 6: "#4", 7: "5", 8: "#5", 9: "6", 10: "#6", 11: "7"
        ]
        return (mapping[noteInOctave] ?? "1", octave)
    }

    /// 根据难度猜测音符八度（民谣吉他常用范围）
    private func guessOctaves(for difficulty: Difficulty) -> [Int] {
        switch difficulty {
        case .easy:   return [4, 4, 4, 4, 5]  // C4-G5 范围
        case .medium: return [3, 4, 4, 4, 5, 5] // G3-A5 范围
        case .hard:   return [3, 3, 4, 4, 5, 5, 6] // E3-C6 范围
        }
    }

    /// 根据节拍数生成节奏旋律
    private func generateRhythmNotes(beats: Int) -> [MelodyNote] {
        switch beats {
        case 4:
            return [
                MelodyNote(solfege: "1", octave: 4, duration: 0.5),
                MelodyNote(solfege: "2", octave: 4, duration: 0.5),
                MelodyNote(solfege: "3", octave: 4, duration: 1.0),
                MelodyNote(solfege: "4", octave: 4, duration: 1.0),
                MelodyNote(solfege: "5", octave: 4, duration: 2.0),
            ]
        case 3:
            return [
                MelodyNote(solfege: "1", octave: 4, duration: 1.0),
                MelodyNote(solfege: "3", octave: 4, duration: 1.0),
                MelodyNote(solfege: "5", octave: 4, duration: 2.0),
            ]
        case 6:
            return [
                MelodyNote(solfege: "1", octave: 4, duration: 0.5),
                MelodyNote(solfege: "2", octave: 4, duration: 0.5),
                MelodyNote(solfege: "3", octave: 4, duration: 0.5),
                MelodyNote(solfege: "4", octave: 4, duration: 0.5),
                MelodyNote(solfege: "5", octave: 4, duration: 0.5),
                MelodyNote(solfege: "6", octave: 4, duration: 0.5),
                MelodyNote(solfege: "7", octave: 4, duration: 0.5),
                MelodyNote(solfege: "1", octave: 5, duration: 0.5),
                MelodyNote(solfege: "2", octave: 5, duration: 0.5),
                MelodyNote(solfege: "3", octave: 5, duration: 1.5),
            ]
        case 5, 7, 12:
            return [
                MelodyNote(solfege: "1", octave: 4, duration: 0.5),
                MelodyNote(solfege: "2", octave: 4, duration: 0.5),
                MelodyNote(solfege: "3", octave: 4, duration: 1.0),
                MelodyNote(solfege: "5", octave: 4, duration: 1.0),
                MelodyNote(solfege: "6", octave: 4, duration: 0.5),
                MelodyNote(solfege: "7", octave: 4, duration: 0.5),
                MelodyNote(solfege: "1", octave: 5, duration: 2.0),
            ]
        default:
            return defaultMelody()
        }
    }

    /// 默认旋律
    private func defaultMelody() -> [MelodyNote] {
        return [
            MelodyNote(solfege: "1", octave: 4, duration: 1.0),
            MelodyNote(solfege: "2", octave: 4, duration: 1.0),
            MelodyNote(solfege: "3", octave: 4, duration: 1.0),
            MelodyNote(solfege: "5", octave: 4, duration: 2.0),
        ]
    }
}

// MARK: - 状态枚举

enum SightSingingState {
    case intro        // 介绍页
    case playingDemo  // 播放示范
    case waitingToSing // 等待演唱
    case singing      // 演唱中
    case result       // 结果页
}

// MARK: - 旋律音符

struct MelodyNote {
    let solfege: String   // 简谱音名：1-7
    let octave: Int       // 八度
    let duration: Double  // 时值（拍）
}

// MARK: - 简谱展示视图

struct SolfegeDisplayView: View {
    let melody: [MelodyNote]
    let currentIndex: Int
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(melody.enumerated()), id: \.offset) { index, note in
                VStack(spacing: 8) {
                    // 音符
                    Text(note.solfege)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(index == currentIndex ? AppColors.primary : .primary.opacity(0.3))
                        .scaleEffect(index == currentIndex ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: currentIndex)

                    // 时值标记
                    Text(durationLabel(note.duration))
                        .font(.caption)
                        .foregroundStyle(index == currentIndex ? Color.secondary : Color.secondary.opacity(0.5))

                    // 高音点
                    if note.octave >= 5 {
                        Circle()
                            .fill(index == currentIndex ? AppColors.primary : .primary.opacity(0.3))
                            .frame(width: 6, height: 6)
                    } else if note.octave <= 3 {
                        Circle()
                            .fill(index == currentIndex ? AppColors.primary : .primary.opacity(0.3))
                            .frame(width: 6, height: 6)
                        Text("（低音）")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        Spacer()
                            .frame(height: 6)
                    }
                }
                .frame(minWidth: 60)
                .padding(.vertical, 16)
                .background(
                    index == currentIndex ?
                    AppColors.primary.opacity(0.1) :
                    Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 音符间隔
                if index < melody.count - 1 {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 2, height: 40)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func durationLabel(_ duration: Double) -> String {
        switch duration {
        case 0.5: return "半拍"
        case 1.0: return "一拍"
        case 2.0: return "二拍"
        default: return "\(Int(duration))拍"
        }
    }
}

// MARK: - 音高指示器视图

struct PitchIndicatorView: View {
    let detectedFrequency: Double
    let targetFrequency: Double
    let centsDeviation: Double

    private let gaugeWidth: CGFloat = 280
    private let indicatorWidth: CGFloat = 4

    var body: some View {
        VStack(spacing: 8) {
            // 刻度尺
            ZStack {
                // 背景刻度
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: gaugeWidth, height: 60)

                // 目标区域（中心绿色区）
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.success.opacity(0.2))
                    .frame(width: 40, height: 60)

                // 中心线
                Rectangle()
                    .fill(AppColors.success)
                    .frame(width: 2, height: 70)

                // 检测到的音高指示器
                if detectedFrequency > 0 {
                    let offset = centsToOffset(centsDeviation)
                    Circle()
                        .fill(colorForCents(centsDeviation))
                        .frame(width: 16, height: 16)
                        .offset(x: offset)
                        .animation(.spring(response: 0.2), value: centsDeviation)
                }

                // 刻度标记
                HStack(spacing: 0) {
                    ForEach(-5..<6, id: \.self) { tick in
                        Rectangle()
                            .fill(Color.secondary.opacity(0.5))
                            .frame(width: 1, height: tick == 0 ? 50 : 20)
                        if tick < 5 { Spacer() }
                    }
                }
                .frame(width: gaugeWidth)
            }

            // 音分偏差显示
            HStack {
                Text("偏低")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if detectedFrequency > 0 {
                    Text("\(Int(centsDeviation)) 音分")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(colorForCents(centsDeviation))
                } else {
                    Text("— 音分")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("偏高")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: gaugeWidth)
        }
    }

    private func centsToOffset(_ cents: Double) -> CGFloat {
        let clamped = max(-50, min(50, cents))
        return CGFloat(clamped / 50) * (gaugeWidth / 2 - 20)
    }

    private func colorForCents(_ cents: Double) -> Color {
        let absCents = abs(cents)
        if absCents <= 10 {
            return AppColors.success
        } else if absCents <= 30 {
            return .yellow
        } else if absCents <= 50 {
            return .orange
        } else {
            return AppColors.error
        }
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
