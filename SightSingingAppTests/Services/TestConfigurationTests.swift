import XCTest
@testable import SightSingingApp

/// TestEngine 配置的单元测试
final class TestConfigurationTests: XCTestCase {
    
    func testWeightsSumToOne() {
        // 权重应该加起来等于 1
        let totalWeight = TestConfiguration.accuracyWeight + TestConfiguration.reactionTimeWeight
        XCTAssertEqual(totalWeight, 1.0, accuracy: 0.001)
    }
    
    func testQuestionCountIsReasonable() {
        // 题目总数应该合理（20-50 之间）
        XCTAssertGreaterThan(TestConfiguration.diagnosticTestQuestionCount, 20)
        XCTAssertLessThan(TestConfiguration.diagnosticTestQuestionCount, 50)
    }
    
    func testReactionThresholdsAreReasonable() {
        // 快速反应阈值应小于中等反应阈值
        XCTAssertLessThan(TestConfiguration.fastReactionThreshold, TestConfiguration.mediumReactionThreshold)
        
        // 反应阈值应该都是正数
        XCTAssertGreaterThan(TestConfiguration.fastReactionThreshold, 0)
        XCTAssertGreaterThan(TestConfiguration.mediumReactionThreshold, 0)
    }
    
    func testChordRecommendationMultiplierIsValid() {
        // 和弦权重倍数应该大于 1（表示更推荐）
        XCTAssertGreaterThan(TestConfiguration.chordRecommendationMultiplier, 1.0)
    }
    
    func testScoreThresholdsAreValid() {
        // 及格分数应小于优秀分数
        XCTAssertLessThan(TestConfiguration.passingScore, TestConfiguration.excellentScore)
        
        // 分数应在合理范围内
        XCTAssertGreaterThanOrEqual(TestConfiguration.passingScore, 0)
        XCTAssertLessThanOrEqual(TestConfiguration.excellentScore, 100)
    }
}

/// TestEngine 题目类型遵循 DifficultyProvidable 协议的测试
final class TestEngineDifficultyTests: XCTestCase {
    
    func testAllQuestionTypesConformToDifficultyProvidable() {
        // 验证所有题目类型都遵循 DifficultyProvidable 协议
        
        // 音名题目
        let noteQuestion = NoteNameQuestion(solfege: "1", noteName: "C", octave: 4, isSharp: false, difficulty: .easy)
        XCTAssertTrue(noteQuestion is DifficultyProvidable)
        XCTAssertEqual(noteQuestion.difficulty, .easy)
        
        // 音程题目
        let intervalQuestion = IntervalQuestion(name: "大二度", shortName: "M2", semitones: 2, difficulty: .easy)
        XCTAssertTrue(intervalQuestion is DifficultyProvidable)
        XCTAssertEqual(intervalQuestion.difficulty, .easy)
        
        // 和弦题目
        let chordQuestion = ChordQuestion(name: "C", notes: [], difficulty: .easy)
        XCTAssertTrue(chordQuestion is DifficultyProvidable)
        XCTAssertEqual(chordQuestion.difficulty, .easy)
        
        // 调式题目
        let scaleQuestion = ScaleQuestion(name: "C大调", root: "C", notes: [], difficulty: .easy)
        XCTAssertTrue(scaleQuestion is DifficultyProvidable)
        XCTAssertEqual(scaleQuestion.difficulty, .easy)
        
        // 节奏题目
        let rhythmQuestion = RhythmQuestion(name: "下上下上", notation: "↓↑↓↑", beats: 4, difficulty: .easy)
        XCTAssertTrue(rhythmQuestion is DifficultyProvidable)
        XCTAssertEqual(rhythmQuestion.difficulty, .easy)
        
        // 旋律题目
        let melodyQuestion = MelodyQuestion(solfege: "123", description: "上行音阶", intervalType: "stepwise", noteCount: 3, difficulty: .easy)
        XCTAssertTrue(melodyQuestion is DifficultyProvidable)
        XCTAssertEqual(melodyQuestion.difficulty, .easy)
    }
}
