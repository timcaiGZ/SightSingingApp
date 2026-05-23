import SwiftUI

// MARK: - 视唱练习页 (匹配 v0 sight-singing-view, 接入真实 PitchDetector + ViewModel)

struct SightSingingView: View {
    @Environment(\.dismiss) private var dismiss

    let exercise: ExerciseType
    let module: ExerciseModule
    let viewModel: PracticeViewModel

    @State private var localVM = SightSingingViewModel()

    var body: some View {
        Group {
            switch localVM.state {
            case .intro:
                introView
            case .playingDemo:
                demoPlayingView
            case .waitingToSing:
                waitingToSingView
            case .singing:
                singingView
            case .result:
                SightSingingResult(
                    score: localVM.totalScore,
                    pitchScore: localVM.pitchScore,
                    rhythmScore: localVM.rhythmScore,
                    onRetry: {
                        localVM.resetPractice()
                    },
                    onNext: {
                        localVM.cleanup()
                        dismiss()
                    },
                    onBack: {
                        localVM.cleanup()
                        dismiss()
                    },
                    exerciseTitle: exercise.rawValue
                )
            }
        }
        .onAppear {
            localVM.generateMelody(for: exercise)
            // 保存练习记录
            localVM.onPracticeComplete = { pitch, rhythm, total in
                Task {
                    viewModel.savePracticeRecord(
                        module: module,
                        exerciseType: exercise,
                        score: total,
                        durationSeconds: 0
                    )
                }
            }
        }
        .onDisappear {
            localVM.cleanup()
        }
    }

    // MARK: - 介绍页

    private var introView: some View {
        ExerciseLayout(
            title: exercise.rawValue,
            questionNumber: 1,
            totalQuestions: localVM.melody.count,
            questionText: "即将播放示范旋律，仔细聆听后演唱。",
            score: 0,
            showDecompose: false,
            onBack: {
                localVM.cleanup()
                dismiss()
            },
            onNewQuestion: {},
            onReplay: {},
            replayLabel: "示范"
        ) {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "music.mic")
                        .font(.system(size: 48))
                        .foregroundStyle(AppTheme.accent)

                    Text("视唱练习")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)

                    Text("请戴好耳机，准备好麦克风")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Button {
                    localVM.checkPermissionAndStart()
                } label: {
                    Text("开始练习")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)

