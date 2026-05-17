import Foundation

/// 测试结果（内存中的计算结果）
struct TestResult: Identifiable {
    let id = UUID()
    let totalScore: Int
    let dimensionScores: [ExerciseModule: DimensionScore]
    let recommendations: [Recommendation]
    let totalDurationSeconds: Int
    let date: Date

    init(
        totalScore: Int,
        dimensionScores: [ExerciseModule: DimensionScore],
        recommendations: [Recommendation],
        totalDurationSeconds: Int,
        date: Date = Date()
    ) {
        self.totalScore = totalScore
        self.dimensionScores = dimensionScores
        self.recommendations = recommendations
        self.totalDurationSeconds = totalDurationSeconds
        self.date = date
    }

    /// 薄弱项（得分最低的维度）
    var weakDimensions: [ExerciseModule] {
        dimensionScores
            .sorted { $0.value.score < $1.value.score }
            .prefix(3)
            .map { $0.key }
    }
}

/// 单个维度的得分详情
struct DimensionScore {
    let module: ExerciseModule
    let correctRate: Double        // 正确率 0-1
    let avgResponseTime: Double    // 平均反应时间（秒）
    let score: Int                 // 综合得分 0-100
    let questionCount: Int         // 题目数
    let correctCount: Int           // 正确数
}
