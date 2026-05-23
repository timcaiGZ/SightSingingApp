import SwiftUI

// MARK: - Tab 3 测试 (标题34px + 3列统计卡片 + 可用测试列表)
struct TestTab: View {
    @State private var selectedTest: TestItemData?
    
    // 统计
    private var completedCount: Int { TestItemData.allTests.filter { $0.isCompleted }.count }
    private var averageScore: Int {
        let scores = TestItemData.allTests.compactMap { $0.bestScore }
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / scores.count
    }
    
    var body: some View {
        NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                // === 页面标题 34px bold + 副标题 ===
                VStack(alignment: .leading, spacing: 4) {
                    Text("测试")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("轻松视唱练耳，自由畅快弹唱")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // === 统计卡片 grid-cols-3 gap-3 ===
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    TestStatCard(
                        icon: "trophy",
                        value: "\(completedCount)",
                        label: "已完成",
                        color: AppTheme.warning
                    )
                    TestStatCard(
                        icon: "target",
                        value: "\(averageScore)%",
                        label: "平均分",
                        color: AppTheme.success
                    )
                    TestStatCard(
                        icon: "clock",
                        value: "45",
                        label: "分钟",
                        color: AppTheme.accent
                    )
                }
                .padding(.horizontal, 16)
                
                // === 可用测试列表 bg-card rounded-2xl border ===
                VStack(alignment: .leading, spacing: 0) {
                    // 列表标题 px-4 py-3 border-b
                    HStack {
                        Text("可用测试")
                            .font(.system(size: 15, weight: .semibold))   // text-[15px] font-semibold
                            .foregroundStyle(AppTheme.primaryText)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    // 分割线
                    Rectangle().fill(AppTheme.border).frame(height: 0.5)
                    
                    // 测试行 divide-y
                    VStack(spacing: 0) {
                        ForEach(Array(TestItemData.allTests.enumerated()), id: \.element.id) { index, test in
                            TestRowView(test: test) {
                                selectedTest = test
                            }
                            if index < TestItemData.allTests.count - 1 {
                                Rectangle().fill(AppTheme.border).frame(height: 0.5)
                            }
                        }
                    }
                }
                .background(Color.white)       // bg-card
                .clipShape(RoundedRectangle(cornerRadius: 16))   // rounded-2xl
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 0.5))  // border-border
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 24)
        }
        .background(AppTheme.background)
        .navigationDestination(item: $selectedTest) { test in
            TestContainerView(test: test)
        }
        }  // NavigationStack
    }
}

// MARK: - 统计卡片 (匹配 v0: bg-card rounded-xl border p-3 text-center)
struct TestStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))  // text-[20px] font-bold
                .foregroundStyle(AppTheme.primaryText)
            
            Text(label)
                .font(.system(size: 11))     // text-[11px]
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)              // p-3
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))   // rounded-xl
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 0.5))
    }
}

// MARK: - 测试行 (匹配 v0: 图标+title+badge + info + chevron-right)
struct TestRowView: View {
    let test: TestItemData
    let onTap: () -> Void
    
    /// 每个测试的图标 (使用确定存在的 SF Symbol)
    private var testIcon: String {
        switch test.id {
        case "basic-theory": return "book"              // BookOpen
        case "interval-test": return "ear"               // Ear
        case "chord-test": return "music.note"           // Music → music.note (确定存在)
        case "rhythm-test": return "metronome"           // Drum → metronome (确定存在)
        case "sight-singing-test": return "mic"           // Mic
        default: return "doc.text"
        }
    }
    
    private var testIconBgColor: Color {
        switch test.id {
        case "basic-theory": return Color(hex: "3B82F6")   // blue-500
        case "interval-test": return Color(hex: "8B5CF6")   // purple-500
        case "chord-test": return Color(hex: "EC4899")      // pink-500
        case "rhythm-test": return Color(hex: "F97316")     // orange-500
        case "sight-singing-test": return Color(hex: "22C55E") // green-500
        default: return AppTheme.accent
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {  // v0: items-center + 左对齐
                // === 左侧彩色图标 w-14 h-14 rounded-xl (v0: flex-shrink-0) ===
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(testIconBgColor)
                        .frame(width: 56, height: 56)
                    Image(systemName: testIcon)
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                }
                .frame(width: 56, height: 56)
                
                // 中间信息 flex-1 min-w-0
                VStack(alignment: .leading, spacing: 4) {
                    // 标题 + 分类标签
                    HStack(spacing: 6) {
                        Text(test.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryText)
                        
                        Text(test.category)
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.secondaryText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppTheme.secondaryBg)
                            .clipShape(Capsule())
                    }
                    
                    // 信息行 (v0 单行: X题 · Y分钟 · 最高Z分)
                    HStack(spacing: 4) {
                        Text("\(test.questionCount) 题")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                        Text("·")
                            .foregroundStyle(AppTheme.tertiaryText)
                        Text("\(test.timeLimit) 分钟")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                        if let best = test.bestScore {
                            Text("·")
                                .foregroundStyle(AppTheme.tertiaryText)
                            Text("最高 \(best) 分")
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.success)
                        }
                    }
                }
                
