import SwiftUI

/// 练习容器视图 - 统一练习界面
struct ExerciseContainerView: View {
    let exercise: ExerciseItem
    let moduleId: String
    
    @AppStorage("notationType") private var globalNotationType: String = "guitar-tab"
    @State private var localNotationType: String = "guitar-tab"
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentQuestion = 0
    @State private var correctCount = 0
    @State private var isCompleted = false
    
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
    
    // 模拟数据
    private let mockOptions = ["大三和弦", "小三和弦", "增三和弦", "减三和弦"]
    private let correctAnswer = "大三和弦"
    private let mockNote = "E4"
    
    private var currentNotationType: String {
        localNotationType.isEmpty ? globalNotationType : localNotationType
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 顶部导航
                HStack {
                    Button("← 返回") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.accent)
                    
                    Spacer()
                    
                    Text("\(currentQuestion + 1) / \(exercise.totalQuestions)")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .padding(16)
                .background(Color.white)
                
                // 进度指示
                ProgressDotsRow(total: exercise.totalQuestions, current: currentQuestion)
                
                if isCompleted {
                    // 练习完成态
                    ExerciseCompletionView(
                        correctCount: correctCount,
                        totalQuestions: exercise.totalQuestions,
                        onRetry: {
                            resetExercise()
                        },
                        onBack: {
                            dismiss()
                        }
                    )
                } else {
                    // 练习内容
                    ScrollView {
                        VStack(spacing: 16) {
                            // 谱式切换器
                            NotationSwitcherView(
                                selectedNotation: $localNotationType,
                                globalNotation: globalNotationType
                            )
                            
                            // 题目提示
                            Text("Q\(currentQuestion + 1)：\(questionText)")
                                .font(.system(size: 14))
                                .foregroundStyle(AppTheme.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // 根据模式渲染不同内容
                            switch exercise.mode {
                            case .multipleChoice:
                                MultipleChoiceContent(
                                    options: mockOptions,
                                    selectedOption: $selectedOption,
                                    showResult: $showResult,
                                    correctAnswer: correctAnswer,
                                    onAnswer: { answer in
                                        if answer == correctAnswer {
                                            correctCount += 1
                                        }
                                        selectedOption = answer
                                        showResult = true
                                    }
                                )
                                
                            case .keyboardInput:
                                KeyboardInputContent(
                                    inputNotes: $inputNotes,
                                    accidental: $keyboardAccidental,
                                    notationType: currentNotationType,
                                    correctAnswer: mockNote,
                                    onSubmit: { isCorrect in
                                        if isCorrect {
                                            correctCount += 1
                                        }
                                    }
                                )
                                
                            case .sightSinging:
                                SightSingingContent(
                                    phase: $sightSingingPhase,
                                    cents: $currentCents,
                                    targetNote: mockNote,
                                    onComplete: { p, r in
                                        pitchScore = p
                                        rhythmScore = r
                                        correctCount += 1
                                    }
                                )
                            }
                        }
                        .padding(16)
                    }
                    
                    // 底部操作栏
                    ExerciseActionBar(
                        mode: exercise.mode,
                        showResult: showResult || sightSingingPhase == .done,
                        onNewQuestion: { nextQuestion() },
                        showDecompose: exercise.mode.showDecompose,
                        onReplay: { /* 重听 */ }
                    )
                }
            }
            .background(AppTheme.background)
        }
        .navigationBarHidden(true)
        .onAppear {
            localNotationType = globalNotationType
        }
    }
    
    private var questionText: String {
        switch exercise.mode {
        case .multipleChoice:
            return "请听音频判断\(exercise.title)"
        case .keyboardInput:
            return "请输入音符名称"
        case .sightSinging:
            return "请演唱指定音符"
        }
    }
    
    private func nextQuestion() {
        if currentQuestion + 1 >= exercise.totalQuestions {
            withAnimation {
                isCompleted = true
            }
        } else {
            currentQuestion += 1
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
    }
    
    private func resetExercise() {
        currentQuestion = 0
        correctCount = 0
        isCompleted = false
        resetQuestionState()
    }
}

// MARK: - 谱式切换器
struct NotationSwitcherView: View {
    @Binding var selectedNotation: String
    let globalNotation: String
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(["guitar-tab", "staff"], id: \.self) { notation in
                Button {
                    selectedNotation = notation
                } label: {
                    Text(notation == "guitar-tab" ? "六线谱+简谱" : "五线谱")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(selectedNotation == notation ? .white : AppTheme.secondaryText)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(selectedNotation == notation ? AppTheme.primary : Color.clear)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(3)
        .background(AppTheme.mutedBackground)
        .clipShape(Capsule())
    }
}

// MARK: - 选择题内容
struct MultipleChoiceContent: View {
    let options: [String]
    @Binding var selectedOption: String?
    @Binding var showResult: Bool
    let correctAnswer: String
    let onAnswer: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    if !showResult {
                        onAnswer(option)
                    }
                } label: {
                    MCOptionView(
                        text: option,
                        isSelected: selectedOption == option,
                        isCorrect: showResult && option == correctAnswer,
                        isWrong: showResult && selectedOption == option && option != correctAnswer,
                        showResult: showResult
                    )
                }
                .buttonStyle(.plain)
                .disabled(showResult)
                
