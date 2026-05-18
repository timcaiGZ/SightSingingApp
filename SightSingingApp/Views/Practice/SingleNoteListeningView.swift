import SwiftUI

/// 单音听辨练习页（集成钢琴键盘和谱式切换）
struct SingleNoteListeningView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let module: ExerciseModule
    let viewModel: PracticeViewModel

    // MARK: - 状态
    @State private var targetNote: Int = 60
    @State private var targetOctave: Int = 4
    @State private var targetNoteName: String = "C"
    @State private var questionCount: Int = 0
    @State private var correctCount: Int = 0
    @State private var totalQuestions: Int = 10
    @State private var startTime: Date = Date()

    // 键盘状态
    @State private var selectedNoteName: String?
    @State private var selectedAccidental: PianoKeyboardView.AccidentalState = .natural
    @State private var showFeedback: Bool = false
    @State private var isCorrect: Bool = false

    private let referenceNote = 69 // A4 = 440Hz
    private let whiteKeyNotes = ["C", "D", "E", "F", "G", "A", "B"]
    private let whiteKeyMIDIs = [60, 62, 64, 65, 67, 69, 71]

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
                    // 题目提示
                    questionHint

                    // 播放控制
                    playbackControl

                    // 答案显示
                    answerDisplay

                    // 反馈区域
                    if showFeedback {
                        feedbackView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }

            // 钢琴键盘
            PianoKeyboardView(
                selectedNote: $selectedNoteName,
                selectedAccidental: $selectedAccidental,
                onConfirm: submitAnswer,
                onDelete: deleteLastInput
            )
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
            generateNewQuestion()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button {
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
                    Text("返回")
                }
                .font(.body)
                .foregroundStyle(AppColors.primary)
            }

            Spacer()

            Text("单音听辨")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Text("\(currentScore) 分")
                .font(.subheadline)
                .foregroundStyle(AppColors.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    // MARK: - 题目提示

    private var questionHint: some View {
        VStack(spacing: 16) {
            // 进度
            HStack {
                Text("第 \(questionCount + 1) / \(totalQuestions) 题")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                Spacer()
            }

            // 听力练习提示（不显示谱式，避免提前泄露答案）
            VStack(spacing: 12) {
                Image(systemName: "ear.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.primary.opacity(0.3))

                Text("仔细聆听播放的音符")
                    .font(.body)
                    .foregroundStyle(AppColors.secondaryText)

                Text("点击下方播放按钮开始")
                    .font(.caption)
                    .foregroundStyle(AppColors.tertiaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }

    // MARK: - 播放控制

    private var playbackControl: some View {
        VStack(spacing: 16) {
            Button {
                playQuestion()
            } label: {
                ZStack {
                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 80, height: 80)
                        .shadow(color: AppColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)

                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }
            }

            Text("点击播放")
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding(.vertical, 8)
    }

    // MARK: - 答案显示

    private var answerDisplay: some View {
        VStack(spacing: 8) {
            Text("你的答案")
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)

            Text(userAnswerDisplay)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(selectedNoteName == nil ? AppColors.secondaryText : AppColors.primary)
                .frame(minHeight: 44)
                .animation(.easeInOut(duration: 0.2), value: selectedNoteName)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 反馈

    private var feedbackView: some View {
        VStack(spacing: 8) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(isCorrect ? AppColors.success : AppColors.error)

            Text(isCorrect ? "正确！" : "错误")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(isCorrect ? AppColors.success : AppColors.error)

            if !isCorrect {
                Text("正确答案是 \(targetNoteName)")
                    .font(.body)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            (isCorrect ? AppColors.success : AppColors.error).opacity(0.08)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 业务逻辑

    private func generateNewQuestion() {
        showFeedback = false
        selectedNoteName = nil
        selectedAccidental = .natural

        let index = Int.random(in: 0..<whiteKeyMIDIs.count)
        targetNote = whiteKeyMIDIs[index]
        targetNoteName = whiteKeyNotes[index]
        targetOctave = 4

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            playQuestion()
        }
    }

    private func playQuestion() {
        Task {
            await AudioEngineManager.shared.playMIDI(referenceNote, duration: 0.8)
            try? await Task.sleep(nanoseconds: 600_000_000)
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

        let userMIDI = midiNoteFromAnswer(note: userNote, accidental: selectedAccidental, octave: 4)
        isCorrect = (userMIDI == targetNote)
        questionCount += 1

        if isCorrect {
            correctCount += 1
        }

        showFeedback = true

        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .medium : .heavy)
        generator.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if questionCount >= totalQuestions {
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

    private func midiNoteFromAnswer(note: String, accidental: PianoKeyboardView.AccidentalState, octave: Int) -> Int {
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
        SingleNoteListeningView(
            module: .noteName,
            viewModel: PracticeViewModel()
        )
    }
}