                if localVM.permissionDenied {
                    Text("麦克风权限被拒绝，请在系统设置中开启。")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.error)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding(.vertical, 16)
        }
    }

    // MARK: - 播放示范页

    private var demoPlayingView: some View {
        ExerciseLayout(
            title: exercise.rawValue,
            questionNumber: 1,
            totalQuestions: localVM.melody.count,
            questionText: "请仔细聆听示范旋律...",
            score: 0,
            showDecompose: false,
            onBack: {
                localVM.cleanup()
                dismiss()
            },
            onNewQuestion: {},
            onReplay: {
                localVM.playDemoMelody()
            },
            replayLabel: "重播"
        ) {
            VStack(spacing: 24) {
                Spacer()

                // 当前播放音符
                if localVM.currentNoteIndex < localVM.melody.count {
                    let note = localVM.melody[localVM.currentNoteIndex]
                    VStack(spacing: 8) {
                        Text("示范旋律")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                        Text("\(note.displayName)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.accent)
                    }
                }

                // 旋律进度
                HStack(spacing: 6) {
                    ForEach(Array(localVM.melody.enumerated()), id: \.offset) { index, note in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index <= localVM.currentNoteIndex ? AppTheme.accent : AppTheme.border)
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 32)

                Text("准备演唱...")
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.secondaryText)

                Spacer()
            }
            .padding(.vertical, 16)
            .onAppear {
                localVM.playDemoMelody()
            }
        }
    }

    // MARK: - 等待演唱页

    private var waitingToSingView: some View {
        ExerciseLayout(
            title: exercise.rawValue,
            questionNumber: 1,
            totalQuestions: localVM.melody.count,
            questionText: "请看目标音符，按住麦克风按钮演唱该音。",
            score: 0,
            showDecompose: false,
            onBack: {
                localVM.cleanup()
                dismiss()
            },
            onNewQuestion: {},
            onReplay: {
                localVM.playDemoMelody()
            },
            replayLabel: "重播"
        ) {
            VStack(spacing: 24) {
                Spacer()

                if !localVM.melody.isEmpty {
                    VStack(spacing: 8) {
                        Text("目标旋律")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)

                        HStack(spacing: 12) {
                            ForEach(Array(localVM.melody.enumerated()), id: \.offset) { _, note in
                                Text(note.displayName)
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppTheme.accent)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.accent.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }

                    PitchMeter(centsDeviation: 0, isListening: false)

                    Text("按住下方按钮开始演唱")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.tertiaryText)
                }

                Spacer()
            }
            .padding(.vertical, 16)
        } bottomContent: {
            SingButton(
                isPressed: false,
                onPressStart: {
                    localVM.startSinging()
                },
                onPressEnd: {}
            )
            .padding(.bottom, 8)
        }
    }

    // MARK: - 演唱进行中页 (真实音高检测)

    private var singingView: some View {
        ExerciseLayout(
            title: exercise.rawValue,
            questionNumber: localVM.currentNoteIndex + 1,
            totalQuestions: localVM.melody.count,
            questionText: "请在音高指示器的引导下演唱。",
            score: 0,
            showDecompose: false,
            onBack: {
                localVM.stopSinging()
                localVM.cleanup()
                dismiss()
            },
            onNewQuestion: {},
            onReplay: {
                localVM.playDemoMelody()
            },
            replayLabel: "示范"
        ) {
            VStack(spacing: 24) {
                Spacer()

                // 当前目标音符
                if localVM.currentNoteIndex < localVM.melody.count {
                    let note = localVM.melody[localVM.currentNoteIndex]
                    VStack(spacing: 8) {
                        Text("目标音")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                        Text(note.displayName)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.accent)
                    }

                    // 实时音高反馈
                    PitchMeter(
                        centsDeviation: localVM.centsDeviation,
                        isListening: true
                    )

                    // 频率显示
                    if localVM.detectedFrequency > 0 {
                        Text(String(format: "%.1f Hz", localVM.detectedFrequency))
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }

                // 旋律进度
                HStack(spacing: 6) {
                    ForEach(Array(localVM.melody.enumerated()), id: \.offset) { index, _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                index < localVM.currentNoteIndex ? AppTheme.success :
                                index == localVM.currentNoteIndex ? AppTheme.accent :
                                AppTheme.border
                            )
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .padding(.vertical, 16)
        } bottomContent: {
            SingButton(
                isPressed: true,
                onPressStart: {},
                onPressEnd: {
                    localVM.stopSinging()
                }
            )
            .padding(.bottom, 8)
        }
    }
}

// MARK: - 演唱按钮

struct SingButton: View {
    let isPressed: Bool
    let onPressStart: () -> Void
    let onPressEnd: () -> Void

    var body: some View {
        Button {
            // 使用手势控制
        } label: {
            ZStack {
                Circle()
                    .fill(isPressed ? AppTheme.accent.opacity(0.8) : AppTheme.accent)
                    .frame(width: 80, height: 80)
                    .shadow(color: AppTheme.accent.opacity(0.3), radius: 12, x: 0, y: 6)

                Image(systemName: "mic.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed { onPressStart() }
                }
                .onEnded { _ in
                    onPressEnd()
                }
        )
    }
}

// MARK: - 音准指示器

struct PitchMeter: View {
    let centsDeviation: Double
    let isListening: Bool

    var body: some View {
        VStack(spacing: 8) {
            // 刻度条
            ZStack {
                // 背景条
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.secondaryBg)
                    .frame(height: 8)

                // 指示器
                GeometryReader { geo in
                    let width = geo.size.width
                    let centerX = width / 2
                    let clampedCents = max(-50, min(50, centsDeviation))
                    let offset = CGFloat(clampedCents / 50) * (width / 2)

                    Circle()
                        .fill(isListening ? indicatorColor : AppTheme.tertiaryText)
                        .frame(width: 16, height: 16)
                        .position(x: centerX + offset, y: 4)
                }
                .frame(height: 8)

                // 中心标记
                Rectangle()
                    .fill(AppTheme.success)
                    .frame(width: 2, height: 16)
            }
            .frame(height: 16)
            .padding(.horizontal, 32)

            // 音分值
            Text(isListening ? String(format: "%.1f ¢", centsDeviation) : "按住按钮开始")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isListening ? indicatorColor : AppTheme.secondaryText)
        }
    }

    private var indicatorColor: Color {
        if abs(centsDeviation) <= 10 { return AppTheme.success }
        else if abs(centsDeviation) <= 30 { return AppTheme.warning }
        else { return AppTheme.error }
    }
}

// MARK: - 视唱结果页

struct SightSingingResult: View {
    let score: Int
    let pitchScore: Int
    let rhythmScore: Int
    let onRetry: () -> Void
    let onNext: () -> Void
    let onBack: () -> Void
    let exerciseTitle: String

    private var grade: (text: String, color: Color) {
        if score >= 95 { return ("完美!", AppTheme.success) }
        if score >= 85 { return ("优秀", AppTheme.success) }
        if score >= 70 { return ("良好", AppTheme.warning) }
        if score >= 60 { return ("及格", AppTheme.warning) }
        return ("继续加油", AppTheme.error)
    }

    var body: some View {
        ExerciseLayout(
            title: exerciseTitle,
            questionNumber: 10,
            totalQuestions: 10,
            questionText: "本次练习已完成，以下是您的成绩。",
            score: score,
            showDecompose: false,
            onBack: onBack,
            onNewQuestion: onRetry,
            onReplay: onNext,
            replayLabel: "下一题"
        ) {
            VStack(spacing: 32) {
                Spacer(minLength: 24)

                // 总分
                VStack(spacing: 8) {
                    Text("本次得分")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.secondaryText)

                    Text("\(score)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(grade.color)

                    Text(grade.text)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(grade.color)
                }

                // 分项得分
                HStack(spacing: 0) {
                    VStack(spacing: 8) {
                        Text("音准")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                        Text("\(pitchScore)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppTheme.accent)
                    }
                    .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(AppTheme.border)
                        .frame(width: 1, height: 48)

                    VStack(spacing: 8) {
                        Text("节奏")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                        Text("\(rhythmScore)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppTheme.warning)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 20)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .padding(.horizontal, 8)

                Spacer(minLength: 40)

                // 操作按钮
                VStack(spacing: 12) {
                    Button {
                        onNext()
                    } label: {
                        Text("退出练习")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    Button {
                        onRetry()
                    } label: {
                        Text("重新练习")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(AppTheme.primaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppTheme.secondaryBg)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 16)
        }
    }
}

// MARK: - 预览

#Preview {
    NavigationStack {
        SightSingingView(
            exercise: .intervalSinging,
            module: .melody,
            viewModel: PracticeViewModel()
        )
    }
}
