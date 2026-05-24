import SwiftUI

/// 乐理学习进度服务 — 持久化「已读/未读」状态，提供分类完成百分比
@Observable
class TheoryProgressService {

    // 用 UserDefaults 直读直写，避免与 @Observable 宏冲突
    private let defaultsKey = "theory_progress_v2"
    private var topics: [String: TopicProgress] = [:]

    // MARK: - 数据模型

    struct TopicProgress: Codable {
        var isRead: Bool = false
        var lastVisitDate: Date?
    }

    struct CategoryProgress {
        let completed: Int
        let total: Int
        var percentage: Int { total > 0 ? Int(Double(completed) / Double(total) * 100) : 0 }
        var isComplete: Bool { completed >= total && total > 0 }
    }

    // MARK: - 生命周期

    init() {
        load()
    }

    // MARK: - 公开 API

    func markRead(_ topicId: String) {
        topics[topicId] = TopicProgress(isRead: true, lastVisitDate: Date())
        save()
    }

    func isRead(_ topicId: String) -> Bool {
        topics[topicId]?.isRead ?? false
    }

    func categoryProgress(topicIds: [String]) -> CategoryProgress {
        let completed = topicIds.filter { topics[$0]?.isRead ?? false }.count
        return CategoryProgress(completed: completed, total: topicIds.count)
    }

    /// 重置全部进度
    func resetAll() {
        topics.removeAll()
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }

    // MARK: - 持久化

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              !data.isEmpty,
              let decoded = try? JSONDecoder().decode([String: TopicProgress].self, from: data)
        else { return }
        topics = decoded
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(topics) {
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        }
    }
}
