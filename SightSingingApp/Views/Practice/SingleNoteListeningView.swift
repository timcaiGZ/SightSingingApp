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

    enum AnswerState {
        case idle, correct, wrong
    }

    var body: some View {
        ZStack {
            ExerciseLayout(
                title: "单音辨认",
                questionNumber: currentQuestion,
                totalQuestions: totalQuestions,
                questionText: "请问演奏了哪个单音? 你听到的第一个音是标准音 (无须录入)。",
                score: score,
                showDecompose: false,
                onBack: { dismiss() },
                onNewQuestion: handleNewQuestion,
                onReplay: handleReplay,
                replayLabel: "重听"
            ) {
                VStack(spacing: 16) {
                    // 谱式展示
                    if notationPrefs.preferredNotation == .staff {
                        StaffNotationDisplay(inputNotes: inputNotes, feedback: answerState)
                    } else {
                        TabSolfegeDisplay(inputNotes: inputNotes, feedback: answerState)
                    }

                    // 下一题按钮
                    if showNext {
                        Button {
                            goNext()
                        } label: {
                            Text("下一题")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(AppTheme.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 16)
            } bottomContent: {
                MusicKeyboard(
                    onNotePress: handleNotePress,
                    onClear: handleClear,
                    onSubmit: handleSubmit,
                    canSubmit: !inputNotes.isEmpty && answerState == .idle
                )
                .padding(.bottom, 8)
            }

            // 完成覆盖层
            if showComplete {
                ExerciseCompletionOverlay(
                    correctCount: correctCount,
                    totalQuestions: totalQuestions,
                    onRetry: handleRetryRound,
                    onBack: { dismiss() }
                )
                .transition(.opacity)
            }
        }
        .onAppear { generateNewQuestion() }
    }

    // MARK: - Actions

    private func goNext() {
        if currentQuestion >= totalQuestions {
            withAnimation { showComplete = true }
            return
        }
        inputNotes = []
        currentAccidental = ""
        answerState = .idle
        showNext = false
        currentQuestion += 1
        generateNewQuestion()
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
        showNext = true
        if ok {
            correctCount += 1
            score += 10
        }
    }

    private func generateNewQuestion() {
        // 从题库随机抽取（优先初级难度）
        let easyQuestions = QuestionBank.noteNameQuestions.filter { $0.difficulty == .easy }
        let pool = easyQuestions.isEmpty ? QuestionBank.noteNameQuestions : easyQuestions
        currentAnswer = pool.randomElement()
    }

    private func handleRetryRound() {
        currentQuestion = 1
        correctCount = 0
        score = 0
        inputNotes = []
        answerState = .idle
        showNext = false
        showComplete = false
        generateNewQuestion()
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

// MARK: - 六线谱+简谱展示 (匹配 v0 TabSolfegeNotation)

struct TabSolfegeDisplay: View {
    let inputNotes: [String]
    let feedback: SingleNoteListeningView.AnswerState

    private let noteToSolfege: [String: String] = [
        "C": "1", "D": "2", "E": "3", "F": "4", "G": "5", "A": "6", "B": "7",
    ]

    private let noteToFret: [String: (string: Int, fret: Int)] = [
        "C": (5, 3), "D": (4, 0), "E": (4, 2), "F": (4, 3),
        "G": (3, 0), "A": (3, 2), "B": (2, 0),
    ]

    private var borderColor: Color {
        switch feedback {
        case .correct: return AppTheme.success
        case .wrong: return AppTheme.error
        case .idle: return AppTheme.border
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // 六线谱
            tablatureCard

            // 简谱
            solfegeCard
        }
    }

    private var tablatureCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("六线谱")
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.secondaryText)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1)
                    )

                GeometryReader { geo in
                    let h = geo.size.height
                    let lineSpacing = (h - 20) / 5

                    ZStack {
                        // 左侧数字 1-6 + 6 条线
                        HStack(spacing: 6) {
                            // 弦号列
                            VStack(spacing: 0) {
                                ForEach(1...6, id: \.self) { num in
                                    Text("\(num)")
                                        .font(.system(size: 9))
                                        .foregroundStyle(AppTheme.secondaryText)
                                        .frame(height: lineSpacing)
                                }
                            }
                            .frame(width: 16)

                            // 6 条线
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
                            .padding(.vertical, 6)
                        }
                        .padding(.horizontal, 12)

                        // 输入的音符（品位标记）
                        HStack(spacing: 28) {
                            ForEach(Array(inputNotes.enumerated()), id: \.offset) { _, note in
                                let baseNote = note.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "b", with: "")
                                if let pos = noteToFret[baseNote] {
                                    let yOffset = CGFloat(pos.string - 1) * lineSpacing - (h - 20) / 2 + 10
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 18, height: 18)
                                        .overlay(
                                            Text("\(pos.fret)")
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundStyle(AppTheme.primaryText)
                                        )
                                        .offset(x: 0, y: yOffset)
                                }
                            }
                        }
                        .position(x: geo.size.width / 2 + 10, y: h / 2)
                    }
                }
            }
            .frame(height: 80)
        }
    }

    private var solfegeCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("简谱")
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.secondaryText)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1)
                    )

                HStack(spacing: 20) {
                    if inputNotes.isEmpty {
                        Text("等待输入...")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                    } else {
                        ForEach(Array(inputNotes.enumerated()), id: \.offset) { _, note in
                            let baseNote = note.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "b", with: "")
                            let solfege = noteToSolfege[baseNote] ?? "?"
                            let hasSharp = note.contains("#")
                            let hasFlat = note.contains("b")

                            VStack(spacing: 2) {
                                HStack(alignment: .lastTextBaseline, spacing: 1) {
                                    if hasSharp {
                                        Text("♯")
                                            .font(.system(size: 12))
                                            .foregroundStyle(AppTheme.accent)
                                    }
                                    if hasFlat {
                                        Text("♭")
                                            .font(.system(size: 12))
                                            .foregroundStyle(AppTheme.accent)
                                    }
                                    Text(solfege)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(AppTheme.accent)
                                }

                                Text(solfegeName(baseNote))
                                    .font(.system(size: 10))
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 80)
        }
    }

    private func solfegeName(_ note: String) -> String {
        switch note {
        case "C": return "do"
        case "D": return "re"
        case "E": return "mi"
        case "F": return "fa"
        case "G": return "sol"
        case "A": return "la"
        case "B": return "si"
        default: return ""
        }
    }
}

// MARK: - 练习完成覆盖层

struct ExerciseCompletionOverlay: View {
    let correctCount: Int
    let totalQuestions: Int
    let onRetry: () -> Void
    let onBack: () -> Void

    private var percentage: Int {
        Int(Double(correctCount) / Double(totalQuestions) * 100)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("练习完成")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)

                VStack(spacing: 8) {
                    Text("\(correctCount)/\(totalQuestions)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.accent)

                    Text("正确率 \(percentage)%")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.secondaryText)
                }

                VStack(spacing: 12) {
                    Button {
                        onRetry()
                    } label: {
                        Text("重新练习")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    Button {
                        onBack()
                    } label: {
                        Text("返回")
                            .font(.system(size: 17))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(32)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - 预览

#Preview {
    NavigationStack {
        SingleNoteListeningView()
    }
}
