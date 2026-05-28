import SwiftUI

// MARK: - 单音辨认练习页 (匹配 v0 single-note-exercise)

struct SingleNoteListeningView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var notationPrefs = NotationPreferences.shared

    private let totalQuestions = 10

    @State private var currentQuestion = 1
    @State private var inputNotes: [String] = []
    @State private var currentAccidental = ""
    @State private var score = 0
    @State private var correctCount = 0
    @State private var answerState: AnswerState = .idle
    @State private var showNext = false
    @State private var showComplete = false
    @State private var currentAnswer: NoteNameQuestion?

    // PracticeSession — 统一练习会话
    @State private var session = PracticeSession(
        exerciseType: .singleNoteListening,
        totalQuestions: 10
    )

    // 多轮练习追踪
    @State private var roundNumber = 1
    @State private var roundResults: [SingleRoundResult] = []

    /// 单轮成绩记录（SingleNoteListeningView 专用）
    struct SingleRoundResult: Identifiable {
        let id = UUID()
        let round: Int
        let correctCount: Int
        let totalQuestions: Int
        var accuracy: Int { Int(Double(correctCount) / Double(totalQuestions) * 100) }
    }

    enum AnswerState {
        case idle, correct, wrong
    }

    var body: some View {
        ZStack {
            ExerciseLayout(
                title: "单音辨认",
                questionNumber: currentQuestion,
                totalQuestions: totalQuestions,
                questionText: "请问演奏了哪个单音? 第一个音为标准音 (无须录入)。",
                score: score,
                scoreLabel: "\(score)/\(currentQuestion * 10) 分",
                showDecompose: false,
                onBack: { dismiss() },
                onNewQuestion: handleNewQuestion,
                onReplay: handleReplay,
                replayLabel: "重听"
            ) {
                VStack(spacing: 12) {
                    // 谱式展示
                    if notationPrefs.preferredNotation == .staff {
                        StaffNotationDisplay(inputNotes: inputNotes, feedback: answerState)
                    } else {
                        TabSolfegeDisplay(
                            inputNotes: inputNotes,
                            feedback: answerState,
                            correctNote: answerState == .wrong ? currentAnswer?.noteName : nil
                        )
                    }

                    // 提交后的正确/错误反馈
                    if answerState != .idle {
                        let attempted = currentQuestion
                        let accuracy = attempted > 0 ? Int(Double(correctCount) / Double(attempted) * 100) : 0
                        HStack(spacing: 6) {
                            Text(answerState == .correct ? "🤩" : "😅")
                            Text(answerState == .correct ? "正确。" : "不正确。")
                                .font(.system(size: 15, weight: .medium))
                            Text("今天的正确率是 \(accuracy)%。")
                                .font(.system(size: 15))
                        }
                        .foregroundStyle(answerState == .correct ? AppTheme.success : AppTheme.error)
                        .padding(.top, 4)
                    }

                    // 输入提示
                    if inputNotes.isEmpty && answerState == .idle {
                        Text("点击下方键盘输入音名")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.tertiaryText)
                            .padding(.top, 4)
                    }

                    // 答错时显示下一题按钮
                    if showNext {
                        Button {
                            goNext()
                        } label: {
                            Text("下一题")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(AppTheme.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 8)
            } bottomContent: {
                MusicKeyboard(
                    onNotePress: handleNotePress,
                    onClear: handleClear,
                    onSubmit: handleSubmit,
                    canSubmit: !inputNotes.isEmpty && answerState == .idle
                )
                .padding(.bottom, 6)
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
        .onAppear {
            generateNewQuestion()
            // 延迟 1.5 秒自动播放第一题
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                handleReplay()
            }
        }
    }

    // MARK: - Actions

    private func goNext() {
        if currentQuestion >= totalQuestions {
            // 记录本轮成绩
            roundResults.append(SingleRoundResult(
                round: roundNumber,
                correctCount: correctCount,
                totalQuestions: totalQuestions
            ))
            session.finish()
            let accuracy = Double(correctCount) / Double(totalQuestions)
            ExperienceEngine.shared.onUserAction(.practiceCompleted(accuracy: accuracy))
            withAnimation { showComplete = true }
            return
        }
        inputNotes = []
        currentAccidental = ""
        answerState = .idle
        showNext = false
        currentQuestion += 1
        session.nextQuestion()
        generateNewQuestion()
        // 自动播放新题目
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            handleReplay()
        }
    }

    private func handleNewQuestion() {
        if showNext { goNext() }
    }

    private func handleReplay() {
        guard let q = currentAnswer else { return }
        ExerciseSoundPlayer.playStandardSequence(noteName: "\(q.noteName)\(q.octave)")
    }

    private func handleNotePress(_ note: String) {
        guard answerState == .idle else { return }
        inputNotes.append(note)
        currentAccidental = ""
    }

    private func handleClear() {
        guard answerState == .idle else { return }
        if !inputNotes.isEmpty {
            inputNotes.removeLast()
        }
    }

    private func handleSubmit() {
        guard !inputNotes.isEmpty, answerState == .idle, let q = currentAnswer else { return }
        let last = inputNotes.last?.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "b", with: "") ?? ""
        let expectedNote = q.noteName
        let ok = last == expectedNote
        answerState = ok ? .correct : .wrong
        if ok {
            correctCount += 1
            score += 10
            session.submitAnswer(isCorrect: true)
            ExperienceEngine.shared.onUserAction(.noteCorrect(deviation: 0))
            // 答对：显示正确反馈后自动进入下一题
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                goNext()
            }
        } else {
            session.submitAnswer(isCorrect: false)
            ExperienceEngine.shared.onUserAction(.noteMissed)
            // 答错：显示"下一题"按钮，用户手动点击
            showNext = true
        }
    }

    private func generateNewQuestion() {
        // 从题库随机抽取（优先初级难度）
        let easyQuestions = QuestionBank.noteNameQuestions.filter { $0.difficulty == .easy }
        let pool = easyQuestions.isEmpty ? QuestionBank.noteNameQuestions : easyQuestions
        currentAnswer = pool.randomElement()
    }

    /// 继续下一轮（保留历史记录）
    private func handleContinueRound() {
        roundNumber += 1
        currentQuestion = 1
        correctCount = 0
        score = 0
        inputNotes = []
        answerState = .idle
        showNext = false
        showComplete = false
        session = PracticeSession(exerciseType: .singleNoteListening, totalQuestions: totalQuestions)
        session.start()
        generateNewQuestion()
        // 自动播放新轮次第一题
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            handleReplay()
        }
    }

    /// 完全重置（清空轮次，从第1轮开始）
    private func handleRetryRound() {
        roundNumber = 1
        currentQuestion = 1
        correctCount = 0
        score = 0
        inputNotes = []
        answerState = .idle
        showNext = false
        showComplete = false
        roundResults.removeAll()
        session = PracticeSession(exerciseType: .singleNoteListening, totalQuestions: totalQuestions)
        session.start()
        generateNewQuestion()
        // 自动播放第一题
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            handleReplay()
        }
    }
}

