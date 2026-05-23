import SwiftUI

// MARK: - Tab 3 测试中心 (匹配 v0 原型: 标题28px + 3列统计卡片 + 可用测试列表)
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
                // === 页面标题 28px bold + 副标题 ===
                VStack(alignment: .leading, spacing: 4) {
                    Text("测试中心")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("轻松视唱练耳，自由畅快弹唱")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // === 统计卡片 grid-cols-3 gap-3 ===
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    TestStatCard(
                        icon: "trophy.fill",
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
                        icon: "clock.fill",
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
                .clipShape(RoundedRectangle(cornerRadius: 14))   // rounded-2xl
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))  // border-border
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
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)  // 固定尺寸确保图标可见
            
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

// MARK: - 测试行 (匹配 v0: title+badge + info + chevron-right)
struct TestRowView: View {
    let test: TestItemData
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // 左侧信息 flex-1 min-w-0
                VStack(alignment: .leading, spacing: 4) {
                    // 标题 + 分类标签
                    HStack(spacing: 6) {
                        Text(test.title)
                            .font(.system(size: 15, weight: .medium))   // text-[15px] font-medium
                            .foregroundStyle(AppTheme.primaryText)
                        
                        // 分类标签 px-2 py-0.5 bg-secondary rounded-full text-[11px]
                        Text(test.category)
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.secondaryText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppTheme.mutedBackground)
                            .clipShape(Capsule())
                    }
                    
                    // 信息行 text-[13px] gap-3
                    HStack(spacing: 10) {
                                Text("\(test.questionCount) 题")
                                    .font(.system(size: 13))
                                    .foregroundStyle(AppTheme.secondaryText)
                                
                                Text("\(test.timeLimit) 分钟")
                                    .font(.system(size: 13))
                                    .foregroundStyle(AppTheme.secondaryText)
                                
                                if let best = test.bestScore {
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
            .padding(.vertical, 12)             // py-3
        }
        .buttonStyle(IOSPressStyle())
    }
}

// MARK: - 测试容器视图 (匹配 v0 test-session: ExerciseLayout + AudioPromptCard + ChoiceList)
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

    var body: some View {
        ZStack {
            if isCompleted {
                TestResultView(
                    score: score,
                    correctCount: correctCount,
                    totalQuestions: questions.count,
                    timeSpent: Int(Date().timeIntervalSince(startTime) / 60),
                    onViewAnalysis: {},
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
                    onBack: { dismiss() },
                    onNewQuestion: {
                        if showResult { nextQuestion() }
                    },
                    onReplay: {
                        playCurrentAudio()
                    },
                    replayLabel: "重听"
                ) {
                    VStack(spacing: 16) {
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
            }
        }
    }

    private func playCurrentAudio() {
        guard let q = currentTestQuestion else { return }
        // 根据维度播放对应音频
        if let module = q.dimensionValue {
            switch module {
            case .chord:
                ExerciseSoundPlayer.playTriadQuality(TriadQuality.random)
            case .interval:
                if let interval = MusicTheoryInterval.allCases.randomElement() {
                    ExerciseSoundPlayer.playInterval(interval)
                }
            case .noteName:
                if let note = QuestionBank.noteNameQuestions.randomElement() {
                    ExerciseSoundPlayer.playStandardSequence(noteName: "\(note.noteName)\(note.octave)")
                }
            default:
                ExerciseSoundPlayer.playReference()
            }
        }
    }

    private func handleSelect(_ option: String) {
        guard !showResult else { return }
        selectedOption = option
        showResult = true
        if option == correctAnswer {
            correctCount += 1
            score += 10
        }
    }

    private func nextQuestion() {
        let totalQuestions = questions.count
        if currentQuestion >= totalQuestions {
            withAnimation { isCompleted = true }
        } else {
            currentQuestion += 1
            selectedOption = nil
            showResult = false
            if currentQuestion <= totalQuestions {
                currentTestQuestion = questions[currentQuestion - 1]
            }
        }
    }
}

// MARK: - 测试结果
struct TestResultView: View {
    let score: Int; let correctCount: Int; let totalQuestions: Int; let timeSpent: Int
    let onViewAnalysis: () -> Void; let onBack: () -> Void
    
    private var scoreColor: Color {
        score >= 85 ? AppTheme.success : (score >= 60 ? AppTheme.warning : AppTheme.error)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)
                Text("🎉").font(.system(size: 40))
                Text("测试完成!").font(.system(size: 20, weight: .bold)).foregroundStyle(AppTheme.primaryText)
                HStack(spacing: 20) {
                    VStack(spacing: 4) { Text("\(score)").font(.system(size: 48, weight: .bold)).foregroundStyle(scoreColor); Text("总分").font(.system(size: 12)).foregroundStyle(AppTheme.secondaryText) }
                    Rectangle().fill(AppTheme.border).frame(width: 1, height: 60)
                    VStack(spacing: 4) { Text("\(correctCount)/\(totalQuestions)").font(.system(size: 24, weight: .bold)).foregroundStyle(AppTheme.accent); Text("正确题数").font(.system(size: 12)).foregroundStyle(AppTheme.secondaryText) }
                    Rectangle().fill(AppTheme.border).frame(width: 1, height: 60)
                    VStack(spacing: 4) { Text("\(timeSpent)分钟").font(.system(size: 24, weight: .bold)).foregroundStyle(AppTheme.primaryText); Text("用时").font(.system(size: 12)).foregroundStyle(AppTheme.secondaryText) }
                }.padding(20).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16)).shadow(color: .black.opacity(0.08), radius: 8)
                VStack(spacing: 10) {
                    Button(action: onViewAnalysis) { Text("查看解析").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 13).background(AppTheme.accent).clipShape(RoundedRectangle(cornerRadius: 13)) }
                    Button(action: onBack) { Text("返回").font(.system(size: 14)).foregroundStyle(AppTheme.primaryText).frame(maxWidth: .infinity).padding(.vertical, 12).background(AppTheme.mutedBackground).clipShape(RoundedRectangle(cornerRadius: 13)) }
                }; Spacer()
            }.padding(16)
        }
    }
}

#Preview { TestTab() }
