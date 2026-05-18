import SwiftUI
import SwiftData

/// 练习详情页（集成谱式切换器和多谱式展示）
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

    private struct QuestionItem {
        let question: String
        let answer: Int
        let options: [String]
        let solfege: String
        let octave: Int
    }

    private var questions: [QuestionItem] { loadQuestions() }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            contentView
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer()

                Text(exercise.rawValue)
                    .font(.headline)

                Spacer()

                Text("\(currentScore) 分")
                    .font(.headline)
                    .foregroundStyle(AppColors.primary)
            }
            .padding()


        }
        .background(Color(.systemBackground))
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        switch state {
        case .question:
            questionView
        case .feedback:
            feedbackView
        case .finished:
            finishedView
        }
    }

    // MARK: - Question View

    private var questionView: some View {
        VStack(spacing: 20) {
            // 进度圆点
            progressDots

            Spacer()

            // 题目内容
            let current = questions[questionCount % questions.count]

            // 谱式展示区
            notationDisplayArea

            // 播放按钮
            Button {
                Task {
                    await AudioEngineManager.shared.playSolfege(current.solfege, octave: current.octave)
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 72, height: 72)

                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }

            // 题目文字
            Text(current.question)
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.primaryText)
                .padding(.horizontal)

            Spacer()

            // 选项
            optionsList(current: current)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
        }
    }

    /// 进度圆点
    private var progressDots: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<questions.count, id: \.self) { index in
                    Circle()
                        .fill(dotColor(for: index))
                        .frame(width: 8, height: 8)
                }
            }

            Text("\(questionCount + 1) / \(questions.count)")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding(.top, 16)
    }

    private func dotColor(for index: Int) -> Color {
        if index < questionCount {
            return isCorrect == true ? AppColors.success : AppColors.error
        } else if index == questionCount {
            return AppColors.primary
        }
        return AppColors.tertiaryText
    }

    /// 谱式展示区（仅六线谱+简谱）
    private var notationDisplayArea: some View {
        VStack(spacing: 12) {
            GuitarTablatureView(
                notes: tabNotesForCurrent,
                fretRange: 0...5
            )
            Divider()
            SolfegeView(
                notes: solfegeNotesForCurrent,
                highlightedIndex: 0
            )
        }
        .padding(.horizontal, 24)
    }

    /// 六线谱音符（五弦2品 = B音）
    private var tabNotesForCurrent: [GuitarTabNote] {
        [
            GuitarTabNote(string: 5, fret: 2, technique: nil)
        ]
    }

    /// 五线谱音符
    private var staffNotesForCurrent: [StaffNote] {
        [
            StaffNote(pitch: StaffPitch(line: 0), duration: .quarter, accidental: nil),
            StaffNote(pitch: StaffPitch(line: 2), duration: .quarter, accidental: nil),
            StaffNote(pitch: StaffPitch(line: 4), duration: .quarter, accidental: nil),
        ]
    }

    /// 简谱音符
    private var solfegeNotesForCurrent: [SolfegeNote] {
        [
            SolfegeNote(solfege: "1", octave: 4, duration: .quarter),
            SolfegeNote(solfege: "2", octave: 4, duration: .quarter),
            SolfegeNote(solfege: "3", octave: 4, duration: .quarter),
        ]
    }

    /// 选项列表
    private func optionsList(current: QuestionItem) -> some View {
        VStack(spacing: 10) {
            Text("请选择")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(Array(current.options.enumerated()), id: \.offset) { index, option in
                Button {
                    selectAnswer(index)
                } label: {
                    HStack {
                        Text(optionLetter(index))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(AppColors.primary.opacity(0.7))
                            .clipShape(Circle())

                        Text(option)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(AppColors.primaryText)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func optionLetter(_ index: Int) -> String {
        let letters = ["A", "B", "C", "D", "E", "F"]
        return index < letters.count ? letters[index] : "\(index + 1)"
    }

    // MARK: - Feedback View

    private var feedbackView: some View {
        VStack(spacing: 24) {
            Spacer()

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
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

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

    // MARK: - Finished View

    private var finishedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)

            Text("练习完成！")
                .font(.title)
                .fontWeight(.bold)

            Text("得分：\(currentScore) / 100")
                .font(.title2)
                .foregroundStyle(AppColors.primary)

            Text("正确率：\(correctCount)/\(questions.count)")
                .font(.body)
                .foregroundStyle(AppColors.secondaryText)

            Spacer()

            VStack(spacing: 12) {
                Button {
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

    // MARK: - Actions

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

        let generator = UIImpactFeedbackGenerator(style: correct ? .medium : .heavy)
        generator.impactOccurred()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
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

    // MARK: - Data Loading

    private func loadQuestions() -> [QuestionItem] {
        switch exercise {
        case .singleNoteRecognition:
            return QuestionBank.noteNameQuestions.prefix(10).map { q in
                let options = generateNoteNameOptions(correct: q.noteName)
                return QuestionItem(
                    question: "简谱 \(q.solfege) 对应哪个音名？",
                    answer: options.firstIndex(of: q.noteName) ?? 0,
                    options: options,
                    solfege: q.solfege,
                    octave: q.octave
                )
            }
        case .openStringRecognition:
            let openStrings = [
                (6, "3", "E", 2), (5, "6", "A", 2), (4, "2", "D", 3),
                (3, "5", "G", 3), (2, "7", "B", 3), (1, "3", "E", 4)
            ]
            return openStrings.shuffled().prefix(10).map { string in
                let options = generateNoteNameOptions(correct: string.2)
                return QuestionItem(
                    question: "第 \(string.0) 弦空弦是什么音？",
                    answer: options.firstIndex(of: string.2) ?? 0,
                    options: options,
                    solfege: string.1,
                    octave: string.3
                )
            }
        default:
            return [
                QuestionItem(question: "简谱 1 对应哪个音名？", answer: 0, options: ["C", "D", "E", "G"], solfege: "1", octave: 4),
                QuestionItem(question: "第6弦空弦是什么音？", answer: 2, options: ["A", "E", "D", "G"], solfege: "3", octave: 3),
                QuestionItem(question: "C 和弦包含哪些音？", answer: 0, options: ["C-E-G", "D-F-A", "E-G-B", "F-A-C"], solfege: "1", octave: 4),
            ]
        }
    }

    private func generateNoteNameOptions(correct: String) -> [String] {
        let allNotes = ["C", "D", "E", "F", "G", "A", "B"]
        var options = [correct]
        while options.count < 4 {
            let note = allNotes.randomElement() ?? "C"
            if !options.contains(note) {
                options.append(note)
            }
        }
        return options.shuffled()
    }
}

#Preview {
    ExerciseDetailView(
        exercise: .singleNoteRecognition,
        module: .noteName,
        viewModel: PracticeViewModel()
    )
}
