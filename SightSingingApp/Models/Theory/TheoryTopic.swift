import Foundation

/// 吉他乐理知识点，完全围绕民谣吉他弹唱场景
struct TheoryTopic: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String          // 标题，如 "C 和弦标准按法"
    let category: TheoryCategory
    let summary: String       // 摘要
    let content: String        // 详细内容（Markdown 风格）
    let searchKeywords: [String] // 搜索关键词
    let tabData: TabData?      // 关联的六线谱图示（可选）

    init(
        id: UUID = UUID(),
        title: String,
        category: TheoryCategory,
        summary: String,
        content: String,
        searchKeywords: [String],
        tabData: TabData? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.summary = summary
        self.content = content
        self.searchKeywords = searchKeywords
        self.tabData = tabData
    }
}

/// 乐理知识分类（吉他学习主题）
enum TheoryCategory: String, CaseIterable, Codable {
    case notationBasics = "识谱入门"
    case intervalsAndScales = "音程与音阶"
    case chords = "和弦"
    case rhythm = "节奏"
    case modes = "调式"

    var displayName: String { rawValue }

    var iconName: String {
        switch self {
        case .notationBasics: return "doc.text"
        case .intervalsAndScales: return "arrow.left.and.right"
        case .chords: return "hand.raised"
        case .rhythm: return "metronome"
        case .modes: return "pianokeys"
        }
    }
}