// MARK: - 五线谱展示 (匹配 v0 StaffNotation)

struct StaffNotationDisplay: View {
    let inputNotes: [String]
    let feedback: SingleNoteListeningView.AnswerState

    private let notePositions: [String: Int] = [
        "C": 0, "D": 1, "E": 2, "F": 3, "G": 4, "A": 5, "B": 6,
    ]

    private var borderColor: Color {
        switch feedback {
        case .correct: return AppTheme.success
        case .wrong: return AppTheme.error
        case .idle: return AppTheme.border
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 1)
                )

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let lineH = h * 0.5
                let lineSpacing = lineH / 4
                let centerY = h / 2

                ZStack {
                    // 5 条谱线
                    VStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { i in
                            Rectangle()
                                .fill(AppTheme.accent)
                                .frame(height: 1)
                            if i < 4 {
                                Spacer().frame(height: lineSpacing - 1)
                            }
                        }
                    }
                    .frame(height: lineH)
                    .position(x: w / 2, y: centerY)

                    // 高音谱号 (简化 SVG path)
                    TrebleClefShape()
                        .fill(AppTheme.accent)
                        .frame(width: 24, height: 45)
                        .position(x: 30, y: centerY - 2)

                    // 输入的音符
                    HStack(spacing: 20) {
                        ForEach(Array(inputNotes.enumerated()), id: \.offset) { _, note in
                            let baseNote = note.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "b", with: "")
                            let accidental = note.contains("#") ? "♯" : note.contains("b") ? "♭" : ""
                            let _ = notePositions[baseNote] ?? 0

                            HStack(spacing: 1) {
                                if !accidental.isEmpty {
                                    Text(accidental)
                                        .font(.system(size: 12))
                                        .foregroundStyle(AppTheme.accent)
                                }
                                Ellipse()
                                    .fill(AppTheme.accent)
                                    .frame(width: 12, height: 9)
                                    .rotationEffect(.degrees(-15))
                            }
                        }
                    }
                    .position(x: w / 2 + 10, y: centerY + 10)
                }
            }
        }
        .frame(height: 100)
    }
}

