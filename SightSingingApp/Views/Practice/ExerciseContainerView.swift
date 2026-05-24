import SwiftUI

// MARK: - 练习容器视图 (匹配 v0 ExerciseContainer)

struct ExerciseContainerView: View {
    let exercise: ExerciseItem
    let moduleId: String

    @Environment(\.dismiss) private var dismiss

    @State private var currentQuestion = 1
    @State private var correctCount = 0
    @State private var isCompleted = false

    // PracticeSession — 统一练习会话
    @State private var session = PracticeSession(exerciseType: .theoryQuiz, totalQuestions: 0)

    // 多轮练习追踪
    @State private var roundNumber = 1                    // 当前轮次（从1开始）
    @State private var roundResults: [RoundResult] = []   // 每轮成绩记录

    /// 单轮成绩记录
    struct RoundResult: Identifiable {
        let id = UUID()
        let round: Int
        let correctCount: Int
        let totalQuestions: Int
        var accuracy: Int { Int(Double(correctCount) / Double(totalQuestions) * 100) }
    }

    // 选择题状态
    @State private var selectedOption: String?
    @State private var showResult = false

    // 键盘输入状态
    @State private var inputNotes: [String] = []
    @State private var keyboardAccidental: String = "—"

    // 视唱状态
    @State private var sightSingingPhase: SightSingingPhase = .idle
    @State private var currentCents: Double = 0
    @State private var pitchScore: Int = 0
    @State private var rhythmScore: Int = 0

    enum SightSingingPhase {
        case idle, singing, done
    }

    // 题目数据（从 QuestionBank 按需生成）
    @State private var currentQuestionData: ExerciseQuestionData?
    @State private var currentCorrectAnswer: String = ""
    
    struct ExerciseQuestionData {
        let options: [String]           // 选项列表
        let correctAnswer: String       // 正确答案
        let audioText: String           // 音频播放文本（如音名）
        let displayHint: String         // 提示文字
    }

    private var totalQuestions: Int { exercise.totalQuestions }

    /// 将当前 exercise mode 映射为 PracticeSession 类型
    private var exerciseTypeForSession: PracticeSession.ExerciseType {
        switch exercise.mode {
        case .sightSinging: return .sightSinging
        case .multipleChoice: return .theoryQuiz
        case .keyboardInput: return .singleNoteListening
        }
    }

    /// 累计统计（所有轮次合计）
    private var totalCorrectOverall: Int { roundResults.reduce(0) { $0 + $1.correctCount } }
    private var totalQuestionsOverall: Int { roundResults.count * totalQuestions }
    private var averageAccuracy: Int {
        guard !roundResults.isEmpty else { return 0 }
        return roundResults.reduce(0) { $0 + $1.accuracy } / roundResults.count
    }
    /// 最佳轮次正确率
    private var bestRoundAccuracy: Int {
        roundResults.map(\.accuracy).max() ?? 0
    }

    // MARK: - Body (匹配 v0 ExerciseContainer 结构)

    var body: some View {
        VStack(spacing: 0) {
            // 导航栏 (匹配 v0 NavBar)
            navBar

            // 内容区域 (匹配 v0: flex-1 px-4 overflow-auto)
            if isCompleted {
                ExerciseCompletionView(
                    roundNumber: roundNumber,
                    correctCount: correctCount,
                    totalQuestions: totalQuestions,
                    roundResults: roundResults,
                    averageAccuracy: averageAccuracy,
                    bestRoundAccuracy: bestRoundAccuracy,
                    onContinue: continueToNextRound,
                    onBack: { dismiss() }
                )
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // 根据模式渲染不同内容
                        switch exercise.mode {
                        case .multipleChoice:
                            if let q = currentQuestionData {
                                MultipleChoiceContent(
                                    options: q.options,
                                    selectedOption: $selectedOption,
                                    showResult: $showResult,
                                    correctAnswer: q.correctAnswer,
                                    onAnswer: { answer in
                                        if answer == q.correctAnswer {
                                            correctCount += 1
                                            session.submitAnswer(isCorrect: true)
                                            ExperienceEngine.shared.onUserAction(.noteCorrect(deviation: 0))
                                        } else {
                                            session.submitAnswer(isCorrect: false)
                                            ExperienceEngine.shared.onUserAction(.noteMissed)
                                        }
                                        selectedOption = answer
                                        showResult = true
                                    },
                                    onPlay: { playCurrentExerciseAudio() },
                                    onNext: { nextQuestion() }
                                )
                            }

                        case .keyboardInput:
                            KeyboardInputContent(
                                inputNotes: $inputNotes,
                                accidental: $keyboardAccidental,
                                notationType: NotationPreferences.shared.preferredNotation.rawValue,
                                correctAnswer: currentCorrectAnswer,
                                onSubmit: { isCorrect in
                                    if isCorrect {
                                        correctCount += 1
                                        session.submitAnswer(isCorrect: true)
                                        ExperienceEngine.shared.onUserAction(.noteCorrect(deviation: 0))
                                    } else {
                                        session.submitAnswer(isCorrect: false)
                                        ExperienceEngine.shared.onUserAction(.noteMissed)
                                    }
                                },
                                onReplay: { playCurrentExerciseAudio() }
                            )

                        case .sightSinging:
                            SightSingingContent(
                                phase: $sightSingingPhase,
                                cents: $currentCents,
                                targetNote: currentCorrectAnswer,
                                onComplete: { p, r in
                                    pitchScore = p
                                    rhythmScore = r
                                    correctCount += 1
                                    session.submitAnswer(isCorrect: true, timingAccuracy: r, pitchAccuracy: p)
                                    let accuracy = Double(r) / 100.0
                                    ExperienceEngine.shared.onUserAction(.rhythmOnBeat(accuracy: accuracy))
                                },
                                onPlayDemo: { playCurrentExerciseAudio() }
                            )
                        }
                    }
                    .padding(16)
                }
            }

