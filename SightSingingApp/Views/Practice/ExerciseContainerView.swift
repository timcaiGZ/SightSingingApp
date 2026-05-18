import SwiftUI
import AVFoundation

/// 练习模式
enum ExerciseMode: String, CaseIterable {
    case multipleChoice = "选择题"
    case keyboardInput = "键盘输入"
    case sightSinging = "视唱"
    
    var icon: String {
        switch self {
        case .multipleChoice: return "list.bullet"
        case .keyboardInput: return "pianokeys"
        case .sightSinging: return "mic.fill"
        }
    }
}

/// 交互模式
enum InteractionMode {
    case multipleChoice(options: [String], correctIndex: Int)
    case keyboardInput
    case sightSinging
}

/// 统一练习容器（参考 Solfeggio 设计）
struct ExerciseContainerView: View {
    let exercise: CourseExercise
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestion: Int = 0
    @State private var score: Int = 0
    @State private var correctCount: Int = 0
    @State private var selectedAnswer: Int?
    @State private var showFeedback: Bool = false
    @State private var isCorrect: Bool = false
    @State private var exerciseMode: ExerciseMode = .multipleChoice
    @State private var isPlaying: Bool = false
    @State private var showResult: Bool = false
    
    // 视唱相关
    @State private var pitchDetector = PitchDetector.shared
    @State private var detectedPitch: String = ""
    @State private var pitchDeviation: Double = 0
    @State private var isRecording: Bool = false
    
    private let totalQuestions = 10
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航
            headerView
            
            Divider()
            
            // 内容区
            contentArea
            
            Divider()
            