// 高音谱号简化形状
struct TrebleClefShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let scale = min(w, h) / 50

        // 简化的高音谱号轮廓
        path.move(to: CGPoint(x: 20 * scale, y: 10 * scale))
        path.addCurve(
            to: CGPoint(x: 30 * scale, y: 15 * scale),
            control1: CGPoint(x: 25 * scale, y: 5 * scale),
            control2: CGPoint(x: 35 * scale, y: 8 * scale)
        )
        path.addCurve(
            to: CGPoint(x: 18 * scale, y: 30 * scale),
            control1: CGPoint(x: 25 * scale, y: 22 * scale),
            control2: CGPoint(x: 15 * scale, y: 25 * scale)
        )
        path.addCurve(
            to: CGPoint(x: 28 * scale, y: 38 * scale),
            control1: CGPoint(x: 22 * scale, y: 35 * scale),
            control2: CGPoint(x: 32 * scale, y: 32 * scale)
        )
        path.addCurve(
            to: CGPoint(x: 20 * scale, y: 48 * scale),
            control1: CGPoint(x: 25 * scale, y: 44 * scale),
            control2: CGPoint(x: 15 * scale, y: 46 * scale)
        )

        // 谱号底部的点
        path.addEllipse(in: CGRect(x: 17 * scale, y: 48 * scale, width: 6 * scale, height: 6 * scale))

        return path
    }
}

// MARK: - 六线谱展示 (C 调指板，匹配 v0 TabSolfegeNotation)

struct TabSolfegeDisplay: View {
    let inputNotes: [String]
    let feedback: SingleNoteListeningView.AnswerState
    /// 标准音音名（C 调下始终为 A，5 弦空弦）
    var standardNote: String = "A"
    /// 正确答案（答错时同时显示）
    var correctNote: String? = nil

    /// C 调标准调弦 EADGBE 下各自然音在指板上的位置
    private let noteToFret: [String: (string: Int, fret: Int)] = [
        "C": (5, 3), "D": (4, 0), "E": (4, 2), "F": (4, 3),
        "G": (3, 0), "A": (5, 0), "B": (2, 0),
    ]

    private var borderColor: Color {
        switch feedback {
        case .correct: return AppTheme.success
        case .wrong: return AppTheme.error
        case .idle: return AppTheme.border
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 标题行：六线谱 + C 调标记
            HStack(spacing: 6) {
                Text("六线谱")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.secondaryText)
                Text("C 调")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.accent.opacity(0.7))
                    .clipShape(Capsule())
            }

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1)
                    )

                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    let lineSpacing = (h - 24) / 5

                    ZStack {
                        // 左侧弦号 + 6 条线
                        HStack(spacing: 6) {
                            VStack(spacing: 0) {
                                ForEach(1...6, id: \.self) { num in
                                    Text("\(num)")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(AppTheme.secondaryText)
                                        .frame(height: lineSpacing)
                                }
                            }
                            .frame(width: 18)

                            VStack(spacing: 0) {
                                ForEach(0..<6, id: \.self) { i in
                                    Rectangle()
                                        .fill(Color(hex: "94A3B8"))
                                        .frame(height: 0.8 + CGFloat(i) * 0.1)
                                    if i < 5 {
                                        Spacer().frame(height: lineSpacing - 0.8 - CGFloat(i) * 0.1)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal, 12)

                        // 标准音标记（左侧固定位置，显示 0）
                        if let pos = noteToFret[standardNote] {
                            let yOffset = CGFloat(pos.string - 1) * lineSpacing - (h - 24) / 2
                            HStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .stroke(Color(hex: "94A3B8"), lineWidth: 1.5)
                                        .background(Circle().fill(Color.white.opacity(0.9)))
                                        .frame(width: 24, height: 24)
                                    Text("0")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(Color(hex: "64748B"))
                                }
                                .offset(x: 0, y: yOffset)

                                Spacer()
                            }
                            .padding(.leading, 52)
                        }

                        // 用户答案 + 正确答案标记
                        HStack(spacing: 32) {
                            if inputNotes.isEmpty && correctNote == nil {
                                Color.clear.frame(width: 1, height: 1)
                            }

                            // 用户输入的音符
                            ForEach(Array(inputNotes.enumerated()), id: \.offset) { _, note in
                                let baseNote = note.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "b", with: "")
                                if let pos = noteToFret[baseNote] {
                                    let yOffset = CGFloat(pos.string - 1) * lineSpacing - (h - 24) / 2
                                    let dotColor = feedback == .wrong ? AppTheme.error : AppTheme.accent
                                    ZStack {
                                        Circle()
                                            .fill(dotColor.opacity(0.15))
                                            .frame(width: 28, height: 28)
                                        Circle()
                                            .fill(dotColor)
                                            .frame(width: 22, height: 22)
                                        Text("\(pos.fret)")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                    .offset(x: 0, y: yOffset)
                                }
                            }

                            // 正确答案（答错时显示，绿色）
                            if feedback == .wrong, let correct = correctNote {
                                let baseCorrect = correct.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "b", with: "")
                                if let pos = noteToFret[baseCorrect] {
                                    let yOffset = CGFloat(pos.string - 1) * lineSpacing - (h - 24) / 2
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.success.opacity(0.15))
                                            .frame(width: 28, height: 28)
                                        Circle()
                                            .fill(AppTheme.success)
                                            .frame(width: 22, height: 22)
                                        Text("\(pos.fret)")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                    .offset(x: 0, y: yOffset)
                                }
                            }
                        }
                        .position(x: w / 2 + 20, y: h / 2)
                    }
                }
            }
            .frame(height: 140)
        }
    }
}