            // 底部操作栏 (匹配 v0: border-t border-border bg-card + mb spacing)
            if !isCompleted {
                bottomActionBar
            }
        }
        .background(AppTheme.background)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            session = PracticeSession(
                exerciseType: exerciseTypeForSession,
                totalQuestions: totalQuestions
            )
            session.start()
            generateNewQuestion()
        }
    }

    // MARK: - 导航栏 (匹配 v0 NavBar: iOS 模糊 + 居中标题 + 右侧分数)

    private var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                    Text("返回")
                        .font(.system(size: 17))
                }
                .foregroundStyle(AppTheme.accent)
            }

            Spacer()

            Text(exercise.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.primaryText)
                .lineLimit(1)

            Spacer()

            // 右侧分数
            Text("\(max(0, correctCount * 10)) 分")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.accent)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    // MARK: - 底部操作栏 (匹配 v0 ExerciseLayout: border-t border-border bg-card + 纯文字按钮)
    
    private var bottomActionBar: some View {
        HStack {
            // 新问题 (左对齐)
            Button(action: { nextQuestion() }) {
                Text("新问题")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
            }
            .buttonStyle(.plain)

            Spacer()

            // 分解 (居中，如果有)
            if exercise.mode.showDecompose {
                Button(action: { playCurrentExerciseAudio() }) {
                    Text("分解")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.accent)
                }
                .buttonStyle(.plain)

                Spacer()
            }

            // 重听/示范 (右对齐)
            Button(action: { playCurrentExerciseAudio() }) {
                Text(exercise.mode == .sightSinging ? "示范" : "重听")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)  // bg-card
        .overlay(Rectangle().fill(AppTheme.border).frame(height: 0.5), alignment: .top)  // border-t
    }

    private func playCurrentExerciseAudio() {
        guard let qd = currentQuestionData else { return }
        switch exercise.mode {
        case .multipleChoice:
            playMultipleChoiceAudio(correctName: qd.correctAnswer)
        case .keyboardInput:
            ExerciseSoundPlayer.playStandardSequence(noteName: currentCorrectAnswer)
        case .sightSinging:
            ExerciseSoundPlayer.playNote(name: currentCorrectAnswer)
        }
    }

    /// 根据正确答案名称精确播放对应音程/和弦（确保声音与选项一致）
    private func playMultipleChoiceAudio(correctName: String) {
        let isIntervalModule = moduleId.contains("interval") || exercise.id.contains("interval")
        let isChordModule = moduleId.contains("chord") || exercise.id.contains("chord") || exercise.id.contains("triad")
        let isRhythmModule = moduleId.contains("rhythm") || exercise.id.contains("rhythm") || exercise.id.contains("quarter") || exercise.id.contains("sixteenth") || exercise.id.contains("syncopation") || exercise.id.contains("triplet") || exercise.id.contains("strumming")

        if isIntervalModule {
            // 从正确名称反查对应的 IntervalQuestion → 播放
            // 特殊处理："增四减五度"在 QuestionBank 中存为 "增四度"/"减五度"，按 semitones=6 匹配
            let target: IntervalQuestion?
            if correctName == "增四减五度" {
                target = QuestionBank.intervalQuestions.first { $0.semitones == 6 }
            } else {
                target = QuestionBank.intervalQuestions.first { $0.name == correctName }
            }
            if let intervalQ = target,
               let interval = MusicTheoryInterval.allCases.first(where: { $0.semitones == intervalQ.semitones }) {
                ExerciseSoundPlayer.playInterval(interval)
            } else {
                // 兜底：按名称模糊匹配
                ExerciseSoundPlayer.fallbackPlayInterval(named: correctName)
            }
        } else if isChordModule {
            // 根据和弦名播放对应和弦（支持转位）
            ExerciseSoundPlayer.playChordNamed(correctName)
        } else if isRhythmModule {
            // 节奏：播放标准音 + 基础拍点提示（P2 改进）
            ExerciseSoundPlayer.playRhythmHint()
        } else {
            // 其他类型静默处理
        }
    }

    // MARK: - QuestionBank Integration

    private func generateNewQuestion() {
        switch exercise.mode {
        case .multipleChoice:
            generateMultipleChoiceQuestion()
        case .keyboardInput:
            generateKeyboardInputQuestion()
        case .sightSinging:
            generateSightSingingQuestion()
        }
    }

    private func generateMultipleChoiceQuestion() {
        // 根据 moduleId 挑选合适题库
        let isIntervalModule = moduleId.contains("interval") || exercise.id.contains("interval")
        let isChordModule = moduleId.contains("chord") || exercise.id.contains("chord") || exercise.id.contains("triad")
        let isRhythmModule = moduleId.contains("rhythm") || exercise.id.contains("rhythm") || exercise.id.contains("quarter") || exercise.id.contains("sixteenth") || exercise.id.contains("syncopation") || exercise.id.contains("triplet") || exercise.id.contains("strumming")

        if isIntervalModule {
            generateIntervalQuestion()
        } else if isChordModule {
            generateChordQuestion()
        } else if isRhythmModule {
            generateRhythmQuestion()
        } else {
            // 默认：音程题（带 levelItems 约束）
            generateIntervalQuestion()
        }
    }

    // MARK: - 音程题目生成（使用 levelItems 约束）
    private func generateIntervalQuestion() {
        let allowedItems = exercise.levelItems

        if !allowedItems.isEmpty {
            // 有 levelItems 约束 → 从约束项中生成选项
            let options = buildMappedOptions(allowedItems, from: .interval)
            let correct = options.randomElement() ?? options.first!
            currentQuestionData = ExerciseQuestionData(
                options: options,
                correctAnswer: correct,
                audioText: correct,
                displayHint: "听辨音程"
            )
            currentCorrectAnswer = correct
        } else {
            // 无约束 → 从全局题库随机取
            let pool = QuestionBank.intervalQuestions.shuffled().prefix(4)
            let options = pool.map { $0.name }
            let correct = pool.first!
            currentQuestionData = ExerciseQuestionData(
                options: options,
                correctAnswer: correct.name,
                audioText: correct.shortName,
                displayHint: "听辨音程"
            )
            currentCorrectAnswer = correct.name
        }
    }

    // MARK: - 和弦题目生成（使用 levelItems 约束）
    private func generateChordQuestion() {
        let allowedItems = exercise.levelItems

        if !allowedItems.isEmpty {
            let options = buildMappedOptions(allowedItems, from: .chord)
            let correct = options.randomElement() ?? options.first!
            currentQuestionData = ExerciseQuestionData(
                options: options,
                correctAnswer: correct,
                audioText: correct,
                displayHint: "听辨和弦"
            )
            currentCorrectAnswer = correct
        } else {
            let optionNames = ["大三和弦", "小三和弦", "增三和弦", "减三和弦"]
            let correct = optionNames.randomElement()!
            currentQuestionData = ExerciseQuestionData(
                options: optionNames,
                correctAnswer: correct,
                audioText: correct,
                displayHint: "听辨和弦"
            )
            currentCorrectAnswer = correct
        }
    }

    // MARK: - 节奏题目生成（使用 levelItems 约束）
    private func generateRhythmQuestion() {
        let allowedItems = exercise.levelItems

        if !allowedItems.isEmpty {
            let options = buildMappedOptions(allowedItems, from: .rhythm)
            let correct = options.randomElement() ?? options.first!
            currentQuestionData = ExerciseQuestionData(
                options: options,
                correctAnswer: correct,
                audioText: correct,
                displayHint: "识别节奏型"
            )
            currentCorrectAnswer = correct
        } else {
            let patternNames = ["四分音符", "八分音符", "四分+八分", "附点节奏", "切分节奏"]
            let correct = patternNames.randomElement()!
            currentQuestionData = ExerciseQuestionData(
                options: patternNames.shuffled(),
                correctAnswer: correct,
                audioText: correct,
                displayHint: "识别节奏型"
            )
            currentCorrectAnswer = correct
        }
    }

    // MARK: - LevelItem 名称映射为 QuestionBank 实际名称

    private enum QuestionType { case interval, chord, rhythm }

    /// 将 LevelDataProvider 的简写名称映射为 QuestionBank 的完整名称
    private func buildMappedOptions(_ items: [String], from type: QuestionType) -> [String] {
        var mapped: [String]

        switch type {
        case .interval:
            let nameMap: [String: String] = [
                "纯一度": "纯一度",
                "小二度": "小二度",
                "大二度": "大二度",
                "小三度": "小三度",
                "大三度": "大三度",
                "纯四度": "纯四度",
                // 增四减五度 → 统一映射为"增四减五度"（与 MusicTheoryInterval.chineseName 对齐）
                // QuestionBank 中同时存在"增四度"和"减五度"，播放时按 semitones=6 查找即可
                "增四减五度": "增四减五度",
                "纯五度": "纯五度",
                "小六度": "小六度",
                "大六度": "大六度",
                "小七度": "小七度",
                "大七度": "大七度",
                "纯八度": "纯八度",
            ]
            mapped = items.compactMap { nameMap[$0] ?? $0 }

        case .chord:
            // 转位和弦保留独立名称，不再坍塌
            let nameMap: [String: String] = [
                "大三": "大三和弦",
                "小三": "小三和弦",
                "减三": "减三和弦",
                "增三": "增三和弦",
                // 转位：保留独立名称，与播放端 playChordNamed 配合
                "大三原位": "大三原位和弦",
                "大三一转": "大三一转和弦(六和弦)",
                "大三大转": "大三大转和弦(四六和弦)",
                "小三原位": "小三原位和弦",
                "小三一转": "小三一转和弦(六和弦)",
                "小三六转": "小三六转和弦(四六和弦)",
                "大六": "大六和弦",
                "小六": "小六和弦",
            ]
            mapped = items.compactMap { nameMap[$0] ?? $0 }

        case .rhythm:
            // 节奏 items → 直观的中文显示名
            let nameMap: [String: String] = [
                "X": "四分音符",
                "x": "八分音符",
                "-": "休止符",
                "0": "空拍",
                ">": "重音",
                "X x": "四分+八分",
                "x X": "八分+四分",
                "xxxx": "四个十六分",
                "x xx": "八分+两个十六分",
                "xx x": "两个十六分+八分",
                "X.xx": "附点四分+十六分×2",
                "x.XX": "附点八分+四分×2",
                "x x.x": "十六分切分",
                "x X.xx": "八分+附点组合",
                "(xxx)": "三连音",
                "X (xxx)": "四分+三连音",
                "(xxx) X": "三连音+四分",
                "(xxx)(xxx)": "连续三连音",
                "(xx-)": "三连音休止(前两音)",
                "(-xx)": "三连音休止(后两音)",
                "↓↑↓↑": "下上下上扫弦",
                "↓↓↓↑": "下下下上扫弦",
                "↓↓↑↓": "下下上下扫弦",
                "↓↑↓↓": "下上下下扫弦",
                "分解T323": "分解 T323",
                "分解T1323": "分解 T1323",
                "分解532123": "分解 532123",
                "分解135313": "分解 135313",
                "123": "1-2-3 上行",
                "234": "2-3-4 上行",
                "345": "3-4-5 上行",
                "456": "4-5-6 上行",
                "135": "1-3-5 分解",
                "351": "3-5-1 分解",
                "531": "5-3-1 下行",
                "132": "1-3-2 混合",
                "143": "1-4-3 混合",
                "356": "3-5-6 混合",
                "653": "6-5-3 下行混合",
                "#123": "#1-2-3 升号",
                "4#56": "4-#5-6 升号",
                "高1高2高3": "高音区上行",
                "低5低6低7": "低音区下行",
                // 音阶/和弦进行名称直接使用
            ]
            mapped = items.compactMap { nameMap[$0] ?? $0 }
        }

        // 去重
        mapped = mapped.removingDuplicates()

        // 如果不足4个选项，从对应题库中补充
        while mapped.count < 4 {
            let extra: String?
            switch type {
            case .interval:
                extra = QuestionBank.intervalQuestions
                    .filter { !mapped.contains($0.name) }.randomElement()?.name
            case .chord:
                extra = ["大三和弦","小三和弦","减三和弦","增三和弦","大六和弦","小六和弦",
                         "大三原位和弦","大三一转和弦(六和弦)","大三大转和弦(四六和弦)",
                         "小三原位和弦","小三一转和弦(六和弦)","小三六转和弦(四六和弦)"]
                    .filter { !mapped.contains($0) }.randomElement()
            case .rhythm:
                extra = ["四分音符","八分音符","附点节奏","切分节奏","三连音","十六分音符",
                         "四分+八分","八分+休止","重音","四个十六分","下上下上扫弦","分解T323"]
                    .filter { !mapped.contains($0) }.randomElement()
            }
            if let e = extra { mapped.append(e) } else { break }
        }

        return mapped.shuffled()
    }

    private func generateKeyboardInputQuestion() {
        guard let q = QuestionBank.noteNameQuestions.randomElement() else { return }
        currentCorrectAnswer = "\(q.noteName)\(q.octave)"
    }

    private func generateSightSingingQuestion() {
        let allowedItems = exercise.levelItems

        if !allowedItems.isEmpty {
            // 有 levelItems 约束 → 从约束项中随机选
            // 支持多种格式：简谱数字("1","2","3")、音名("C4")、描述性名称("C大调上行")
            let target = allowedItems.randomElement()!
            currentCorrectAnswer = target
        } else {
            // 无约束 → 默认 C4-B4 范围随机
            let notes = ["C4", "D4", "E4", "F4", "G4", "A4", "B4", "C5"]
            currentCorrectAnswer = notes.randomElement()!
        }
    }

    // MARK: - Actions

    private func nextQuestion() {
        if currentQuestion >= totalQuestions {
            // 记录本轮成绩
            roundResults.append(RoundResult(
                round: roundNumber,
                correctCount: correctCount,
                totalQuestions: totalQuestions
            ))
            // 完成练习会话
            session.finish()
            let accuracy = Double(correctCount) / Double(totalQuestions)
            ExperienceEngine.shared.onUserAction(.practiceCompleted(accuracy: accuracy))
            withAnimation {
                isCompleted = true
            }
        } else {
            currentQuestion += 1
            session.nextQuestion()
            resetQuestionState()
        }
    }

    private func resetQuestionState() {
        selectedOption = nil
        showResult = false
        inputNotes = []
        keyboardAccidental = "—"
        sightSingingPhase = .idle
        currentCents = 0
        generateNewQuestion()
    }

    /// 继续下一轮练习（保留历史轮次记录）
    private func continueToNextRound() {
        roundNumber += 1
        currentQuestion = 1
        correctCount = 0
        pitchScore = 0
        rhythmScore = 0
        isCompleted = false
        session = PracticeSession(exerciseType: exerciseTypeForSession, totalQuestions: totalQuestions)
        session.start()
        resetQuestionState()
    }

    /// 完全重置（清空所有轮次记录，重新从第1轮开始）
    private func resetExercise() {
        roundNumber = 1
        correctCount = 0
        isCompleted = false
        roundResults.removeAll()
        session = PracticeSession(exerciseType: exerciseTypeForSession, totalQuestions: totalQuestions)
        session.start()
        resetQuestionState()
    }
}

