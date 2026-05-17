import Foundation
import SwiftUI
import SwiftData

/// 测试 Tab ViewModel
@Observable
final class TestViewModel {
    private var modelContext: ModelContext?

    /// 测试状态
    enum TestState {
        case idle          // 初始状态
        case inProgress   // 测试进行中
        case showingResult // 显示结果
    }

    var state: TestState = .idle
    var currentQuestionIndex: Int = 0
    var questions: [TestQuestion] = []
    var answers: [UUID: Int] = [:]       // questionID: selectedIndex
    var responseTimes: [UUID: Double] = [:]  // questionID: responseTime (秒)
    var currentQuestionStartTime: Date = Date()
    var result: TestResult?
    var showingTestIntro: Bool = false

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    /// 开始新测试
    func startTest() {
        questions = TestEngine.generateDiagnosticTest()
        answers = [:]
        responseTimes = [:]
        currentQuestionIndex = 0
        currentQuestionStartTime = Date()
        result = nil
        state = .inProgress
        showingTestIntro = false
    }

    /// 选择答案
    func selectAnswer(questionID: UUID, answerIndex: Int) {
        let elapsed = Date().timeIntervalSince(currentQuestionStartTime)
        answers[questionID] = answerIndex
        responseTimes[questionID] = elapsed

        // 延迟 0.5 秒后进入下一题
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.nextQuestion()
        }
    }

    /// 下一题
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            currentQuestionStartTime = Date()
        } else {
            finishTest()
        }
    }

    /// 完成测试，计算结果
    func finishTest() {
        result = TestEngine.calculateResult(
            questions: questions,
            answers: answers,
            responseTimes: responseTimes
        )
        state = .showingResult

        // 保存到历史记录
        saveToHistory()
    }

    /// 当前题目
    var currentQuestion: TestQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    /// 进度
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }

    /// 提交答案后是否正确
    func isCorrect(questionID: UUID) -> Bool? {
        guard let selected = answers[questionID],
              let question = questions.first(where: { $0.id == questionID }) else {
            return nil
        }
        return selected == question.correctAnswerIndex
    }

    /// 获取测试历史记录
    func getHistory() -> [TestHistory] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<TestHistory>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    private func saveToHistory() {
        guard let context = modelContext, let result = result else { return }
        let history = TestHistory(
            totalScore: result.totalScore,
            dimensionScores: Dictionary(
                uniqueKeysWithValues: result.dimensionScores.map { ($0.key, $0.value.score) }
            ),
            recommendations: result.recommendations,
            totalDurationSeconds: result.totalDurationSeconds
        )
        context.insert(history)
        try? context.save()
    }
}
