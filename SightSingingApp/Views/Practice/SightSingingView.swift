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
    @State private var startTime: Date = Date()
    @State private var permissionDenied: Bool = false

    // 视唱旋律数据（简谱 + 时值）
    let melody: [MelodyNote] = [
        MelodyNote(solfege: "5", octave: 4, duration: 1.0),
        MelodyNote(solfege: "6", octave: 4, duration: 1.0),
        MelodyNote(solfege: "7", octave: 4, duration: 1.0),
        MelodyNote(solfege: "1", octave: 5, duration: 2.0),
    ]

    private let pitchDetector = PitchDetector.shared

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

                // 实时音高指示器
                PitchIndicatorView(
                    detectedFrequency: pitchDetector.detectedFrequency,
                    targetFrequency: targetFrequency,
                    centsDeviation: pitchDetector.centsDeviation
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
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.currentNoteIndex = index
                AudioEngine.shared.playSolfege(note.solfege, octave: note.octave)
            }
            delay += note.duration
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
            self.state = .waitingToSing
            self.currentNoteIndex = 0
        }
    }

    // MARK: - 开始演唱

    private func startSinging() {
        pitchDetector.startDetection()
        state = .singing
        startTime = Date()
        currentNoteIndex = 0
        noteScores = []

        // 实时更新音高指示器
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard self.state == .singing else {
                timer.invalidate()
                return
            }

            // 更新当前音索引（简化：手动或按检测到的音量切换）
            // 实际应根据音高检测自动切换
            let currentNote = self.melody[self.currentNoteIndex]
            self.pitchDetector.setTarget(solfege: currentNote.solfege, octave: currentNote.octave)

            // 记录当前音分数
            let score = self.pitchDetector.currentScore
            self.noteScores.append(score)
        }
    }

    // MARK: - 停止演唱 → 计算结果

    private func stopSinging() {
        pitchDetector.stopDetection()

        // 计算总分
        let avgPitchScore = noteScores.isEmpty ? 0 : noteScores.reduce(0, +) / noteScores.count
        pitchScore = avgPitchScore
        rhythmScore = 100 // 简化：节奏暂不检测
        totalScore = Int(Double(pitchScore) * 0.7 + Double(rhythmScore) * 0.3)

        state = .result
    }

    // MARK: - 重置

    private func resetPractice() {
        pitchDetector.reset()
        noteScores = []
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
