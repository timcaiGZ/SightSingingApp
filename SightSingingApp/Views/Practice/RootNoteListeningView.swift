import SwiftUI

/// 根音听辨练习页
/// 同时播放多个音（和弦），用户听辨并选择最低音（根音/低音）
struct RootNoteListeningView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let module: ExerciseModule
    let viewModel: PracticeViewModel

    // MARK: - 题目状态
    @State private var rootNote: Int = 60          // 根音 MIDI
    @State private var rootNoteName: String = "C"  // 根音音名
    @State private var allNotes: [Int] = []         // 同时播放的所有音
    @State private var questionCount: Int = 0
    @State private var correctCount: Int = 0
    @State private var totalQuestions: Int = 10
    @State private var startTime: Date = Date()

    // MARK: - 用户输入状态
    @State private var selectedNoteName: String? = nil
    @State private var selectedAccidental: AccidentalType = .natural
    @State private var selectedOctave: Int = 4
    @State private var showFeedback: Bool = false
    @State private var isCorrect: Bool = false
    @State private var feedbackMessage: String = ""

    // MARK: - 常量
    private let referenceNote: Int = 69 // A4
    private let whiteKeyNotes = ["C", "D", "E", "F", "G", "A", "B"]
    private let whiteKeyMIDIs = [60, 62, 64, 65, 67, 69, 71]

    enum AccidentalType: String, CaseIterable {
        case natural = "♮"
        case sharp = "♯"
        case flat = "♭"
    }

    private var currentScore: Int {
        guard questionCount > 0 else { return 0 }
        return Int(Double(correctCount) / Double(questionCount) * 100)
    }

    private var userAnswerDisplay: String {
        guard let note = selectedNoteName else { return "点击键盘输入答案" }
        let accidental = selectedAccidental == .natural ? "" : selectedAccidental.rawValue
        return "\(note)\(accidental)"
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    instructionView
                    progressView
                    playbackControlView
                    answerDisplayView

                    if showFeedback {
                        feedbackView
                    }

                    actionButtonsView
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }

            Divider()
            musicKeyboardView
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
            generateNewQuestion()
        }
    }

    // MARK: - 子视图

    private var headerView: some View {
        HStack {
            Button {
                saveAndDismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("自由练习")
                }
                .font(.body)
                .foregroundStyle(AppColors.primary)
            }

            Spacer()

            Text("根音听辨")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Button { } label: {
                Image(systemName: "gear")
                    .font(.title3)
                    .foregroundStyle(AppColors.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    private var instructionView: some View {
        Text("先听标准音，再听一组音。\n找出其中最低的那个音（根音）。")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
    }

    private var progressView: some View {
        HStack {
            Text("第 \(questionCount + 1) / \(totalQuestions) 题")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text("得分: \(currentScore)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.primary)
        }
    }

    private var playbackControlView: some View {
        VStack(spacing: 16) {
            Button {
                playQuestion()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.primary.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: AppColors.primary.opacity(0.3), radius: 12, x: 0, y: 6)

                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                }
            }

            Text("点击播放")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }

    private var answerDisplayView: some View {
        VStack(spacing: 8) {
            Text("你的答案")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(userAnswerDisplay)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(selectedNoteName == nil ? .secondary : AppColors.primary)
                .frame(minHeight: 44)
                .animation(.easeInOut(duration: 0.2), value: selectedNoteName)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var feedbackView: some View {
        VStack(spacing: 8) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(isCorrect ? AppColors.success : AppColors.error)

            Text(feedbackMessage)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(isCorrect ? AppColors.success : AppColors.error)

            if !isCorrect {
                Text("正确根音是 \(rootNoteName)")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            (isCorrect ? AppColors.success : AppColors.error).opacity(0.08)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var actionButtonsView: some View {
        HStack(spacing: 24) {
            Button { generateNewQuestion() } label: {
                Label("新问题", systemImage: "shuffle")
                    .font(.body)
                    .foregroundStyle(AppColors.primary)
            }

            Button { playArpeggio() } label: {
                Label("分解", systemImage: "waveform")
                    .font(.body)
                    .foregroundStyle(AppColors.primary)
            }

            Button { playQuestion() } label: {
                Label("重听", systemImage: "arrow.counterclockwise")
                    .font(.body)
                    .foregroundStyle(AppColors.primary)
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - 音乐键盘
    private var musicKeyboardView: some View {
        VStack(spacing: 6) {
            keyboardRow(
                leftKeys: [("♮", { selectedAccidental = .natural })],
                centerKeys: [("C", { selectNote("C") }), ("D", { selectNote("D") }), ("E", { selectNote("E") })],
                rightKeys: [("删除", { deleteLastInput() })]
            )

            keyboardRow(
                leftKeys: [("♯", { selectedAccidental = .sharp })],
                centerKeys: [("F", { selectNote("F") }), ("G", { selectNote("G") }), ("A", { selectNote("A") })],
                rightKeys: [("↑", { selectedOctave = min(selectedOctave + 1, 6) })]
            )

            keyboardRow(
                leftKeys: [("♭", { selectedAccidental = .flat })],
                centerKeys: [("B", { selectNote("B") }), ("+8va", { selectedOctave = min(selectedOctave + 1, 6) }), ("-8va", { selectedOctave = max(selectedOctave - 1, 2) })],
                rightKeys: []
            )

            Button {
                submitAnswer()
            } label: {
                Text("完成")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(selectedNoteName == nil)
            .opacity(selectedNoteName == nil ? 0.5 : 1)
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
    }

    private func playArpeggio() {
        Task {
            await AudioEngineManager.shared.playMIDI(referenceNote, duration: 0.8)
            try? await Task.sleep(nanoseconds: 400_000_000)
            for midi in allNotes.sorted() {
                await AudioEngineManager.shared.playMIDI(midi, duration: 0.6)
                try? await Task.sleep(nanoseconds: 300_000_000)
            }
        }
    }


    private func keyboardRow(
        leftKeys: [(String, () -> Void)],
        centerKeys: [(String, () -> Void)],
        rightKeys: [(String, () -> Void)]
    ) -> some View {
        HStack(spacing: 6) {
            ForEach(leftKeys.indices, id: \.self) { i in
                let key = leftKeys[i]
                keyboardKey(key.0, action: key.1, style: .accent)
            }
            ForEach(centerKeys.indices, id: \.self) { i in
                let key = centerKeys[i]
                keyboardKey(key.0, action: key.1, style: .primary)
            }
            ForEach(rightKeys.indices, id: \.self) { i in
                let key = rightKeys[i]
                keyboardKey(key.0, action: key.1, style: .accent)
            }
        }
    }

    private func keyboardKey(_ title: String, action: @escaping () -> Void, style: KeyStyle) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: title.count > 1 ? 12 : 15, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(style.backgroundColor)
                .foregroundStyle(style.foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    enum KeyStyle {
        case primary, accent

        var backgroundColor: Color {
            switch self {
            case .primary: return Color(.systemBackground)
            case .accent: return Color(.systemGray3)
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary: return .primary
            case .accent: return .primary
            }
        }
    }

    // MARK: - 业务逻辑

    private func generateNewQuestion() {
        showFeedback = false
        selectedNoteName = nil
        selectedAccidental = .natural
        selectedOctave = 4

        // 随机选择一个根音（C3 ~ D5）
        let baseNotes: [(name: String, midi: Int)] = [
            ("C", 48), ("D", 50), ("E", 52), ("F", 53), ("G", 55), ("A", 57), ("B", 59),
            ("C", 60), ("D", 62), ("E", 64), ("F", 65), ("G", 67), ("A", 69), ("B", 71),
            ("C", 72), ("D", 74)
        ]

        let chosen = baseNotes.randomElement()!
        rootNote = chosen.midi
        rootNoteName = chosen.name

        // 生成 2~4 个音，根音 + 上方音（2~24 半音范围内随机）
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

    private func selectNote(_ note: String) {
        selectedNoteName = note
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private func deleteLastInput() {
        selectedNoteName = nil
        selectedAccidental = .natural
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private func submitAnswer() {
        guard let userNote = selectedNoteName else { return }
        let userMIDI = midiNoteFromAnswer(note: userNote, accidental: selectedAccidental, octave: selectedOctave)

        isCorrect = (userMIDI == rootNote)
        questionCount += 1

        if isCorrect {
            correctCount += 1
            feedbackMessage = "正确！"
        } else {
            feedbackMessage = "错误"
        }

        showFeedback = true

        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .medium : .heavy)
        generator.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if questionCount >= totalQuestions {
                saveAndDismiss()
            } else {
                generateNewQuestion()
            }
        }
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