// MARK: - 通用单轮成绩记录（供 ExerciseCompletionOverlay 使用）

struct RoundSummaryItem: Identifiable {
    let id = UUID()
    let round: Int
    let correctCount: Int
    let totalQuestions: Int
    var accuracy: Int { Int(Double(correctCount) / Double(totalQuestions) * 100) }
}

// MARK: - 练习完成覆盖层（支持多轮连续练习）

struct ExerciseCompletionOverlay: View {
    let roundNumber: Int
    let correctCount: Int
    let totalQuestions: Int
    let roundResults: [RoundSummaryItem]
    let onContinue: () -> Void
    let onBack: () -> Void

    private var percentage: Int {
        Int(Double(correctCount) / Double(totalQuestions) * 100)
    }

    /// 根据正确率返回颜色
    private func colorForAccuracy(_ acc: Int) -> Color {
        if acc >= 90 { return AppTheme.success }
        if acc >= 70 { return AppTheme.accent }
        if acc >= 50 { return AppTheme.warning }
        return AppTheme.error
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // === 头部 ===
                    Text("练习完成")
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

                    // 本轮成绩大字展示
                    VStack(spacing: 8) {
                        Text("\(correctCount)/\(totalQuestions)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(colorForAccuracy(percentage))

                        Text("正确率 \(percentage)%")
                            .font(.system(size: 15))
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    // === 历史轮次汇总（2轮以上显示）===
                    if roundResults.count > 1 {
                        Divider()
                            .padding(.horizontal, 20)

                        historyRoundsList
                    }

                    // === 按钮 ===
                    VStack(spacing: 12) {
                        Button {
                            onContinue()
                        } label: {
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
                        .buttonStyle(.plain)

                        Button {
                            onBack()
                        } label: {
                            Text("结束练习，返回")
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(28)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 36)
            }
        }
    }

    // MARK: - 历史轮次列表

    @ViewBuilder
    private var historyRoundsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.accent)
                Text("已练 \(roundResults.count) 轮")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.primaryText)
            }

            ForEach(roundResults) { result in
                HStack(spacing: 10) {
                    Text("第\(result.round)轮")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(width: 44, alignment: .trailing)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AppTheme.mutedBackground)
                                .frame(height: 12)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(colorForAccuracy(result.accuracy).opacity(0.75))
                                .frame(width: max(4, geo.size.width * Double(result.accuracy) / 100), height: 12)

                            Text("\(result.accuracy)%")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.white)
                                .offset(x: min(
                                    geo.size.width * Double(result.accuracy) / 100 - 16,
                                    geo.size.width - 32
                                ))
                        }
                    }
                    .frame(height: 12)
                }
            }
        }
        .padding(14)
        .background(AppTheme.mutedBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - 预览

#Preview {
    NavigationStack {
        SingleNoteListeningView()
    }
}
