import Foundation
import SwiftData

/// 测试历史记录，SwiftData 持久化
@Model
final class TestHistory {
    var id: UUID
    var date: Date
    var totalScore: Int           // 总分 0-100
    var dimensionScoresJSON: String // 各维度得分 JSON
    var recommendationsJSON: String // 推荐 JSON
    var totalDurationSeconds: Int  // 总耗时（秒）

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        totalScore: Int,
        dimensionScores: [ExerciseModule: Int],
        recommendations: [Recommendation],
        totalDurationSeconds: Int
    ) {
        self.id = id
        self.date = date
        self.totalScore = totalScore
        self.dimensionScoresJSON = (try? JSONEncoder().encode(dimensionScores))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        self.recommendationsJSON = (try? JSONEncoder().encode(recommendations))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        self.totalDurationSeconds = totalDurationSeconds
    }

    var dimensionScores: [ExerciseModule: Int] {
        guard let data = dimensionScoresJSON.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        var result: [ExerciseModule: Int] = [:]
        for (key, value) in decoded {
            if let module = ExerciseModule(rawValue: key) {
                result[module] = value
            }
        }
        return result
    }

    var recommendations: [Recommendation] {
        guard let data = recommendationsJSON.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([Recommendation].self, from: data) else {
            return []
        }
        return decoded
    }
}

/// 推荐结构
struct Recommendation: Codable, Identifiable {
    var id: UUID
    var exerciseType: String      // ExerciseType.rawValue
    var module: String            // ExerciseModule.rawValue
    var suggestedMinutes: Int      // 建议时长（分钟）
    var reason: String            // 推荐原因

    init(
        id: UUID = UUID(),
        exerciseType: ExerciseType,
        suggestedMinutes: Int,
        reason: String
    ) {
        self.id = id
        self.exerciseType = exerciseType.rawValue
        self.module = exerciseType.module.rawValue
        self.suggestedMinutes = suggestedMinutes
        self.reason = reason
    }

    var exerciseTypeValue: ExerciseType? {
        ExerciseType(rawValue: exerciseType)
    }

    var exerciseModule: ExerciseModule? {
        ExerciseModule(rawValue: module)
    }
}
