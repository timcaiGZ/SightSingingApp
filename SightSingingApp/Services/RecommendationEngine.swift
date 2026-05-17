import Foundation

/// 推荐引擎 — 基于测试结果和练习历史生成个性化推荐
final class RecommendationEngine {
    /// 吉他场景权重（和弦权重最高，因为大横按是痛点）
    private static let dimensionWeights: [ExerciseModule: Double] = [
        .noteName: 0.8,
        .interval: 1.0,
        .chord: 1.3,    // 最高权重
        .scale: 0.9,
        .rhythm: 1.0,
        .melody: 1.1,
    ]

    /// 生成推荐
    static func generateRecommendations(
        dimensionScores: [ExerciseModule: DimensionScore]
    ) -> [Recommendation] {
        var recommendations: [Recommendation] = []

        // 计算每个维度的薄弱指数
        var weakItems: [(module: ExerciseModule, score: Int, weakIndex: Double)] = []

        for (module, dimScore) in dimensionScores {
            let weight = dimensionWeights[module] ?? 1.0
            let weakIndex = Double(100 - dimScore.score) * weight
            weakItems.append((module: module, score: dimScore.score, weakIndex: weakIndex))
        }

        // 按薄弱指数排序，取前3
        let sortedWeak = weakItems.sorted { $0.weakIndex > $1.weakIndex }

        for item in sortedWeak.prefix(3) {
            guard item.weakIndex > 20 else { continue } // 低于阈值不推荐

            let suggestedMinutes = suggestedMinutes(for: item.weakIndex)
            let exerciseType = recommendExerciseType(for: item.module, score: item.score)
            let reason = generateReason(for: item.module, score: item.score)

            recommendations.append(Recommendation(
                exerciseType: exerciseType,
                suggestedMinutes: suggestedMinutes,
                reason: reason
            ))
        }

        // 如果没有明显薄弱项，建议均衡练习
        if recommendations.isEmpty {
            recommendations.append(Recommendation(
                exerciseType: .chordTransitionSpeed,
                suggestedMinutes: 10,
                reason: "各维度表现均衡，建议练习和弦转换保持状态"
            ))
        }

        return recommendations
    }

    /// 根据薄弱指数计算建议时长
    private static func suggestedMinutes(for weakIndex: Double) -> Int {
        if weakIndex > 40 {
            return 20
        } else if weakIndex > 20 {
            return 15
        } else {
            return 10
        }
    }

    /// 根据维度推荐具体练习类型
    private static func recommendExerciseType(for module: ExerciseModule, score: Int) -> ExerciseType {
        switch module {
        case .noteName:
            return score < 50 ? .openStringRecognition : .singleNoteRecognition
        case .interval:
            return score < 50 ? .intervalRecognition : .fretboardIntervalComparison
        case .chord:
            // 和弦：低分推荐大横按，高分推荐转换速度
            return score < 50 ? .barreChordRecognition : .chordTransitionSpeed
        case .scale:
            return score < 50 ? .commonTuningRecognition : .cagedSystemPractice
        case .rhythm:
            return score < 50 ? .strummingPattern : .arpeggioPattern
        case .melody:
            return score < 50 ? .intervalSinging : .tablatureMelodySinging
        }
    }

    /// 生成推荐原因（吉他特色）
    private static func generateReason(for module: ExerciseModule, score: Int) -> String {
        switch module {
        case .noteName:
            return score < 50
                ? "空弦音辨认需要加强，EADGBE 调弦基础要打牢"
                : "单音辨认能力可进一步提升，建议练习跨弦音高"
        case .interval:
            return score < 50
                ? "音程关系是推弦、揉弦的基础，建议加强"
                : "把位音程比较能力可进一步提升"
        case .chord:
            if score < 40 {
                return "大横按是吉他进阶的难点，F/Bm 和弦需要多练"
            } else if score < 60 {
                return "和弦转换速度需要提升，多练 C-G-Am-Em 循环"
            }
            return "和弦基础扎实，可尝试复杂节奏型"
        case .scale:
            return score < 50
                ? "CAGED 系统是理解吉他指板的核心"
                : "调式把位掌握不错，可练习即兴演奏"
        case .rhythm:
            return score < 50
                ? "扫弦节奏型是弹唱伴奏的基础"
                : "节奏稳定性良好，可尝试切分节奏"
        case .melody:
            return score < 50
                ? "视唱能力需要加强，简谱旋律模唱要多练习"
                : "旋律视唱能力不错，可尝试更复杂旋律"
        }
    }
}
