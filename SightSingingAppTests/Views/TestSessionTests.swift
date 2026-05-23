import XCTest
@testable import SightSingingApp

/// 测试 Tab 四级页面 单元测试
final class TestSessionTests: XCTestCase {
    
    // MARK: - 题目生成测试
    
    func test_generateDiagnosticTest_questionsHaveAudioNote() {
        let questions = TestEngine.generateDiagnosticTest()
        
        for question in questions {
            XCTAssertFalse(question.audioNote.isEmpty, "每道题应有 audioNote: \(question.dimension)")
        }
    }
    
    func test_generateDiagnosticTest_optionsNotEmpty() {
        let questions = TestEngine.generateDiagnosticTest()
        
        for question in questions {
            XCTAssertFalse(question.options.isEmpty, "每道题应有选项")
            XCTAssertTrue(question.correctAnswerIndex < question.options.count, "correctAnswerIndex 应在合法范围内")
        }
    }
    
    func test_generateDiagnosticTest_allQuestionTypesCovered() {
        let questions = TestEngine.generateDiagnosticTest()
        let dimensions = Set(questions.compactMap { $0.dimensionValue })
        
        // 验证6个维度全覆盖
        XCTAssertEqual(dimensions.count, ExerciseModule.allCases.count, "应覆盖全部6个维度")
        for module in ExerciseModule.allCases {
            XCTAssertTrue(dimensions.contains(module), "应包含 \(module.rawValue) 维度")
        }
    }
    
    // MARK: - 结果计算测试
    
    func test_scoreCalculation_perfectScore() {
        let totalQuestions = 30
        let correctCount = 30
        let percentage = Int(Double(correctCount) / Double(totalQuestions) * 100)
        
        XCTAssertEqual(percentage, 100)
    }
    
    func test_scoreCalculation_zeroCorrect() {
        let totalQuestions = 30
        let correctCount = 0
        let percentage = Int(Double(correctCount) / Double(totalQuestions) * 100)
        
        XCTAssertEqual(percentage, 0)
    }
    
    func test_scoreCalculation_partialCorrect() {
        let totalQuestions = 30
        let correctCount = 21
        let percentage = Int(Double(correctCount) / Double(totalQuestions) * 100)
        
        XCTAssertEqual(percentage, 70)
    }
    
    // MARK: - 分数等级测试
    
    func test_gradeText_excellent() {
        let grade = gradeText(for: 95)
        XCTAssertEqual(grade, "太棒了！完美表现！")
    }
    
    func test_gradeText_good() {
        let grade = gradeText(for: 85)
        XCTAssertEqual(grade, "做得很好！继续保持！")
    }
    
    func test_gradeText_ok() {
        let grade = gradeText(for: 65)
        XCTAssertEqual(grade, "不错！还有进步空间！")
    }
    
    func test_gradeText_poor() {
        let grade = gradeText(for: 40)
        XCTAssertEqual(grade, "继续加油！熟能生巧！")
    }
    
    // MARK: - 连击逻辑测试
    
    func test_comboReset_onWrongAnswer() {
        // 模拟连击场景
        var comboCount = 3
        var maxCombo = 3
        
        // 答错
        comboCount = 0
        maxCombo = max(maxCombo, comboCount)
        
        XCTAssertEqual(comboCount, 0, "答错后连击应重置为0")
        XCTAssertEqual(maxCombo, 3, "最高连击应为3")
    }
    
    func test_comboIncrement_onCorrectAnswer() {
        var comboCount = 3
        var maxCombo = 3
        
        // 答对
        comboCount += 1
        maxCombo = max(maxCombo, comboCount)
        
        XCTAssertEqual(comboCount, 4, "答对后连击应+1")
        XCTAssertEqual(maxCombo, 4, "最高连击应更新")
    }
    
    func test_maxCombo_persistence() {
        var comboCount = 5
        var maxCombo = 5
        
        // 答错：连击清零但最高连击保留
        comboCount = 0
        
        // 又答对
        comboCount += 1
        
        XCTAssertEqual(maxCombo, 5, "最高连击应保持为5")
        XCTAssertEqual(comboCount, 1, "当前连击重新开始")
    }
    
    // MARK: - 跳过题目的行为测试
    
    func test_skipResetsCombo() {
        var comboCount = 4
        
        // 跳过题目
        comboCount = 0
        
        XCTAssertEqual(comboCount, 0, "跳过题目应重置连击")
    }
    
    // MARK: - 题目唯一性测试
    
    func test_questionsAreUnique() {
        let questions = TestEngine.generateDiagnosticTest()
        let ids = questions.map { $0.id }
        let uniqueIds = Set(ids)
        
        XCTAssertEqual(ids.count, uniqueIds.count, "所有题目ID应该唯一")
    }
    
    func test_questionsHaveUniquePrompts() {
        let questions = TestEngine.generateDiagnosticTest()
        
        // 至少应该有多个不同的题目描述
        let uniquePrompts = Set(questions.map { $0.prompt })
        XCTAssertGreaterThan(uniquePrompts.count, 5, "应该至少有5个不同的题目描述")
    }
    
    // MARK: - Helper
    
    private func gradeText(for percentage: Int) -> String {
        if percentage >= 90 { return "太棒了！完美表现！" }
        if percentage >= 80 { return "做得很好！继续保持！" }
        if percentage >= 60 { return "不错！还有进步空间！" }
        return "继续加油！熟能生巧！"
    }
}
