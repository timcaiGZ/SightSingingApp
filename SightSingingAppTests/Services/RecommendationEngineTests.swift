import XCTest
@testable import SightSingingApp

final class RecommendationEngineTests: XCTestCase {

    func testGenerateRecommendations_ReturnsUpTo3Recommendations() {
        var dimensionScores: [ExerciseModule: DimensionScore] = [:]

        dimensionScores[.noteName] = DimensionScore(
            module: .noteName, correctRate: 0.3, avgResponseTime: 2.0, score: 30, questionCount: 5, correctCount: 1
        )
        dimensionScores[.interval] = DimensionScore(
            module: .interval, correctRate: 0.4, avgResponseTime: 2.0, score: 40, questionCount: 5, correctCount: 2
        )
        dimensionScores[.chord] = DimensionScore(
            module: .chord, correctRate: 0.2, avgResponseTime: 2.0, score: 20, questionCount: 5, correctCount: 1
        )
        dimensionScores[.scale] = DimensionScore(
            module: .scale, correctRate: 0.5, avgResponseTime: 2.0, score: 50, questionCount: 5, correctCount: 2
        )
        dimensionScores[.rhythm] = DimensionScore(
            module: .rhythm, correctRate: 0.6, avgResponseTime: 2.0, score: 60, questionCount: 5, correctCount: 3
        )
        dimensionScores[.melody] = DimensionScore(
            module: .melody, correctRate: 0.7, avgResponseTime: 2.0, score: 70, questionCount: 5, correctCount: 3
        )

        let recommendations = RecommendationEngine.generateRecommendations(dimensionScores: dimensionScores)

        XCTAssertLessThanOrEqual(recommendations.count, 3, "最多返回3条推荐")
        XCTAssertFalse(recommendations.isEmpty, "应该有推荐")
    }

    func testGenerateRecommendations_HighestWeakIndexFirst() {
        var dimensionScores: [ExerciseModule: DimensionScore] = [:]

        dimensionScores[.chord] = DimensionScore(
            module: .chord, correctRate: 0.2, avgResponseTime: 2.0, score: 20, questionCount: 5, correctCount: 1
        )
        dimensionScores[.noteName] = DimensionScore(
            module: .noteName, correctRate: 0.3, avgResponseTime: 2.0, score: 30, questionCount: 5, correctCount: 1
        )
        dimensionScores[.interval] = DimensionScore(
            module: .interval, correctRate: 0.5, avgResponseTime: 2.0, score: 50, questionCount: 5, correctCount: 2
        )
        dimensionScores[.scale] = DimensionScore(
            module: .scale, correctRate: 0.5, avgResponseTime: 2.0, score: 50, questionCount: 5, correctCount: 2
        )
        dimensionScores[.rhythm] = DimensionScore(
            module: .rhythm, correctRate: 0.5, avgResponseTime: 2.0, score: 50, questionCount: 5, correctCount: 2
        )
        dimensionScores[.melody] = DimensionScore(
            module: .melody, correctRate: 0.5, avgResponseTime: 2.0, score: 50, questionCount: 5, correctCount: 2
        )

        let recommendations = RecommendationEngine.generateRecommendations(dimensionScores: dimensionScores)

        if !recommendations.isEmpty {
            let firstRec = recommendations[0]
            XCTAssertEqual(firstRec.module, ExerciseModule.chord.rawValue, "最弱的和弦应该排第一")
        }
    }

    func testSuggestedMinutes_HighWeakIndex_20Minutes() {
        var dimensionScores: [ExerciseModule: DimensionScore] = [:]
        dimensionScores[.chord] = DimensionScore(
            module: .chord, correctRate: 0.2, avgResponseTime: 2.0, score: 20, questionCount: 5, correctCount: 1
        )

        let recommendations = RecommendationEngine.generateRecommendations(dimensionScores: dimensionScores)

        if !recommendations.isEmpty {
            XCTAssertEqual(recommendations[0].suggestedMinutes, 20, "高薄弱指数应建议20分钟")
        }
    }
}
