import SwiftUI

// MARK: - 乐理主题到练习的关联映射
/// 建立乐理知识点与对应练习之间的精确关联，让用户学完理论后能直接进入相关练习
struct TheoryPracticeMapper {

    /// 关联的练习信息
    struct PracticeLink {
        let categoryId: String      // 练习分类ID (pitch/singing/rhythm/chord/transcription)
        let exerciseId: String      // 练习项ID
        let exerciseTitle: String   // 显示标题
        let reason: String          // 关联原因（为什么推荐这个练习）
    }

    /// 全部映射表（练习内容完成后填充）
    static let mapping: [String: PracticeLink] = [:]

    /// 根据 topicId 获取关联练习
    static func link(for topicId: String) -> PracticeLink? {
        mapping[topicId]
    }

    /// 获取关联的练习数据（包括 category 和 exercise）
    static func resolvedLink(for topicId: String) -> (category: PracticeCategoryData, exercise: PracticeExerciseData, link: PracticeLink)? {
        guard let link = mapping[topicId] else { return nil }
        guard let category = PracticeCategoryData.allCategories.first(where: { $0.id == link.categoryId }) else { return nil }
        guard let exercise = category.exercises.first(where: { $0.id == link.exerciseId }) else { return nil }
        return (category, exercise, link)
    }

    /// 判断 topicId 是否有对应的关联练习
    static func hasPractice(for topicId: String) -> Bool {
        mapping[topicId] != nil
    }
}
