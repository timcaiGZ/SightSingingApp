import SwiftUI
import SwiftData

/// 练习详情页（实际练习界面）
struct ExerciseDetailView: View {
    let exercise: ExerciseType
    let module: ExerciseModule
    let viewModel: PracticeViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var state: ExerciseState = .question
    @State private var currentScore: Int = 0
    @State private var questionCount: Int = 0
    @State private var correctCount: Int = 0
    @State private var selectedAnswer: Int?
    @State private var isCorrect: Bool?
    @State private var startTime: Date = Date()

    enum ExerciseState {
        case question
        case feedback
        case finished
    }

    // 模拟题目数据
    let questions: [(question: String, answer: Int, options: [String])] = [
        ("简谱 `1` 对应哪个音名？", 0, ["C", "D", "E", "G"]),
        ("第6弦空弦是什么音？", 2, ["A", "E", "D", "G"]),
        ("C 和弦包含哪些音？", 1, ["C-E-G", "D-F-A", "E-G-B", "F-A-C"]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(exercise.rawValue)
                    .font(.headline)

                Spacer()

                // 得分
                Text("\(currentScore) 分")
                    .font(.headline)
                    .foregroundStyle(AppColors.primary)
            }
            .padding()
            .background(Color(.systemBackground))

            Divider()

            // 内容区
            Group {
                switch state {
                case .question:
                    questionView
                case .feedback:
                    feedbackView
                case .finished:
                    finishedView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    private var questionView: some View {
        VStack(spacing: 32) {
            // 进度
            HStack {
                Text("第 \(questionCount + 1) / \(questions.count) 题")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)

            Spacer()

            // 题目
            let current = questions[questionCount % questions.count]
            VStack(spacing: 16) {
                // 播放按钮
                Button {
                    // 播放音频
                    AudioEngine.shared.playSolfege("1", octave: 4)
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 80, height: 80)

                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                }

                Text(current.question)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()

            // 选项
            VStack(spacing: 12) {
                ForEach(Array(current.options.enumerated()), id: \.offset) { index, option in
                    Button {
                        selectAnswer(index)
                    } label: {
                        Text(option)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private var feedbackView: some View {
        VStack(spacing: 24) {
            Spacer()

            // 结果图标
            Image(systemName: isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(isCorrect == true ? AppColors.success : AppColors.error)

            Text(isCorrect == true ? "正确！" : "错误")
                .font(.title)
                .fontWeight(.bold)

            if isCorrect == false {
                let correct = questions[questionCount % questions.count].options[
                    questions[questionCount % questions.count].answer
                ]
                Text("正确答案：\(correct)")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 继续按钮
            Button {
                nextQuestion()
            } label: {
                Text("下一题")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private var finishedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("练习完成！")
                .font(.title)
                .fontWeight(.bold)

            Text("得分：\(currentScore) / 100")
                .font(.title2)
                .foregroundStyle(AppColors.primary)

            Text("正确率：\(correctCount)/\(questions.count)")
                .font(.body)
                .foregroundStyle(.secondary)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    // 保存记录
                    viewModel.savePracticeRecord(
                        module: module,
                        exerciseType: exercise,
                        score: currentScore,
                        durationSeconds: Int(Date().timeIntervalSince(startTime))
                    )
                    dismiss()
                } label: {
                    Text("保存并退出")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    // 重新开始
                    questionCount = 0
                    correctCount = 0
                    currentScore = 0
                    state = .question
                    startTime = Date()
                } label: {
                    Text("再练一次")
                        .font(.headline)
                        .foregroundStyle(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func selectAnswer(_ index: Int) {
        let current = questions[questionCount % questions.count]
        let correct = index == current.answer
        selectedAnswer = index
        isCorrect = correct
        questionCount += 1

        if correct {
            correctCount += 1
            currentScore = Int(Double(correctCount) / Double(questionCount) * 100)
        }

        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: correct ? .medium : .heavy)
        generator.impactOccurred()

        // 延迟进入反馈或完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if questionCount >= questions.count {
                state = .finished
            } else {
                state = .feedback
            }
        }
    }

    private func nextQuestion() {
        selectedAnswer = nil
        isCorrect = nil
        state = .question
    }
}

#Preview {
    ExerciseDetailView(
        exercise: .singleNoteRecognition,
        module: .noteName,
        viewModel: PracticeViewModel()
    )
}