                // 右箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)   // py-4 (v0)
            .frame(maxWidth: .infinity, alignment: .leading)  // w-full text-left
        }
        .buttonStyle(IOSPressStyle())
    }
}

// MARK: - 测试容器视图 (四级页面：匹配 v0 test-session + 设计文档 ExerciseResultPage)
struct TestContainerView: View {
    let test: TestItemData
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestion = 1
    @State private var correctCount = 0
    @State private var score = 0
    @State private var isCompleted = false
    @State private var selectedOption: String?
    @State private var showResult = false
    @State private var startTime = Date()
    @State private var comboCount = 0
    @State private var maxCombo = 0
    @State private var answeredCount = 0

    // TestEngine 生成的题目
    @State private var questions: [TestQuestion] = []
    @State private var currentTestQuestion: TestQuestion?

    private var currentOptions: [String] {
        currentTestQuestion?.options.map(\.label) ?? []
    }
    private var correctAnswer: String {
        guard let q = currentTestQuestion, q.correctAnswerIndex < q.options.count else { return "" }
        return q.options[q.correctAnswerIndex].label
    }
    private var questionPrompt: String {
        currentTestQuestion?.prompt ?? "请听辨音频，选择正确的答案。"
    }
    private var elapsedMinutes: Int {
        max(1, Int(Date().timeIntervalSince(startTime) / 60))
    }

