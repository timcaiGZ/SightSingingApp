import SwiftUI

// MARK: - 练习详情页 (匹配 v0 exercise-detail 选择题设计)

struct ExerciseDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let exercise: ExerciseType
    let module: ExerciseModule
    let viewModel: PracticeViewModel

    private let totalQuestions = 10

    @State private var currentQuestion = 1
    @State private var score = 0
    @State private var correctCount = 0
    @State private var selectedOption: String?
    @State private var showResult = false
    @State private var showComplete = false

    // 多轮练习追踪
    @State private var roundNumber = 1
    @State private var roundResults: [DetailRoundResult] = []

    /// 单轮成绩记录（ExerciseDetailView 专用）
    struct DetailRoundResult: Identifiable {
        let id = UUID()
        let round: Int
        let correctCount: Int
        let totalQuestions: Int
        var accuracy: Int { Int(Double(correctCount) / Double(totalQuestions) * 100) }
    }

    @State private var currentQuestionData: QuestionData = QuestionData(displayContent: "点击播放", displayLabel: "加载中...", options: [], correctAnswer: "")

    private var showDecompose: Bool {
        !["rhythm-hear", "melody-dictation", "interval-compare"].contains(exerciseID)
    }

    private var exerciseID: String {
        switch exercise {
        case .intervalRecognition: return "interval"
        case .chordQualityRecognition: return "chord"
        case .commonChordRecognition: return "triad"
        case .barreChordRecognition: return "seventh-chord"
        case .scaleRecognition: return "chord-inversion"
        case .syncopationRecognition: return "rhythm-hear"
        case .tablatureMelodySinging: return "melody-dictation"
        case .fretboardIntervalComparison: return "interval-compare"
        default: return "interval-identify"
        }
    }

    private var questionPrompt: String {
        let prompts: [String: String] = [
            "interval": "请听辨以下音程，选择正确的答案。",
            "chord": "请听辨以下和弦，选择正确的和弦类型。",
            "triad": "请听辨以下三和弦，选择正确的和弦类型。",
            "seventh-chord": "请听辨以下七和弦，选择正确的和弦类型。",
            "chord-inversion": "请听辨以下和弦，判断其转位。",
            "rhythm-hear": "请听辨以下节奏型，选择正确的答案。",
            "melody-dictation": "请先听标准音校准音高，然后听取旋律并记录。",
            "interval-compare": "请比较两个音程，选择哪个更大。",
            "interval-identify": "请听辨音程，选择正确的音程名称。",
        ]
        return prompts[exerciseID] ?? "请听辨音频，选择正确的答案。"
    }

    var body: some View {
        ZStack {
            ExerciseLayout(
                title: exercise.rawValue,
                questionNumber: currentQuestion,
                totalQuestions: totalQuestions,
                questionText: questionPrompt,
                score: score,
                showDecompose: showDecompose,
                onBack: { dismiss() },
                onNewQuestion: handleNewQuestion,
                onDecompose: {
                    playCurrentQuestion()
                },
                onReplay: {
                    playCurrentQuestion()
                }
            ) {
                VStack(spacing: 16) {
                    // 标准音（旋律听写）
                    if exerciseID == "melody-dictation" {
                        ReferenceNoteCard(note: "A", frequency: "440Hz", onPlay: {
                            ExerciseSoundPlayer.playReference()
                        })
                    }

                    // 音频提示卡片
                    AudioPromptCard(
                        label: currentQuestionData.displayContent,
                        hint: currentQuestionData.displayLabel,
                        onPlay: {
                            playCurrentQuestion()
                        }
                    )

                    // 选择题
                    ChoiceList(
                        options: currentQuestionData.options,
                        selectedOption: selectedOption,
                        correctAnswer: currentQuestionData.correctAnswer,
                        showResult: showResult,
                        onSelect: handleSelect,
                        onNext: goNext
                    )
                }
                .padding(.vertical, 16)
            }

            // 完成覆盖层
            if showComplete {
                ExerciseCompletionOverlay(
                    roundNumber: roundNumber,
                    correctCount: correctCount,
                    totalQuestions: totalQuestions,
                    roundResults: roundResults.map { RoundSummaryItem(round: $0.round, correctCount: $0.correctCount, totalQuestions: $0.totalQuestions) },
                    onContinue: handleContinueRound,
                    onBack: { dismiss() }
                )
                .transition(.opacity)
            }
        }
        .onAppear { generateQuestionFromBank() }
    }

    // MARK: - Actions

    private func handleSelect(_ option: String) {
        guard !showResult else { return }
        selectedOption = option
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.2)) { showResult = true }
            if option == currentQuestionData.correctAnswer {
                correctCount += 1
                score += 10
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            } else {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }
        }
    }

    private func goNext() {
        if currentQuestion >= totalQuestions {
            // 记录本轮成绩
            roundResults.append(DetailRoundResult(
                round: roundNumber,
                correctCount: correctCount,
                totalQuestions: totalQuestions
            ))
            withAnimation { showComplete = true }
            return
        }
        selectedOption = nil
        showResult = false
        currentQuestion += 1
        generateQuestionFromBank()
    }

    private func handleNewQuestion() {
        if showResult { goNext() }
    }

    /// 继续下一轮（保留历史记录）
    private func handleContinueRound() {
        roundNumber += 1
        currentQuestion = 1
        correctCount = 0
        score = 0
        selectedOption = nil
        showResult = false
        showComplete = false
        generateQuestionFromBank()
    }

    private func handleRetryRound() {
        roundNumber = 1
        currentQuestion = 1
        correctCount = 0
        score = 0
        selectedOption = nil
        showResult = false
        showComplete = false
        roundResults.removeAll()
        generateQuestionFromBank()
    }

    // MARK: - Demo Data

    private func playCurrentQuestion() {
        switch exerciseID {
        case "interval", "interval-identify":
            guard let q = QuestionBank.intervalQuestions.randomElement() else { return }
            if let interval = MusicTheoryInterval.allCases.first(where: { $0.semitones == q.semitones }) {
                ExerciseSoundPlayer.playInterval(interval)
            }
        case "chord", "triad", "seventh-chord", "chord-inversion":
            let quality = TriadQuality.allCases.randomElement()!
            ExerciseSoundPlayer.playTriadQuality(quality)
        default:
            ExerciseSoundPlayer.playReference()
        }
    }

    private func generateQuestionFromBank() {
        switch exerciseID {
        case "interval", "interval-identify":
            let pool = QuestionBank.intervalQuestions.shuffled().prefix(4)
            let options = pool.map { $0.name }
            let correct = pool.first!
            currentQuestionData = QuestionData(
                displayContent: "点击播放音频",
                displayLabel: "听辨音程",
                options: options,
                correctAnswer: correct.name
            )
        case "chord", "triad", "seventh-chord", "chord-inversion":
            let optionNames = ["大三和弦", "小三和弦", "增三和弦", "减三和弦"]
            let correct = optionNames.randomElement()!
            currentQuestionData = QuestionData(
                displayContent: "点击播放音频",
                displayLabel: "听辨和弦",
                options: optionNames,
                correctAnswer: correct
            )
        case "rhythm-hear", "melody-dictation", "interval-compare":
            if exerciseID == "rhythm-hear" {
                let pool = QuestionBank.rhythmQuestions.shuffled().prefix(4)
                let options = pool.map { $0.name }
                currentQuestionData = QuestionData(
                    displayContent: "点击播放音频",
                    displayLabel: "听辨节奏",
                    options: options,
                    correctAnswer: pool.first?.name ?? ""
                )
            } else {
                let pool = QuestionBank.intervalQuestions.shuffled().prefix(4)
                let options = pool.map { $0.name }
                let correct = pool.first!
                currentQuestionData = QuestionData(
                    displayContent: "点击播放音频",
                    displayLabel: "听辨音程",
                    options: options,
                    correctAnswer: correct.name
                )
            }
        default:
            let pool = QuestionBank.intervalQuestions.shuffled().prefix(4)
            let options = pool.map { $0.name }
            let correct = pool.first!
            currentQuestionData = QuestionData(
                displayContent: "点击播放音频",
                displayLabel: exercise.rawValue,
                options: options,
                correctAnswer: correct.name
            )
        }
    }

    private struct QuestionData {
        let displayContent: String
        let displayLabel: String
        let options: [String]
        let correctAnswer: String
    }
}

// MARK: - 预览

#Preview {
    NavigationStack {
        ExerciseDetailView(
            exercise: .intervalRecognition,
            module: .interval,
            viewModel: PracticeViewModel()
        )
    }
}
