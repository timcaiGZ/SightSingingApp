import SwiftUI

/// 单音听辨练习页
/// 先播放标准音 A4，再播放目标音，用户通过音乐键盘输入答案
struct SingleNoteListeningView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let module: ExerciseModule
    let viewModel: PracticeViewModel

    // MARK: - 题目状态
    @State private var targetNote: Int = 60
    @State private var targetOctave: Int = 4
    @State private var targetNoteName: String = "C"
    @State private var questionCount: Int = 0
    @State private var correctCount: Int = 0
    @State private var totalQuestions: Int = 10
    @State private var startTime: Date = Date()

    // MARK: - 用户输入状态
    @State private var selectedNoteName: String? = nil
    @State private var selectedAccidental: AccidentalType = .natural
    @State private var selectedOctave: Int = 4
    @State private var userInputs: [String] = []

    // MARK: - 反馈状态
    @State private var showFeedback: Bool = false
    @State private var isCorrect: Bool = false
    @State private var feedbackMessage: String = ""

    // MARK: - 常量
    private let referenceNote: Int = 69 // A4 = 440Hz
    private let referenceNoteName = "A"
    private let whiteKeyNotes = ["C", "D", "E", "F", "G", "A", "B"]
    private let whiteKeyMIDIs = [60, 62, 64, 65, 67, 69, 71]

    enum AccidentalType: String, CaseIterable {
        case natural = "♮"
        case sharp = "♯"
        case flat = "♭"
    }

    // MARK: - 计算属性
    private var userAnswerDisplay: String {
        guard let note = selectedNoteName else { return "点击键盘输入答案" }
        let accidental = selectedAccidental == .natural ? "" : selectedAccidental.rawValue
        return "\(note)\(accidental)"
    }

    private var currentScore: Int {
        guard questionCount > 0 else { return 0 }
        return Int(Double(correctCount) / Double(questionCount) * 100)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            headerView

            Divider()

            // 内容区
            ScrollView {
                VStack(spacing: 20) {
                    // 说明文字
                    instructionView

                    // 进度与得分
                    progressView

                    // 播放控制区
                    playbackControlView

                    // 用户答案显示
                    answerDisplayView

                    // 反馈区域
                    if showFeedback {
                        feedbackView
                    }

                    // 操作按钮
                    actionButtonsView
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }

            Divider()

            // 音乐键盘
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
                // 保存记录后退出
                if questionCount > 0 {
                    viewModel.savePracticeRecord(
                        module: module,
                        exerciseType: .singleNoteRecognition,
                        score: currentScore,
                        durationSeconds: Int(Date().timeIntervalSince(startTime))
                    )
                }
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("自由练习")
                }
                .font(.body)
                .foregroundStyle(AppColors.primary)
            }

            Spacer()

            Text("单音听辨")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Button {
                // 设置（可扩展）
            } label: {
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
        Text("先听标准音，再听题目音。\n然后在键盘中选择你听到的音。")
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
            // 大播放按钮
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
                Text("正确答案是 \(targetNoteName) (\(noteNameToSolfege(targetNoteName)))")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            (isCorrect ? AppColors.success : AppColors.error)
                .opacity(0.08)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var actionButtonsView: some View {
        HStack {
            Button {
                generateNewQuestion()
            } label: {
                Label("新问题", systemImage: "shuffle")
                    .font(.body)
                    .foregroundStyle(AppColors.primary)
            }

            Spacer()

            Button {
                playQuestion()
            } label: {
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
            // 音符时值行（装饰用，单音听辨不使用时值）
            durationRow

            // 音名 + 功能键
            keyboardRow(
                leftKeys: [("♮", { selectedAccidental = .natural })],
                centerKeys: [
                    ("C", { selectNote("C") }),
                    ("D", { selectNote("D") }),
                    ("E", { selectNote("E") })
                ],
                rightKeys: [("删除", { deleteLastInput() })]
            )

            keyboardRow(
                leftKeys: [("♯", { selectedAccidental = .sharp })],
                centerKeys: [
                    ("F", { selectNote("F") }),
                    ("G", { selectNote("G") }),
                    ("A", { selectNote("A") })
                ],
                rightKeys: [("↑", { selectedOctave = min(selectedOctave + 1, 6) })]
            )

            keyboardRow(
                leftKeys: [("♭", { selectedAccidental = .flat })],
                centerKeys: [
                    ("B", { selectNote("B") }),
                    ("+8va", { selectedOctave = min(selectedOctave + 1, 6) }),
                    ("-8va", { selectedOctave = max(selectedOctave - 1, 2) })
                ],
                rightKeys: []
            )

            // 完成按钮
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

    private var durationRow: some View {
        HStack(spacing: 8) {
            ForEach([("𝅝", "全音符"), ("𝅗𝅥", "二分音符"), ("𝅘𝅥", "四分音符"), ("𝅘𝅥𝅮", "八分音符"), ("𝅘𝅥𝅯", "十六分音符")], id: \.1) { symbol, name in
                Button {
                    // 单音听辨不使用时值，仅作为装饰
                } label: {
                    Text(symbol)
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color(.systemGray4))
                        .foregroundStyle(.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .disabled(true)
                .opacity(0.6)
            }
        }
    }

    private func keyboardRow(
        leftKeys: [(String, () -> Void)],
        centerKeys: [(String, () -> Void)],
        rightKeys: [(String, () -> Void)]
    ) -> some View {
        HStack(spacing: 6) {
            // 左侧功能键（灰色）
            ForEach(leftKeys.indices, id: \.self) { i in
                let key = leftKeys[i]
                keyboardKey(key.0, action: key.1, style: .accent)
            }

            // 中间音名键（白色）
            ForEach(centerKeys.indices, id: \.self) { i in
                let key = centerKeys[i]
                keyboardKey(key.0, action: key.1, style: .primary)
            }

            // 右侧功能键（灰色）
            ForEach(rightKeys.indices, id: \.self) { i in
                let key = rightKeys[i]
                keyboardKey(key.0, action: key.1, style: .accent)
            }

            // 填充空白，保持布局
            if centerKeys.isEmpty && rightKeys.count < 2 {
                Spacer()
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
        // 重置状态
        showFeedback = false
        selectedNoteName = nil
        selectedAccidental = .natural
        selectedOctave = 4

        // 随机选择一个白键（C4-B4 范围）
        let index = Int.random(in: 0..<whiteKeyMIDIs.count)
        targetNote = whiteKeyMIDIs[index]
        targetNoteName = whiteKeyNotes[index]
        targetOctave = 4

        // 自动播放
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            playQuestion()
        }
    }

    private func playQuestion() {
        Task {
            // 播放标准音 A4
            await AudioEngineManager.shared.playMIDI(referenceNote, duration: 0.8)
            try? await Task.sleep(nanoseconds: 600_000_000) // 0.6秒停顿
            // 播放目标音
            await AudioEngineManager.shared.playMIDI(targetNote, duration: 1.0)
        }
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

        // 构建用户答案的 MIDI note
        let userMIDI = midiNoteFromAnswer(note: userNote, accidental: selectedAccidental, octave: selectedOctave)

        isCorrect = (userMIDI == targetNote)
        questionCount += 1

        if isCorrect {
            correctCount += 1
            feedbackMessage = "正确！"
        } else {
            feedbackMessage = "错误"
        }

        showFeedback = true

        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .medium : .heavy)
        generator.impactOccurred()

        // 3秒后自动下一题，或完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if questionCount >= totalQuestions {
                // 练习完成
                viewModel.savePracticeRecord(
                    module: module,
                    exerciseType: .singleNoteRecognition,
                    score: currentScore,
                    durationSeconds: Int(Date().timeIntervalSince(startTime))
                )
                dismiss()
            } else {
                generateNewQuestion()
            }
        }
    }

    // MARK: - 辅助方法

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

        // C4 = 60, 所以 octave 4 对应 MIDI 基准
        return (octave + 1) * 12 + semitone
    }

    private func noteNameToSolfege(_ noteName: String) -> String {
        let mapping: [String: String] = [
            "C": "1 (Do)", "D": "2 (Re)", "E": "3 (Mi)",
            "F": "4 (Fa)", "G": "5 (Sol)", "A": "6 (La)", "B": "7 (Si)"
        ]
        return mapping[noteName] ?? noteName
    }
}

// MARK: - 预览
#Preview {
    NavigationStack {
        SingleNoteListeningView(
            module: .noteName,
            viewModel: PracticeViewModel()
        )
    }
}