            // 操作栏
            actionBar
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            determineExerciseMode()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(AppColors.secondaryText)
                }
                
                Spacer()
                
                Text(exercise.title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(score) 分")
                    .font(.headline)
                    .foregroundStyle(AppColors.accentBlue)
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Content Area
    
    private var contentArea: some View {
        VStack(spacing: 20) {
            // 进度圆点
            progressDots
            
            Spacer()
            
            // 问题内容
            questionContent
            
            // 交互区域
            interactionArea
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    /// 进度圆点
    private var progressDots: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<totalQuestions, id: \.self) { index in
                    Circle()
                        .fill(dotColor(for: index))
                        .frame(width: 8, height: 8)
                }
            }
            
            Text("\(currentQuestion + 1) / \(totalQuestions)")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
    
    private func dotColor(for index: Int) -> Color {
        if index < currentQuestion {
            return AppColors.success
        } else if index == currentQuestion {
            return AppColors.accentBlue
        }
        return Color(.systemGray4)
    }
    
    /// 问题内容
    @ViewBuilder
    private var questionContent: some View {
        VStack(spacing: 16) {
            // 播放按钮
            Button {
                playQuestion()
            } label: {
                ZStack {
                    Circle()
                        .fill(AppColors.accentBlue)
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }
            .disabled(isPlaying)
            
            // 谱式展示区
            notationDisplay
            
            // 问题文字
            Text(exercise.content)
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(4)
        }
    }
    
    /// 谱式展示区
    private var notationDisplay: some View {
        Group {
            switch exercise.type {
            case .theory:
                StaffNotationView(notes: sampleStaffNotes)
            case .singing:
                SolfegeView(notes: sampleSolfegeNotes, highlightedIndex: nil)
            case .earTraining:
                GuitarTablatureView(notes: sampleTabNotes, fretRange: 0...5)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // 示例数据
    private var sampleStaffNotes: [StaffNote] {
        [
            StaffNote(pitch: StaffPitch(line: 0), duration: .quarter, accidental: nil),
            StaffNote(pitch: StaffPitch(line: 2), duration: .quarter, accidental: nil),
            StaffNote(pitch: StaffPitch(line: 4), duration: .quarter, accidental: nil),
        ]
    }
    
    private var sampleSolfegeNotes: [SolfegeNote] {
        [
            SolfegeNote(solfege: "1", octave: 4, duration: .quarter),
            SolfegeNote(solfege: "2", octave: 4, duration: .quarter),
            SolfegeNote(solfege: "3", octave: 4, duration: .quarter),
        ]
    }
    
    /// 当前题目的六线谱音符（五弦2品 = B音）
    private var sampleTabNotes: [GuitarTabNote] {
        [
            GuitarTabNote(string: 5, fret: 2, technique: nil)
        ]
    }
    
    // MARK: - Interaction Area
    
    @ViewBuilder
    private var interactionArea: some View {
        switch exerciseMode {
        case .multipleChoice:
            multipleChoiceView
        case .keyboardInput:
            keyboardInputView
        case .sightSinging:
            sightSingingView
        }
    }
    
    /// 选择题视图
    private var multipleChoiceView: some View {
        VStack(spacing: 10) {
            Text("请选择")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let options = ["C", "D", "E", "G"]
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button {
                    selectAnswer(index)
                } label: {
                    HStack {
                        Text(optionLetter(index))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(optionColor(for: index))
                            .clipShape(Circle())
                        
                        Text(option)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(AppColors.primaryText)
                        
                        Spacer()
                        
                        if selectedAnswer == index {
                            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(isCorrect ? .green : .red)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(optionBackground(for: index))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(selectedAnswer != nil)
            }
        }
    }
    
    private func optionLetter(_ index: Int) -> String {
        let letters = ["A", "B", "C", "D", "E", "F"]
        return index < letters.count ? letters[index] : "\(index + 1)"
    }
    
    private func optionColor(for index: Int) -> Color {
        if selectedAnswer == index {
            return isCorrect ? AppColors.success : AppColors.error
        }
        return AppColors.accentBlue.opacity(0.7)
    }
    
    private func optionBackground(for index: Int) -> Color {
        if selectedAnswer == index && showFeedback {
            return isCorrect ? AppColors.success.opacity(0.1) : AppColors.error.opacity(0.1)
        }
        return Color(.systemBackground)
    }
    
    /// 键盘输入视图（选择即提交，不显示答案）
    private var keyboardInputView: some View {
        VStack(spacing: 16) {
            // 钢琴键盘
            MusicKeyboardView { selectedNote in
                checkKeyboardAnswer(selectedNote)
            }
        }
    }
    
    /// 检查键盘输入答案
    private func checkKeyboardAnswer(_ note: String) {
        // 当前题目正确答案（五弦2品 = B音）
        let correctAnswer = "B"
        let isAnswerCorrect = note == correctAnswer
        
        showFeedback = true
        isCorrect = isAnswerCorrect
        
        if isAnswerCorrect {
            correctCount += 1
            score = Int(Double(correctCount) / Double(currentQuestion + 1) * 100)
        }
        
        let generator = UIImpactFeedbackGenerator(style: isAnswerCorrect ? .medium : .heavy)
        generator.impactOccurred()
        
        // 延迟后进入下一题
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            nextQuestion()
        }
    }
    
    /// 视唱视图
    private var sightSingingView: some View {
        VStack(spacing: 20) {
            // 音准指示器
            PitchMeterView(
                centsDeviation: pitchDeviation,
                isActive: isRecording,
                targetNote: "C"
            )
            .frame(height: 120)
            
            // 目标音显示
            VStack(spacing: 4) {
                Text("目标音")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("C")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.accentBlue)
            }
            
            // 演唱按钮
            Button {
                toggleRecording()
            } label: {
                HStack {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    Text(isRecording ? "停止" : "按着演唱")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isRecording ? AppColors.error : AppColors.accentBlue)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Action Bar
    
    private var actionBar: some View {
        HStack(spacing: 16) {
            Button {
                playQuestion()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("重听")
                }
                .font(.subheadline)
                .foregroundStyle(AppColors.accentBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.accentBlue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                nextQuestion()
            } label: {
                HStack {
                    Text("下一题")
                    Image(systemName: "arrow.right")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.accentBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Actions
    
    private func determineExerciseMode() {
        switch exercise.type {
        case .theory:
            exerciseMode = .multipleChoice
        case .earTraining:
            exerciseMode = .keyboardInput
        case .singing:
            exerciseMode = .sightSinging
        }
    }
    
    private func playQuestion() {
        isPlaying = true
        // 播放音频
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            isPlaying = false
        }
    }
    
    private func selectAnswer(_ index: Int) {
        selectedAnswer = index
        // 假设第一个选项正确
        isCorrect = index == 0
        showFeedback = true
        
        if isCorrect {
            correctCount += 1
            score = Int(Double(correctCount) / Double(currentQuestion + 1) * 100)
        }
        
        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .medium : .heavy)
        generator.impactOccurred()
        
        // 震动反馈
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            nextQuestion()
        }
    }
    
    private func nextQuestion() {
        if currentQuestion >= totalQuestions - 1 {
            showResult = true
            dismiss()
        } else {
            currentQuestion += 1
            selectedAnswer = nil
            showFeedback = false
        }
    }
    
    private func toggleRecording() {
        isRecording.toggle()
        if isRecording {
            pitchDetector.startDetection()
        } else {
            pitchDetector.stopDetection()
        }
    }
}

#Preview {
    ExerciseContainerView(exercise: CourseExercise(
        id: "preview",
        title: "音名识别",
        type: .theory,
        difficulty: 1,
        description: "识别音名",
        content: "请选择你听到的音名"
    ))
}
