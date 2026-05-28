import SwiftUI

// MARK: - 统一练习页面布局 (匹配 v0 ExerciseLayout)

struct ExerciseLayout<Content: View, BottomContent: View>: View {
    let title: String
    let questionNumber: Int
    let totalQuestions: Int
    let questionText: String
    let score: Int?
    let scoreLabel: String?
    let showDecompose: Bool
    let onBack: () -> Void
    let onNewQuestion: () -> Void
    let onDecompose: (() -> Void)?
    let onReplay: () -> Void
    let replayLabel: String
    let content: Content
    let bottomContent: BottomContent

    @State private var selectedNotation: NotationType = NotationPreferences.shared.preferredNotation

    init(
        title: String,
        questionNumber: Int,
        totalQuestions: Int,
        questionText: String,
        score: Int? = nil,
        scoreLabel: String? = nil,
        showDecompose: Bool = false,
        onBack: @escaping () -> Void,
        onNewQuestion: @escaping () -> Void,
        onDecompose: (() -> Void)? = nil,
        onReplay: @escaping () -> Void,
        replayLabel: String = "重听",
        @ViewBuilder content: () -> Content,
        @ViewBuilder bottomContent: () -> BottomContent = { EmptyView() }
    ) {
        self.title = title
        self.questionNumber = questionNumber
        self.totalQuestions = totalQuestions
        self.questionText = questionText
        self.score = score
        self.scoreLabel = scoreLabel
        self.showDecompose = showDecompose
        self.onBack = onBack
        self.onNewQuestion = onNewQuestion
        self.onDecompose = onDecompose
        self.onReplay = onReplay
        self.replayLabel = replayLabel
        self.content = content()
        self.bottomContent = bottomContent()
    }

    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            navBar

            // 问题提示
            HStack {
                Text("Q\(questionNumber): \(questionText)")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.primaryText)
                    .lineSpacing(4)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // 主要内容区域
            ScrollView {
                VStack(spacing: 0) {
                    content
                }
                .padding(.horizontal, 16)
            }

            // 底部操作栏
            bottomActionBar

            // 底部内容（键盘、录音按钮等）
            if !(bottomContent is EmptyView) {
                bottomContent
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
        .background(AppTheme.background)
    }

    // MARK: - 导航栏 (匹配 v0 NavBar: iOS 模糊背景)

    private var navBar: some View {
        HStack {
            // 左侧返回
            Button(action: onBack) {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                    Text("返回")
                        .font(.system(size: 17))
                }
                .foregroundStyle(AppTheme.accent)
            }

            Spacer()

            // 中间标题
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.primaryText)
                .lineLimit(1)

            Spacer()

            // 右侧分数
            if let scoreLabel = scoreLabel {
                Text(scoreLabel)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
            } else if let score = score {
                Text("\(score) 分")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
            } else {
                Color.clear.frame(width: 50)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    // MARK: - 底部操作栏 (匹配 v0: 纯文字按钮, justify-between 两端对齐)

    private var bottomActionBar: some View {
        HStack {
            // 新问题 (左对齐)
            Button(action: onNewQuestion) {
                Text("新问题")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
            }
            .buttonStyle(.plain)

            Spacer()

            // 分解 (居中，如果有)
            if showDecompose, let onDecompose = onDecompose {
                Button(action: onDecompose) {
                    Text("分解")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.accent)
                }
                .buttonStyle(.plain)

                Spacer()
            }

            // 重听/示范 (右对齐)
            Button(action: onReplay) {
                Text(replayLabel)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - 进度圆点 (匹配 v0 ProgressDots)

struct ExerciseProgressDots: View {
    let total: Int
    let current: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                let questionIndex = index + 1
                let isCompleted = questionIndex < current
                let isCurrent = questionIndex == current

                Circle()
                    .fill(
                        isCurrent ? AppTheme.accent :
                        isCompleted ? AppTheme.accent.opacity(0.4) :
                        AppTheme.tertiaryText.opacity(0.3)
                    )
                    .frame(width: 10, height: 10)
                    .scaleEffect(isCurrent ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: current)
            }
        }
    }
}

// MARK: - 胶囊谱式切换器 (匹配 v0 NotationPillSwitcher)

struct PillNotationSwitcher: View {
    @Binding var selectedNotation: NotationType

    var body: some View {
        HStack(spacing: 0) {
            ForEach([NotationType.staff, .tabWithSolfege]) { notation in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedNotation = notation
                        NotationPreferences.shared.preferredNotation = notation
                    }
                } label: {
                    Text(notation.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(
                            selectedNotation == notation ? .white : AppTheme.secondaryText
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            selectedNotation == notation ? AppTheme.accent : Color.clear
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(AppTheme.secondaryBg)
        .clipShape(Capsule())
    }
}

// MARK: - 音频提示卡片 (匹配 v0 AudioPromptCard)

struct AudioPromptCard: View {
    let label: String
    let hint: String
    let onPlay: () -> Void

    var body: some View {
        Button(action: onPlay) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.1))
                        .frame(width: 64, height: 64)
                    Image(systemName: "play.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(AppTheme.accent)
                }

                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.primaryText)

                Text(hint)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding(.vertical, 24)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 标准音卡片 (匹配 v0 ReferenceNoteCard)

struct ReferenceNoteCard: View {
    let note: String
    let frequency: String
    let onPlay: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onPlay) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent)
                        .frame(width: 56, height: 56)
                        .shadow(color: AppTheme.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                    Text(note)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("标准音 \(note)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.primaryText)
                Text(frequency)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()
        }
        .padding(.bottom, 12)
    }
}

// MARK: - 选择题列表 (匹配 v0 ChoiceList)

struct ChoiceList: View {
    let options: [String]
    let selectedOption: String?
    let correctAnswer: String?
    let showResult: Bool
    let onSelect: (String) -> Void
    let onNext: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 0) {
                // 标题行
                HStack {
                    Text("请选择")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.secondaryText)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppTheme.secondaryBg.opacity(0.5))

                // 选项列表
                VStack(spacing: 0) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        let isSelected = selectedOption == option
                        let isCorrect = showResult && option == correctAnswer
                        let isWrong = showResult && isSelected && option != correctAnswer

                        Button {
                            if !showResult {
                                onSelect(option)
                            }
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.system(size: 16))
                                    .foregroundStyle(
                                        isCorrect ? AppTheme.success :
                                        isWrong ? AppTheme.error :
                                        AppTheme.primaryText
                                    )
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                isCorrect ? AppTheme.success.opacity(0.1) :
                                isWrong ? AppTheme.error.opacity(0.1) :
                                isSelected ? AppTheme.accent.opacity(0.05) :
                                Color.clear
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(showResult)

                        if index < options.count - 1 {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppTheme.border, lineWidth: 1)
            )

            // 下一题按钮 (匹配 v0 rounded-xl)
            if showResult, let onNext = onNext {
                Button(action: onNext) {
                    Text("下一题")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - 预览

#Preview {
    ExerciseLayout(
        title: "单音辨认",
        questionNumber: 1,
        totalQuestions: 10,
        questionText: "请输入音符名称",
        score: 0,
        showDecompose: false,
        onBack: {},
        onNewQuestion: {},
        onReplay: {}
    ) {
        VStack(spacing: 16) {
            AudioPromptCard(label: "点击播放", hint: "听取音符") {}
            Text("谱面预览区域")
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        }
        .padding(.vertical, 16)
    } bottomContent: {
        Text("底部内容")
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(AppTheme.secondaryBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
