import XCTest
@testable import SightSingingApp

/// TheoryPracticeMapper TDD 测试
/// 验证乐理知识点到练习的映射正确性，以及乐理数据的完整性
final class TheoryPracticeMapperTests: XCTestCase {

    // MARK: - 映射完整性测试

    /// 所有乐理分类中的 topic 都应该有对应的练习映射（或有合理的缺失理由）
    func testAllTheoryTopicsHaveMappedPracticeOrAreDocumented() {
        let allTopics = TheoryCategoryData.allCategories.flatMap { $0.topics }
        let specialTopicIds = ["seventh-chords", "mode-relation"] // 特殊页面，不需要练习映射

        for topic in allTopics {
            if specialTopicIds.contains(topic.id) {
                // 特殊页面允许没有映射
                continue
            }
            let hasLink = TheoryPracticeMapper.hasPractice(for: topic.id)
            XCTAssertTrue(hasLink, "Topic '\(topic.id)' ('\(topic.title)') 缺少练习映射")
        }
    }

    /// 所有映射都应该能解析到有效的分类和练习
    func testAllMappingsResolveToValidPractice() {
        let allTopicIds = TheoryCategoryData.allCategories.flatMap { $0.topics }.map(\.id)

        for topicId in allTopicIds {
            guard let resolved = TheoryPracticeMapper.resolvedLink(for: topicId) else {
                // 允许无映射的情况（特殊页面）
                continue
            }

            // 验证分类存在
            XCTAssertEqual(resolved.category.id, resolved.link.categoryId,
                           "Topic '\(topicId)' 的分类ID不匹配")

            // 验证练习存在
            XCTAssertEqual(resolved.exercise.id, resolved.link.exerciseId,
                           "Topic '\(topicId)' 的练习ID不匹配")

            // 验证练习标题不为空
            XCTAssertFalse(resolved.exercise.title.isEmpty,
                           "Topic '\(topicId)' 的练习标题为空")
        }
    }

    // MARK: - 关键映射准确性测试

    func testNotesTopicMapsToSingleNoteRecognition() {
        let link = TheoryPracticeMapper.link(for: "notes")
        XCTAssertNotNil(link)
        XCTAssertEqual(link?.exerciseId, "single-note")
        XCTAssertEqual(link?.exerciseTitle, "单音辨认")
        XCTAssertEqual(link?.categoryId, "pitch")
    }

    func testTriadsTopicMapsToTriadIdentify() {
        let link = TheoryPracticeMapper.link(for: "triads")
        XCTAssertNotNil(link)
        XCTAssertEqual(link?.exerciseId, "triad-identify")
        XCTAssertEqual(link?.exerciseTitle, "三和弦辨认")
        XCTAssertEqual(link?.categoryId, "chord")
    }

    func testIntervalConceptMapsToAscendingInterval() {
        let link = TheoryPracticeMapper.link(for: "interval-concept")
        XCTAssertNotNil(link)
        XCTAssertEqual(link?.exerciseId, "ascending-interval")
        XCTAssertEqual(link?.categoryId, "pitch")
    }

    func testRhythmBasicsMapsToSyncopation() {
        let link = TheoryPracticeMapper.link(for: "rhythm-basics")
        XCTAssertNotNil(link)
        XCTAssertEqual(link?.exerciseId, "syncopation")
        XCTAssertEqual(link?.categoryId, "rhythm")
    }

    func testMajorScaleMapsToCircleOfFifths() {
        let link = TheoryPracticeMapper.link(for: "major-scale")
        XCTAssertNotNil(link)
        XCTAssertEqual(link?.exerciseId, "circle-of-fifths")
        XCTAssertEqual(link?.categoryId, "chord")
    }

    // MARK: - 关联原因测试

    func testAllLinksHaveNonEmptyReason() {
        for (topicId, link) in TheoryPracticeMapper.mapping {
            XCTAssertFalse(link.reason.isEmpty,
                           "Topic '\(topicId)' 的关联原因不能为空")
        }
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