                if option != options.last {
                    Rectangle()
                        .fill(AppTheme.border)
                        .frame(height: 1)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - 键盘输入内容
struct KeyboardInputContent: View {
    @Binding var inputNotes: [String]
    @Binding var accidental: String
    let notationType: String
    let correctAnswer: String
    let onSubmit: (Bool) -> Void
    
    @State private var isSubmitted = false
    @State private var isCorrect = false
    
    private let notes = ["C", "D", "E", "F", "G", "A", "B"]
    private let accidentals = ["—", "♯", "♭"]
    
    var body: some View {
        VStack(spacing: 12) {
            // 谱面显示区
            NotationDisplayPreviewView(
                notes: inputNotes,
                notationType: notationType,
                isCorrect: isCorrect,
                showResult: isSubmitted
            )
            
            // 已输入音符
            HStack {
                Text(inputNotes.isEmpty ? "请输入音符..." : inputNotes.joined())
                    .font(.system(size: 13))
                    .foregroundStyle(inputNotes.isEmpty ? AppTheme.secondaryText : (isSubmitted ? (isCorrect ? AppTheme.success : AppTheme.error) : AppTheme.primaryText))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isSubmitted {
                    Text(isCorrect ? "✓ 正确" : "✗ 错误")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isCorrect ? AppTheme.success : AppTheme.error)
                }
            }
            .padding(11)
            .background(AppTheme.mutedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 11))
            
            // 升降号选择
            HStack(spacing: 6) {
                ForEach(accidentals, id: \.self) { acc in
                    Button {
                        accidental = acc
                    } label: {
                        Text(acc)
                            .font(.system(size: accidental == acc ? 13 : 11, weight: .semibold))
                            .foregroundStyle(accidental == acc ? .white : AppTheme.primaryText)
                            .frame(width: 38, height: 38)
                            .background(accidental == acc ? AppTheme.primary : AppTheme.mutedBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.border, lineWidth: 1.5)
                            }
                    }
                }
                
                Spacer()
            }
            
            // 音符键盘
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 4), spacing: 5) {
                ForEach(notes, id: \.self) { note in
                    Button {
                        if !isSubmitted {
                            let fullNote = accidental == "—" ? note : accidental + note
                            inputNotes.append(fullNote)
                            accidental = "—"
                        }
                    } label: {
                        Text(note)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(isSubmitted ? AppTheme.tertiaryText : AppTheme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                    }
                    .disabled(isSubmitted)
                }
                
                // 退格
                Button {
                    if !inputNotes.isEmpty && !isSubmitted {
                        inputNotes.removeLast()
                    }
                } label: {
                    Text("⌫")
                        .font(.system(size: 16))
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(AppTheme.mutedBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                        .overlay {
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(AppTheme.border, lineWidth: 1)
                        }
                }
                
                // 完成
                Button {
                    if !inputNotes.isEmpty && !isSubmitted {
                        isSubmitted = true
                        isCorrect = inputNotes.joined() == correctAnswer
                        onSubmit(isCorrect)
                    }
                } label: {
                    Text("完成")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(inputNotes.isEmpty ? AppTheme.tertiaryText : AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                }
                .disabled(inputNotes.isEmpty || isSubmitted)
            }
        }
    }
}

// MARK: - 谱面预览
struct NotationDisplayPreviewView: View {
    let notes: [String]
    let notationType: String
    let isCorrect: Bool
    let showResult: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 13)
            .fill(Color.white)
            .frame(height: 80)
            .overlay {
                if notes.isEmpty {
                    Text("谱面预览")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.tertiaryText)
                } else {
                    Text(notes.joined())
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(showResult ? (isCorrect ? AppTheme.success : AppTheme.error) : AppTheme.primary)
                }
            }
    }
}

// MARK: - 视唱内容
struct SightSingingContent: View {
    @Binding var phase: ExerciseContainerView.SightSingingPhase
    @Binding var cents: Double
    let targetNote: String
    let onComplete: (Int, Int) -> Void
    
    @State private var timer: Timer?
    
    private var cursorColor: Color {
        let absCents = abs(cents)
        if absCents <= 10 { return AppTheme.success }
        if absCents <= 20 { return AppTheme.warning }
        return AppTheme.error
    }
    