// MARK: - 选择题内容 (匹配 v0 MultipleChoice)

struct MultipleChoiceContent: View {
    let options: [String]
    @Binding var selectedOption: String?
    @Binding var showResult: Bool
    let correctAnswer: String
    let onAnswer: (String) -> Void
    let onPlay: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // 音频卡片
            AudioPromptCard(
                label: "点击播放音频",
                hint: "仔细聆听后选择正确答案",
                onPlay: onPlay
            )

            // 选项列表 (匹配 v0 ChoiceList)
            VStack(spacing: 0) {
                HStack {
                    Text("请选择")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.secondaryText)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppTheme.secondaryBg.opacity(0.5))

                VStack(spacing: 0) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        let isSelected = selectedOption == option
                        let isCorrect = showResult && option == correctAnswer
                        let isWrong = showResult && isSelected && option != correctAnswer

                        Button {
                            if !showResult {
                                onAnswer(option)
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
                            Rectangle()
                                .fill(AppTheme.border)
                                .frame(height: 1)
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

            // 下一题按钮
            if showResult {
                Button {
                    onNext()
                } label: {
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

// MARK: - 键盘输入内容 (匹配 v0 ExerciseContainer 简版 MusicKeyboard)

struct KeyboardInputContent: View {
    @Binding var inputNotes: [String]
    @Binding var accidental: String
    let notationType: String
    let correctAnswer: String
    let onSubmit: (Bool) -> Void
    let onReplay: () -> Void

    @State private var isSubmitted = false
    @State private var isCorrect = false
    @State private var selectedAccidental: String? = nil

    private let notes = ["C", "D", "E", "F", "G", "A", "B"]

    var body: some View {
        VStack(spacing: 16) {
            // 已输入音符显示 (匹配 v0: secondary bg rounded-xl + 蓝色标签)
            HStack(spacing: 8) {
                if inputNotes.isEmpty {
                    Text("请输入音符...")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.secondaryText)
                } else {
                    ForEach(Array(inputNotes.enumerated()), id: \.offset) { _, note in
                        Text(note)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppTheme.secondaryBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // 升降号按钮 (匹配 v0: # / b 两个，48x48，圆角 12px)
            HStack(spacing: 8) {
                Button {
                    selectedAccidental = selectedAccidental == "sharp" ? nil : "sharp"
                } label: {
                    Text("♯")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(selectedAccidental == "sharp" ? .white : AppTheme.primaryText)
                        .frame(width: 48, height: 48)
                        .background(selectedAccidental == "sharp" ? AppTheme.accent : AppTheme.secondaryBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(isSubmitted)

                Button {
                    selectedAccidental = selectedAccidental == "flat" ? nil : "flat"
                } label: {
                    Text("♭")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(selectedAccidental == "flat" ? .white : AppTheme.primaryText)
                        .frame(width: 48, height: 48)
                        .background(selectedAccidental == "flat" ? AppTheme.accent : AppTheme.secondaryBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(isSubmitted)

                Spacer()
            }

            // 音符键盘 (匹配 v0: 7 列一行，h-14 bg-primary rounded-xl)
            HStack(spacing: 6) {
                ForEach(notes, id: \.self) { note in
                    Button {
                        if !isSubmitted {
                            var fullNote = note
                            if selectedAccidental == "sharp" { fullNote += "♯" }
                            if selectedAccidental == "flat" { fullNote += "♭" }
                            inputNotes.append(fullNote)
                            selectedAccidental = nil
                        }
                    } label: {
                        Text(note)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(isSubmitted ? AppTheme.tertiaryText : AppTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(IOSPressStyle())
                    .disabled(isSubmitted)
                }
            }

            // 功能按钮 (匹配 v0: grid-cols-3 gap-3)
            HStack(spacing: 8) {
                Button {
                    if !isSubmitted {
                        inputNotes.removeAll()
                    }
                } label: {
                    Text("清空")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(AppTheme.secondaryBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(IOSPressStyle())
                .disabled(isSubmitted)

                Button {
                    if !inputNotes.isEmpty && !isSubmitted {
                        isSubmitted = true
                        isCorrect = inputNotes.joined() == correctAnswer
                        onSubmit(isCorrect)
                    }
                } label: {
                    Text("确认")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(IOSPressStyle())
                .disabled(inputNotes.isEmpty || isSubmitted)

                Button {
                    onReplay()
                } label: {
                    Text("重听")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(AppTheme.secondaryBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(IOSPressStyle())
            }
        }
    }
}

// MARK: - 视唱内容 (严格匹配 v0 SightSingingView: PitchMeter圆形卡片 + SingButton圆形)

struct SightSingingContent: View {
    @Binding var phase: ExerciseContainerView.SightSingingPhase
    @Binding var cents: Double
    let targetNote: String
    let onComplete: (Int, Int) -> Void
    let onPlayDemo: () -> Void

    @State private var timer: Timer?

    private var cursorColor: Color {
        if phase == .idle { return AppTheme.tertiaryText }
        let absCents = abs(cents)
        if absCents <= 10 { return AppTheme.success }
        if absCents <= 20 { return AppTheme.warning }
        return AppTheme.error
    }

    private var isAccurate: Bool { abs(cents) <= 10 && phase == .singing }

    var body: some View {
        VStack(spacing: 20) {
            // === v0 PitchMeter 卡片 ===
            VStack(spacing: 16) {
                Text("目标音符")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.secondaryText)

                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.1))
                        .frame(width: 96, height: 96)
                    Text(targetNote)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                }

                Text(phase == .singing ? "正在聆听..." : "请唱出此音")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.secondaryText)

                pitchMeterBar

                HStack {
                    Text("-50").font(.system(size: 12)).foregroundStyle(AppTheme.tertiaryText)
                    Spacer()
                    Text("准").font(.system(size: 12, weight: .medium)).foregroundStyle(AppTheme.success)
                    Spacer()
                    Text("+50").font(.system(size: 12)).foregroundStyle(AppTheme.tertiaryText)
                }

                feedbackArea
            }
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))  // rounded-2xl
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.border, lineWidth: 0.5))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)

            // === v0 SingButton 圆形按钮 ===
            VStack(spacing: 8) {
                Button {
                    if phase == .idle { startSinging() }
                    else { stopSinging() }
                } label: {
                    ZStack {
                        if phase == .singing {
                            Circle().fill(AppTheme.error.opacity(0.3)).frame(width: 96, height: 96)
                            Circle().stroke(AppTheme.error.opacity(0.5), lineWidth: 2).frame(width: 104, height: 104)
                        }
                        Circle()
                            .fill(phase == .singing ? AppTheme.error : AppTheme.accent)
                            .frame(width: 80, height: 80)
                            .shadow(color: (phase == .singing ? AppTheme.error : AppTheme.accent).opacity(0.3), radius: phase == .singing ? 8 : 4)
                        Image(systemName: phase == .singing ? "stop.fill" : "mic.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(IOSPressStyle())
                Text(phase == .singing ? "松开结束" : "按住演唱")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(phase == .singing ? AppTheme.error : AppTheme.secondaryText)
            }
        }
        .padding(.horizontal, 16)
    }

    private var pitchMeterBar: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(AppTheme.mutedBackground).frame(height: 8)
                Capsule().fill(AppTheme.success.opacity(0.3)).frame(width: w / 5, height: 8).position(x: w / 2, y: 4)
                Rectangle().fill(AppTheme.success).frame(width: 1, height: 8).position(x: w / 2, y: 4)
                if phase != .idle {
                    let pos = max(0, min(1, (cents / 50 + 1) / 2))
                    Circle()
                        .fill(cursorColor).frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(color: cursorColor.opacity(0.4), radius: 4)
                        .position(x: pos * w, y: 4)
                }
            }
        }
        .frame(height: 24)
    }

    private var feedbackArea: some View {
        Group {
            if phase == .idle {
                Text("按住下方按钮开始演唱").font(.system(size: 15)).foregroundStyle(AppTheme.secondaryText)
            } else if isAccurate {
                HStack(spacing: 6) {
                    Circle().fill(AppTheme.success).frame(width: 8, height: 8)
                    Text("音准良好!").font(.system(size: 17, weight: .semibold)).foregroundStyle(AppTheme.success)
                }
            } else if cents < 0 {
                HStack(spacing: 4) {
                    Text("偏低").font(.system(size: 15)).foregroundStyle(AppTheme.warning)
                    Text("\(abs(Int(cents)))").font(.system(size: 17, weight: .bold)).foregroundStyle(AppTheme.warning)
                    Text("音分").font(.system(size: 15)).foregroundStyle(AppTheme.warning)
                }
            } else {
                HStack(spacing: 4) {
                    Text("偏高").font(.system(size: 15)).foregroundStyle(AppTheme.error)
                    Text("\(Int(cents))").font(.system(size: 17, weight: .bold)).foregroundStyle(AppTheme.error)
                    Text("音分").font(.system(size: 15)).foregroundStyle(AppTheme.error)
                }
            }
        }
        .padding(.vertical, 12).padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background((phase != .idle) ? AppTheme.mutedBackground : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func startSinging() {
        phase = .singing
        var tick = 0
        let totalTicks = 30
        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            tick += 1
            let progress = Double(tick) / Double(totalTicks)
            let convergence = sin(progress * .pi * 0.7)
            let noiseRange: Double = 35.0 * (1.0 - progress)
            cents = convergence * Double.random(in: -noiseRange...noiseRange)
            if tick >= totalTicks {
                stopSinging()
            }
        }
    }

    private func stopSinging() {
        timer?.invalidate()
        timer = nil
        phase = .done
        let absCents = abs(cents)
        let pitch = max(0, 50 - Int(absCents))
        let rhythm = Int.random(in: 35...50)
        onComplete(pitch, rhythm)
    }
    
    /// 根据音名动态计算唱名 (如 "C4" → "Do · 4", "E4" → "Mi · 3")
    private func solfegeName(for note: String) -> String {
        let noteToSolfege = [
            "C": "Do", "D": "Re", "E": "Mi", "F": "Fa",
            "G": "Sol", "A": "La", "B": "Si"
        ]
        
        // 提取音名和八度
        let name = String(note.prefix(1).uppercased())
        var octaveStr = ""
        if note.count > 1 {
            octaveStr = String(note.dropFirst())
        }
        
        let solfege = noteToSolfege[name] ?? name
        if !octaveStr.isEmpty, let octave = Int(octaveStr) {
            return "\(solfege) · \(octave)"
        }
        return solfege
    }
}

// MARK: - 练习总结视图（每组10题完成后展示，支持多轮连续练习）

struct ExerciseCompletionView: View {
    let roundNumber: Int
    let correctCount: Int
    let totalQuestions: Int
    let roundResults: [ExerciseContainerView.RoundResult]
    let averageAccuracy: Int
    let bestRoundAccuracy: Int
    let onContinue: () -> Void
    let onBack: () -> Void

    private var accuracy: Int {
        Int((Double(correctCount) / Double(totalQuestions)) * 100)
    }

    private var gradeEmoji: String {
        if accuracy >= 90 { return "🎉" }
        if accuracy >= 70 { return "👏" }
        if accuracy >= 50 { return "💪" }
        return "📚"
    }

    private var gradeTitle: String {
        if accuracy >= 90 { return "表现出色！" }
        if accuracy >= 70 { return "做得不错！" }
        if accuracy >= 50 { return "继续加油！" }
        return "多多练习！"
    }

    /// 根据正确率返回颜色
    private func colorForAccuracy(_ acc: Int) -> Color {
        if acc >= 90 { return AppTheme.success }
        if acc >= 70 { return AppTheme.accent }
        if acc >= 50 { return AppTheme.warning }
        return AppTheme.error
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 16)

                // === 本轮结果头部 ===
                Text(gradeEmoji)
                    .font(.system(size: 48))

                Text(gradeTitle)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)

                // 轮次标签
                Text("第 \(roundNumber) 轮")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(AppTheme.secondaryBg)
                    .clipShape(Capsule())

                // === 本轮成绩卡片 ===
                HStack(spacing: 24) {
                    VStack(spacing: 6) {
                        Text("\(correctCount)/\(totalQuestions)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(AppTheme.success)
                        Text("答对题数")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    Rectangle()
                        .fill(AppTheme.border)
                        .frame(width: 1, height: 56)

                    VStack(spacing: 6) {
                        Text("\(accuracy)%")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(colorForAccuracy(accuracy))
                        Text("正确率")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)

                // === 历史轮次汇总（有2轮以上才显示）===
                if roundResults.count > 1 {
                    historySummarySection
                }

                // === 操作按钮 ===
                VStack(spacing: 12) {
                    // 主要操作：继续下一轮
                    Button(action: onContinue) {
                        HStack(spacing: 6) {
                            Text("继续练习")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(IOSPressStyle())

                    // 次要操作：返回
                    Button(action: onBack) {
                        Text("结束练习，返回")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(AppTheme.primaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppTheme.secondaryBg)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(IOSPressStyle())
                }

                Spacer()
            }
            .padding(16)
        }
    }

    // MARK: - 历史轮次汇总区域

    @ViewBuilder
    private var historySummarySection: some View {
        VStack(spacing: 14) {
            // 汇总标题行
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.accent)
                Text("已练 \(roundResults.count) 轮 · 累计统计")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
            }

            // 三项汇总指标
            HStack(spacing: 12) {
                summaryCard(
                    title: "平均正确率",
                    value: "\(averageAccuracy)%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: averageAccuracy >= 70 ? AppTheme.accent : AppTheme.warning
                )
                summaryCard(
                    title: "最佳单轮",
                    value: "\(bestRoundAccuracy)%",
                    icon: "trophy.fill",
                    color: AppTheme.success
                )
                summaryCard(
                    title: "总答题数",
                    value: "\(roundResults.count * totalQuestions)",
                    icon: "list.bullet",
                    color: AppTheme.secondaryText
                )
            }

            // 各轮成绩条形图
            VStack(spacing: 8) {
                ForEach(roundResults) { result in
                    HStack(spacing: 10) {
                        Text("第\(result.round)轮")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.secondaryText)
                            .frame(width: 44, alignment: .trailing)

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // 背景轨道
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppTheme.mutedBackground)
                                    .frame(height: 16)

                                // 填充进度
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(colorForAccuracy(result.accuracy).opacity(0.8))
                                    .frame(
                                        width: max(4, geometry.size.width * Double(result.accuracy) / 100),
                                        height: 16
                                    )

                                // 百分比文字
                                Text("\(result.accuracy)%")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .offset(x: min(
                                        geometry.size.width * Double(result.accuracy) / 100 - 18,
                                        geometry.size.width - 36
                                    ), y: 0)
                            }
                        }
                        .frame(height: 16)
                    }
                }
            }
            .padding(14)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border.opacity(0.5), lineWidth: 0.5))
        }
        .padding(16)
        .background(AppTheme.secondaryBg.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    /// 汇总小卡片
    private func summaryCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.primaryText)
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.secondaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - 预览

#Preview {
    ExerciseContainerView(
        exercise: ExerciseItem(id: "chord-hear", title: "和弦辨认", mode: .multipleChoice, percentage: 30),
        moduleId: "hearing"
    )
}