    var body: some View {
        ZStack {
            if isCompleted {
                TestResultView(
                    score: score,
                    correctCount: correctCount,
                    totalQuestions: questions.count,
                    timeSpent: elapsedMinutes,
                    maxCombo: maxCombo,
                    onRetry: { resetAndStart() },
                    onBack: { dismiss() }
                )
            } else {
                ExerciseLayout(
                    title: test.title,
                    questionNumber: currentQuestion,
                    totalQuestions: questions.count,
                    questionText: questionPrompt,
                    score: score,
                    showDecompose: false,
                    onBack: {
                        dismiss()
                    },
                    onNewQuestion: {
                        // "新问题"按钮：跳过当前题（计为错误）
                        if !showResult {
                            handleSkip()
                        }
                    },
                    onReplay: {
                        playCurrentAudio()
                    },
                    replayLabel: "重听"
                ) {
                    VStack(spacing: 16) {
                        // 连击显示
                        if comboCount > 1 {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppTheme.warning)
                                Text("连击 \(comboCount)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppTheme.warning)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.warning.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        
                        AudioPromptCard(
                            label: "点击播放",
                            hint: "听辨音频",
                            onPlay: { playCurrentAudio() }
                        )

                        ChoiceList(
                            options: currentOptions,
                            selectedOption: selectedOption,
                            correctAnswer: correctAnswer,
                            showResult: showResult,
                            onSelect: { option in handleSelect(option) },
                            onNext: nextQuestion
                        )
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .onAppear {
            startTime = Date()
            questions = TestEngine.generateDiagnosticTest()
            if !questions.isEmpty {
                currentTestQuestion = questions[0]
                // 自动播放第一题
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    playCurrentAudio()
                }
            }
        }
    }

    // MARK: - 根据题目类型播放正确音频
    
    private func playCurrentAudio() {
        guard let q = currentTestQuestion, let module = q.dimensionValue else { return }
        
        // 使用题目的 audioNote 数据播放实际音频
        let audioNote = q.audioNote
        
        switch module {
        case .noteName:
            // audioNote 是简谱数字，需要转换为音名
            let solfegeToNote: [String: String] = ["1": "C", "2": "D", "3": "E", "4": "F", "5": "G", "6": "A", "7": "B"]
            let noteName = solfegeToNote[audioNote] ?? "C"
            if let question = QuestionBank.noteNameQuestions.first(where: { $0.noteName == noteName }) {
                ExerciseSoundPlayer.playStandardSequence(noteName: "\(question.noteName)\(question.octave)")
            } else {
                ExerciseSoundPlayer.playNote(name: noteName)
            }
            
        case .interval:
            // audioNote 是音程简称，如 "M2", "m3", "P5"
            if let intervalQuestion = QuestionBank.intervalQuestions.first(where: { $0.shortName == audioNote }) {
                let interval = MusicTheoryInterval.allCases.first {
                    $0.semitones == intervalQuestion.semitones
                }
                if let interval = interval {
                    ExerciseSoundPlayer.playInterval(interval)
                }
            } else {
                ExerciseSoundPlayer.playInterval(.majorSecond)
            }
            
        case .chord:
            // audioNote 是和弦名，如 "C", "Am"
            let chordName = audioNote.replacingOccurrences(of: "(大横按)", with: "")
            if let chord = MusicTheory.openChords.first(where: { $0.name == chordName }) {
                ExerciseSoundPlayer.playChordNamed(chord.name)
            } else {
                ExerciseSoundPlayer.playTriadQuality(TriadQuality.random)
            }
            
        case .scale:
            if let question = QuestionBank.scaleQuestions.first(where: { $0.name == audioNote }) {
                let solfegeToNote: [String: String] = ["1": "C", "2": "D", "3": "E", "4": "F", "5": "G", "6": "A", "7": "B"]
                let noteName = solfegeToNote[question.root] ?? "C"
                ExerciseSoundPlayer.playNote(name: noteName)
            } else {
                ExerciseSoundPlayer.playReference()
            }
            
        case .melody, .rhythm:
            ExerciseSoundPlayer.playReference()
        }
    }

    private func handleSelect(_ option: String) {
        guard !showResult else { return }
        selectedOption = option
        showResult = true
        answeredCount += 1
        
        if option == correctAnswer {
            correctCount += 1
            score += 10
            comboCount += 1
            maxCombo = max(maxCombo, comboCount)
        } else {
            comboCount = 0
        }
    }
    
    private func handleSkip() {
        // 跳过当前题，计为未作答
        comboCount = 0
        nextQuestion()
    }

    private func nextQuestion() {
        let totalQuestions = questions.count
        if currentQuestion >= totalQuestions {
            withAnimation(.easeInOut(duration: 0.3)) { isCompleted = true }
        } else {
            currentQuestion += 1
            selectedOption = nil
            showResult = false
            if currentQuestion <= totalQuestions {
                currentTestQuestion = questions[currentQuestion - 1]
                // 自动播放下一题
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playCurrentAudio()
                }
            }
        }
    }
    
    private func resetAndStart() {
        currentQuestion = 1
        correctCount = 0
        score = 0
        isCompleted = false
        selectedOption = nil
        showResult = false
        comboCount = 0
        maxCombo = 0
        answeredCount = 0
        startTime = Date()
        questions = TestEngine.generateDiagnosticTest()
        if !questions.isEmpty {
            currentTestQuestion = questions[0]
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                playCurrentAudio()
            }
        }
    }
}

// MARK: - 测试结果页 (匹配设计文档 ExerciseResultPage)
struct TestResultView: View {
    let score: Int
    let correctCount: Int
    let totalQuestions: Int
    let timeSpent: Int
    let maxCombo: Int
    let onRetry: () -> Void
    let onBack: () -> Void
    
    private var percentage: Int {
        Int(Double(correctCount) / Double(totalQuestions) * 100)
    }
    
    private var gradeText: String {
        if percentage >= 90 { return "太棒了！完美表现！" }
        if percentage >= 80 { return "做得很好！继续保持！" }
        if percentage >= 60 { return "不错！还有进步空间！" }
        return "继续加油！熟能生巧！"
    }
    
    private var gradeColor: Color {
        if percentage >= 80 { return AppTheme.success }
        if percentage >= 60 { return AppTheme.warning }
        return AppTheme.error
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // === 标题 ===
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(gradeColor.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Text("🏆")
                            .font(.system(size: 40))
                    }
                    
                    Text("测试完成")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                    
                    Text(gradeColor == AppTheme.success ? "太棒了！完美表现！" : gradeText)
                        .font(.system(size: 15))
                        .foregroundStyle(gradeColor)
                }
                .padding(.top, 20)
                
                // === 成绩统计卡片 ===
                VStack(spacing: 16) {
                    // 正确率
                    statsRow(icon: "checkmark.circle.fill", iconColor: AppTheme.success, value: "\(correctCount)/\(totalQuestions)", label: "正确率", detail: "\(percentage)%")
                    
                    Divider()
                    
                    // 最高连击
                    statsRow(icon: "flame.fill", iconColor: AppTheme.warning, value: "\(maxCombo) 题", label: "最高连击", detail: maxCombo > 0 ? "连续答对 \(maxCombo) 题" : "未产生连击")
                    
                    Divider()
                    
                    // 用时
                    statsRow(icon: "clock.fill", iconColor: AppTheme.accent, value: "\(timeSpent) 分钟", label: "用时", detail: "共 \(max(1, timeSpent)) 分钟完成测试")
                }
                .padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                // === 分数等级色条 ===
                VStack(spacing: 8) {
                    HStack {
                        Text("分数等级")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.secondaryText)
                        Spacer()
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppTheme.mutedBackground)
                                .frame(height: 10)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(gradeColor)
                                .frame(width: max(4, geo.size.width * Double(percentage) / 100), height: 10)
                        }
                    }
                    .frame(height: 10)
                    
                    Text(gradeText)
                        .font(.system(size: 13))
                        .foregroundStyle(gradeColor)
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
                
                // === 操作按钮 ===
                VStack(spacing: 12) {
                    Button(action: onRetry) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16, weight: .semibold))
                            Text("再练一次")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onBack) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14))
                            Text("返回测试列表")
                                .font(.system(size: 15))
                        }
                        .foregroundStyle(AppTheme.secondaryText)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 8)
                }
            }
            .padding(.horizontal, 16)
        }
        .background(AppTheme.background)
    }
    
    @ViewBuilder
    private func statsRow(icon: String, iconColor: Color, value: String, label: String, detail: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(value)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    
                    Text(label)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.tertiaryText)
            }
            
            Spacer()
        }
    }
}

#Preview { TestTab() }