    private var feedbackText: String {
        let absCents = abs(cents)
        if phase == .idle { return "等待演唱..." }
        if absCents <= 10 { return "音准良好!" }
        return cents < 0 ? "偏低 \(Int(absCents)) 音分" : "偏高 \(Int(absCents)) 音分"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 目标音符
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("请演唱")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.secondaryText)
                    HStack(alignment: .bottom, spacing: 7) {
                        Text(targetNote)
                            .font(.system(size: 50, weight: .bold))
                            .foregroundStyle(AppTheme.primary)
                        Text("Mi · 3")
                            .font(.system(size: 15))
                            .foregroundStyle(AppTheme.secondaryText)
                            .padding(.bottom, 8)
                    }
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(AppTheme.accent.opacity(0.2))
            }
            .padding(13)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 13))
            
            // 音高指示器
            VStack(spacing: 8) {
                Text(phase == .idle ? "—" : targetNote)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)
                
                // 轨道
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景条
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.border)
                            .frame(height: 7)
                        
                        // 绿色区间（居中 1/5）
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.success.opacity(0.3))
                            .frame(width: geometry.size.width * 0.2, height: 7)
                            .position(x: geometry.size.width / 2, y: 3.5)
                        
                        // 游标
                        if phase == .singing {
                            let position = (cents / 50 + 1) / 2
                            Circle()
                                .fill(cursorColor)
                                .frame(width: 18, height: 18)
                                .position(x: min(max(position * geometry.size.width, 9), geometry.size.width - 9), y: 3.5)
                                .shadow(color: cursorColor.opacity(0.3), radius: 4)
                        }
                    }
                }
                .frame(height: 20)
                
                // 标签
                HStack {
                    Text("偏低")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.error)
                    Spacer()
                    Text(feedbackText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(cursorColor)
                    Spacer()
                    Text("偏高")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.error)
                }
            }
            .padding(13)
            .background(AppTheme.mutedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 13))
            
            // 演唱按钮
            Button {
                if phase == .idle {
                    startSinging()
                } else if phase == .singing {
                    stopSinging()
                }
            } label: {
                HStack {
                    if phase == .singing {
                        Image(systemName: "stop.fill")
                    } else {
                        Image(systemName: "mic.fill")
                    }
                    Text(phase == .singing ? "松开结束" : "按住演唱")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(phase == .singing ? AppTheme.error : AppTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
    
    private func startSinging() {
        phase = .singing
        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            cents = Double.random(in: -44...44)
        }
    }
    
    private func stopSinging() {
        timer?.invalidate()
        timer = nil
        phase = .done
        
        // 计算分数
        let absCents = abs(cents)
        let pitch = max(0, 50 - Int(absCents))
        let rhythm = Int.random(in: 35...50)
        onComplete(pitch, rhythm)
    }
}

// MARK: - 练习操作栏
struct ExerciseActionBar: View {
    let mode: ExerciseMode
    let showResult: Bool
    let onNewQuestion: () -> Void
    let showDecompose: Bool
    let onReplay: () -> Void
    
    var body: some View {
        HStack(spacing: 40) {
            Button(action: onNewQuestion) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 20))
                    Text("新问题")
                        .font(.system(size: 11))
                }
                .foregroundStyle(AppTheme.primaryText)
            }
            .opacity(showResult ? 1 : 0.5)
            .disabled(!showResult)
            
            if showDecompose {
                Button(action: {}) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.split.2x1")
                            .font(.system(size: 20))
                        Text("分解")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(AppTheme.primaryText)
                }
            }
            
            Button(action: onReplay) {
                VStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 20))
                    Text(mode == .sightSinging ? "示范" : "重听")
                        .font(.system(size: 11))
                }
                .foregroundStyle(.white)
                .padding(10)
                .background(AppTheme.accent)
                .clipShape(Circle())
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)
        }
    }
}

// MARK: - 练习完成视图
struct ExerciseCompletionView: View {
    let correctCount: Int
    let totalQuestions: Int
    let onRetry: () -> Void
    let onBack: () -> Void
    
    private var accuracy: Int {
        Int((Double(correctCount) / Double(totalQuestions)) * 100)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)
                
                Text("🎉")
                    .font(.system(size: 40))
                
                Text("练习完成!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)
                
                // 结果卡片
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(correctCount)/\(totalQuestions)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppTheme.success)
                        Text("正确")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    
                    Rectangle()
                        .fill(AppTheme.border)
                        .frame(width: 1, height: 50)
                    
                    VStack(spacing: 4) {
                        Text("\(accuracy)%")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppTheme.accent)
                        Text("正确率")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 13))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                
                // 按钮
                VStack(spacing: 10) {
                    Button(action: onRetry) {
                        Text("再来一轮")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(AppTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 13))
                    }
                    
                    Button(action: onBack) {
                        Text("返回")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.mutedBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 13))
                    }
                }
                
                Spacer()
            }
            .padding(16)
        }
    }
}

#Preview {
    ExerciseContainerView(
        exercise: ExerciseItem(id: "chord-hear", title: "和弦辨认", mode: .multipleChoice, percentage: 30),
        moduleId: "hearing"
    )
}
