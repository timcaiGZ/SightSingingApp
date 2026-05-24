import Foundation
import SwiftUI

/// 统一练习会话 —— 独立于具体 View，纯练习流程管理。
///
/// 被 ExerciseContainerView / SingleNoteListeningView / SightSingingView 使用。
/// 替代 ViewModel 中的 `@State currentQuestion/correctCount/isCompleted` 等分散状态。
@Observable
final class PracticeSession: Identifiable {

    // MARK: - Types

    /// 练习阶段
    enum Phase: Equatable {
        case intro
        case demo              // 示范播放
        case waitingToStart
        case practicing        // 用户练习中
        case evaluating        // 计算成绩
        case completed
    }

    /// 答题记录
    struct PracticeAnswer: Identifiable, Sendable {
        let id: UUID
        let questionIndex: Int
        let isCorrect: Bool
        let timingAccuracy: Int       // 0-100
        let pitchAccuracy: Int?       // 视唱才有
        let responseTime: TimeInterval

        init(
            id: UUID = UUID(),
            questionIndex: Int,
            isCorrect: Bool,
            timingAccuracy: Int = 100,
            pitchAccuracy: Int? = nil,
            responseTime: TimeInterval = 0
        ) {
            self.id = id
            self.questionIndex = questionIndex
            self.isCorrect = isCorrect
            self.timingAccuracy = timingAccuracy
            self.pitchAccuracy = pitchAccuracy
            self.responseTime = responseTime
        }
    }

    enum ExerciseType: String, Sendable {
        case singleNoteListening
        case sightSinging
        case chordProgression
        case rhythmPractice
        case theoryQuiz
    }

    // MARK: - Properties

    let id: UUID
    let exerciseType: ExerciseType
    let totalQuestions: Int

    /// 当前阶段
    var phase: Phase = .intro

    /// 当前题目索引 (0-based)
    var currentQuestion: Int = 0

    /// 答题记录
    var answers: [PracticeAnswer] = []

    /// 得分
    var score: PracticeScore?

    /// 本轮已用时间
    private var sessionStartTime: Date?

    // MARK: - Init

    init(
        id: UUID = UUID(),
        exerciseType: ExerciseType,
        totalQuestions: Int = 10
    ) {
        self.id = id
        self.exerciseType = exerciseType
        self.totalQuestions = totalQuestions
    }

    // MARK: - Computed

    var correctCount: Int {
        answers.filter(\.isCorrect).count
    }

    var incorrectCount: Int {
        answers.count - correctCount
    }

    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentQuestion) / Double(totalQuestions)
    }

    var isCompleted: Bool {
        currentQuestion >= totalQuestions
    }

    var accuracy: Double {
        guard !answers.isEmpty else { return 0 }
        return Double(correctCount) / Double(answers.count)
    }

    // MARK: - Lifecycle

    func start() {
        phase = .demo
        sessionStartTime = Date()
        currentQuestion = 0
        answers = []
        score = nil
    }

    func startPracticing() {
        phase = .practicing
    }

    /// 提交一次答题
    func submitAnswer(
        isCorrect: Bool,
        timingAccuracy: Int = 100,
        pitchAccuracy: Int? = nil
    ) {
        let answer = PracticeAnswer(
            questionIndex: currentQuestion,
            isCorrect: isCorrect,
            timingAccuracy: timingAccuracy,
            pitchAccuracy: pitchAccuracy,
            responseTime: Date().timeIntervalSince(sessionStartTime ?? Date())
        )
        answers.append(answer)
    }

    /// 进入下一题
    func nextQuestion() {
        guard !isCompleted else {
            finish()
            return
        }
        currentQuestion += 1
        if currentQuestion >= totalQuestions {
            finish()
        }
    }

    /// 完成练习
    func finish() {
        phase = .evaluating
        score = PracticeScore(from: self)

        // 短暂延迟后标记完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.phase = .completed
        }
    }

    /// 重置练习
    func reset() {
        phase = .intro
        currentQuestion = 0
        answers = []
        score = nil
        sessionStartTime = nil
    }
}
