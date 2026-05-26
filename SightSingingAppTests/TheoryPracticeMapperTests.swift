import XCTest
@testable import SightSingingApp

/// TheoryPracticeMapper TDD 测试
/// 验证乐理知识点到练习的映射正确性，以及乐理数据的完整性
/// 注意：练习内容尚未实现，当前映射表为空。
final class TheoryPracticeMapperTests: XCTestCase {

    // MARK: - 映射完整性测试

    /// 练习映射尚未实现，验证所有 topic 均无映射
    func testAllTheoryTopicsHaveNoPracticeMapping() {
        let allTopics = TheoryCategoryData.allCategories.flatMap { $0.topics }

        for topic in allTopics {
            let hasLink = TheoryPracticeMapper.hasPractice(for: topic.id)
            XCTAssertFalse(hasLink, "Topic '\(topic.id)' ('\(topic.title)') 不应有练习映射（练习尚未实现）")
        }
    }

    /// 空映射表下 resolvedLink 应返回 nil
    func testAllResolvedLinksReturnNil() {
        let allTopicIds = TheoryCategoryData.allCategories.flatMap { $0.topics }.map(\.id)

        for topicId in allTopicIds {
            XCTAssertNil(TheoryPracticeMapper.resolvedLink(for: topicId),
                         "Topic '\(topicId)' 不应有已解析的练习链接")
        }
    }

    /// mapping 字典应为空
    func testMappingIsEmpty() {
        XCTAssertTrue(TheoryPracticeMapper.mapping.isEmpty, "练习映射表应为空")
    }

    // MARK: - 乐理数据完整性测试

    /// 验证 TheoryDetailDatabase 中没有使用不兼容的 Unicode 音乐符号
    func testNoIncompatibleUnicodeMusicSymbolsInTheoryData() {
        let incompatibleSymbols = ["𝅝", "𝅗𝅥", "𝅘𝅥𝅮"]
        let allDetails = TheoryDetailDatabase.allDetailsArray

        for detail in allDetails {
            for section in detail.sections {
                // 检查 content
                for symbol in incompatibleSymbols {
                    XCTAssertFalse(section.content.contains(symbol),
                                   "Topic '\(detail.topicId)' 的 content 包含不兼容符号 '\(symbol)'")
                }

                // 检查 graphicData 中的 notes
                if let notes = section.graphicData?.notes {
                    for note in notes {
                        for symbol in incompatibleSymbols {
                            XCTAssertFalse(note.contains(symbol),
                                           "Topic '\(detail.topicId)' 的 graphicData.notes 包含不兼容符号 '\(symbol)'")
                        }
                    }
                }
            }
        }
    }
}
