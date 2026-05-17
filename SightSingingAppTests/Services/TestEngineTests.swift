import XCTest
@testable import SightSingingApp

final class TestEngineTests: XCTestCase {

    func testGenerateDiagnosticTest_Contains30Questions() {
        let questions = TestEngine.generateDiagnosticTest()
        XCTAssertEqual(questions.count, 30, "诊断测试应包含30道题")
    }

    func testGenerateDiagnosticTest_CoversAllDimensions() {
        let questions = TestEngine.generateDiagnosticTest()
        let dimensions = Set(questions.compactMap { $0.dimensionValue })

        for module in ExerciseModule.allCases {
            XCTAssertTrue(dimensions.contains(module), "测试应覆盖 \(module.rawValue) 维度")
        }
    }

    func testGenerateDiagnosticTest_EachDimensionHas5Questions() {
        let questions = TestEngine.generateDiagnosticTest()

        for module in ExerciseModule.allCases {
            let count = questions.filter { $0.dimensionValue == module }.count
            XCTAssertEqual(count, 5, "每个维度应有5道题")
        }
    }

    func testCalculateResult_AllCorrect() {
        let questions = TestEngine.generateDiagnosticTest()
        var answers: [UUID: Int] = [:]
        var responseTimes: [UUID: Double] = [:]

        for question in questions {
            answers[question.id] = question.correctAnswerIndex
            responseTimes[question.id] = 1.0
        }

        let result = TestEngine.calculateResult(
            questions: questions,
            answers: answers,
            responseTimes: responseTimes
        )

        XCTAssertEqual(result.totalScore, 100, "全对时应得100分")
    }

    func testCalculateResult_AllWrong() {
        let questions = TestEngine.generateDiagnosticTest()
        var answers: [UUID: Int] = [:]
        var responseTimes: [UUID: Double] = [:]

        for question in questions {
            // 选一个错误的答案
            let wrongAnswer = (question.correctAnswerIndex + 1) % question.options.count
            answers[question.id] = wrongAnswer
            responseTimes[question.id] = 2.0
        }

        let result = TestEngine.calculateResult(
            questions: questions,
            answers: answers,
            responseTimes: responseTimes
        )

        XCTAssertEqual(result.totalScore, 0, "全错时应得0分")
    }
}
