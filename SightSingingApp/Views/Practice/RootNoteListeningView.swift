import SwiftUI

/// 根音听辨练习页 — 匹配 v0.app 设计
/// 同时播放多个音（和弦），用户听辨并选择最低音（根音/低音）
struct RootNoteListeningView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let module: ExerciseModule
    let viewModel: PracticeViewModel

    // MARK: - 题目状态
    @State private var rootNote: Int = 60
    @State private var rootNoteName: String = "C"
    @State private var allNotes: [Int] = []
    @State private var questionCount: Int = 0
    @State private var correctCount: Int = 0
    private let totalQuestions: Int = 10
    @State private var startTime: Date = Date()

    // MARK: - 用户输入状态
    @State private var selectedNoteName: String? = nil
    @State private var selectedAccidental: AccidentalType = .natural
    @State private var selectedOctave: Int = 4
    @State private var inputNotes: [String] = []
    @State private var answerState: AnswerState = .idle
    @State private var showNext = false
    @State private var showComplete = false

    enum AnswerState {
        case idle, correct, wrong
    }

    enum AccidentalType: String, CaseIterable {
        case natural = "♮"
        case sharp = "♯"
        case flat = "♭"
    }

    private let referenceNote: Int = 69 // A4
    private let whiteKeyNotes = ["C", "D", "E", "F", "G", "A", "B"]

    private var currentScore: Int {
        guard questionCount > 0 else { return 0 }
        return Int(Double(correctCount) / Double(questionCount) * 100)
    }

    private var userAnswerDisplay: String {
        guard let note = selectedNoteName else { return "" }
        let accidental = selectedAccidental == .natural ? "" : selectedAccidental.rawValue
        return "\(note)\(accidental)"
    }

    var body: some View {
        ZStack {
            ExerciseLayout(
                title: "根音听辨",
                questionNumber: min(questionCount + 1, totalQuestions),
                totalQuestions: totalQuestions,
                questionText: "请问和弦的根音是什么? 先听标准音再听和弦，找出最低的音（根音）。",
                score: currentScore,
                showDecompose: true,
                onBack: { saveAndDismiss() },
                onNewQuestion: handleNewQuestion,
                onDecompose: { playQuestion() },
                onReplay: { playQuestion() },
                replayLabel: "重听"
            ) {
                VStack(spacing: 16) {
                    // 标准音 + 和弦播放
                    VStack(spacing: 8) {
                        ReferenceNoteCard(
                            note: "A",
                            frequency: "440 Hz",
                            onPlay: {
                                Task {
                                    await AudioEngineManager.shared.playMIDI(referenceNote, duration: 0.8)
                                }
                            }
                        )

                        AudioPromptCard(
                            label: "点击播放和弦",
                            hint: "同时播放 \(allNotes.count) 个音",
                            onPlay: { playQuestion() }
                        )
                    }

                    // 答案反馈区
                    if answerState != .idle {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: answerState == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(answerState == .correct ? AppTheme.success : AppTheme.error)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(answerState == .correct ? "正确！" : "错误")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(answerState == .correct ? AppTheme.success : AppTheme.error)

                                    if answerState == .wrong {
                                        Text("正确根音是 \(rootNoteName)")
                                            .font(.system(size: 14))
                                            .foregroundStyle(AppTheme.secondaryText)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding(16)
                        .background(
                            (answerState == .correct ? AppTheme.success : AppTheme.error).opacity(0.08)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                    canSubmit: selectedNoteName != nil && answerState == .idle
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
        .onAppear {
            viewModel.setModelContext(modelContext)
            generateNewQuestion()
        }
    }

    // MARK: - Actions

    private func goNext() {
        if questionCount >= totalQuestions {
            withAnimation { showComplete = true }
            return
        }
        inputNotes = []
        selectedNoteName = nil
        selectedAccidental = .natural
        answerState = .idle
        showNext = false
        generateNewQuestion()
    }

    private func handleNewQuestion() {
        if showNext { goNext() }
    }

    private func handleNotePress(_ note: String) {
        guard answerState == .idle else { return }
        // Parse note input to determine note name and accidental
        let cleaned = note.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "b", with: "")
        if cleaned.count == 1, whiteKeyNotes.contains(cleaned) {
            selectedNoteName = cleaned
            selectedAccidental = note.contains("#") ? .sharp : (note.contains("b") ? .flat : .natural)
        }
        inputNotes = [note]
    }

    private func handleClear() {
        guard answerState == .idle else { return }
        inputNotes = []
        selectedNoteName = nil
        selectedAccidental = .natural
    }

    private func handleSubmit() {
        guard let userNote = selectedNoteName, answerState == .idle else { return }
        // 根据 rootNote 计算正确的八度，确保用户选对音名即算正确
        let rootOctave = (rootNote / 12) - 1
        let userMIDI = midiNoteFromAnswer(note: userNote, accidental: selectedAccidental, octave: rootOctave)

        let isCorrect = (userMIDI == rootNote)
        questionCount += 1

        if isCorrect {
            correctCount += 1
            answerState = .correct
        } else {
            answerState = .wrong
        }

        showNext = true

        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .medium : .heavy)
        generator.impactOccurred()
    }

    private func handleRetryRound() {
        questionCount = 0
        correctCount = 0
        inputNotes = []
        selectedNoteName = nil
        selectedAccidental = .natural
        answerState = .idle
        showNext = false
        showComplete = false
        generateNewQuestion()
    }

    // MARK: - 业务逻辑

    private func generateNewQuestion() {
        answerState = .idle
        selectedNoteName = nil
        selectedAccidental = .natural
        selectedOctave = 4
        inputNotes = []

        let baseNotes: [(name: String, midi: Int)] = [
            ("C", 48), ("D", 50), ("E", 52), ("F", 53), ("G", 55), ("A", 57), ("B", 59),
            ("C", 60), ("D", 62), ("E", 64), ("F", 65), ("G", 67), ("A", 69), ("B", 71),
            ("C", 72), ("D", 74)
        ]

        let chosen = baseNotes.randomElement()!
        rootNote = chosen.midi
        rootNoteName = chosen.name

        let noteCount = Int.random(in: 2...4)
        var notes = [rootNote]
        let possibleUpper = (rootNote + 2)...(rootNote + 24)
        var upperNotes: [Int] = []
        while upperNotes.count < noteCount - 1 {
            let random = Int.random(in: possibleUpper)
            if !upperNotes.contains(random) && random != rootNote {
                upperNotes.append(random)
            }
        }
        notes.append(contentsOf: upperNotes)
        allNotes = notes.shuffled()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            playQuestion()
        }
    }

    private func playQuestion() {
        Task {
            await AudioEngineManager.shared.playMIDI(referenceNote, duration: 0.8)
            try? await Task.sleep(nanoseconds: 600_000_000)
            let notesForPlayback = allNotes.map { midi -> (solfege: String, octave: Int) in
                let (solfege, octave) = midiToSolfege(midi)
                return (solfege, octave)
            }
            await AudioEngineManager.shared.playChord(notesForPlayback, duration: 1.2)
        }
    }

    private func midiToSolfege(_ midi: Int) -> (String, Int) {
        let octave = (midi / 12) - 1
        let noteInOctave = midi % 12
        let mapping: [Int: String] = [
            0: "1", 2: "2", 4: "3", 5: "4", 7: "5", 9: "6", 11: "7",
            1: "#1", 3: "#2", 6: "#4", 8: "#5", 10: "#6"
        ]
        let solfege = mapping[noteInOctave] ?? "1"
        return (solfege, octave)
    }

    private func saveAndDismiss() {
        viewModel.savePracticeRecord(
            module: module,
            exerciseType: .rootNoteRecognition,
            score: currentScore,
            durationSeconds: Int(Date().timeIntervalSince(startTime))
        )
        dismiss()
    }

    private func midiNoteFromAnswer(note: String, accidental: AccidentalType, octave: Int) -> Int {
        let baseNotes: [String: Int] = [
            "C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11
        ]
        guard let base = baseNotes[note] else { return 60 }
        var semitone = base
        switch accidental {
        case .sharp: semitone += 1
        case .flat: semitone -= 1
        case .natural: break
        }
        return (octave + 1) * 12 + semitone
    }
}

#Preview {
    NavigationStack {
        RootNoteListeningView(module: .noteName, viewModel: PracticeViewModel())
    }
}
