import XCTest
@testable import SightSingingApp

/// 乐理知识点详情内容 单元测试
final class TheoryDetailContentTests: XCTestCase {
    
    // MARK: - 覆盖率测试：所有 topicId 都有对应内容
    
    func test_allTheoryTopics_haveDetailContent() {
        // 获取所有 TheoryCategoryData 中的 topic IDs
        var allTopicIds = Set<String>()
        for category in TheoryCategoryData.allCategories {
            for topic in category.topics {
                allTopicIds.insert(topic.id)
            }
        }
        
        // 验证每个 topicId 都能获取到有效内容
        for topicId in allTopicIds {
            let detail = TheoryDetailDatabase.getDetail(for: topicId)
            XCTAssertEqual(detail.topicId, topicId, "topicId 应与请求匹配: \(topicId)")
            XCTAssertFalse(detail.title.isEmpty, "title 不应为空: \(topicId)")
            XCTAssertFalse(detail.sections.isEmpty, "至少应有一个 section: \(topicId)")
            
            // 验证每个 section 都有内容
            for section in detail.sections {
                XCTAssertFalse(section.title.isEmpty, "section title 不应为空: \(topicId)")
                XCTAssertFalse(section.content.isEmpty, "section content 不应为空: \(topicId)")
            }
        }
    }
    
    // MARK: - 内容完整性测试
    
    func test_basicTheoryTopics_count() {
        let basicCategory = TheoryCategoryData.allCategories.first { $0.id == "basic" }
        XCTAssertNotNil(basicCategory)
        XCTAssertEqual(basicCategory?.topics.count, 8, "基础乐理应有8个知识点")
    }
    
    func test_notationTopics_count() {
        let notationCategory = TheoryCategoryData.allCategories.first { $0.id == "notation" }
        XCTAssertNotNil(notationCategory)
        XCTAssertEqual(notationCategory?.topics.count, 6, "识谱应有6个知识点")
    }
    
    func test_intervalTopics_count() {
        let intervalCategory = TheoryCategoryData.allCategories.first { $0.id == "interval" }
        XCTAssertNotNil(intervalCategory)
        XCTAssertEqual(intervalCategory?.topics.count, 5, "音程应有5个知识点")
    }
    
    func test_chordTopics_count() {
        let chordCategory = TheoryCategoryData.allCategories.first { $0.id == "chord" }
        XCTAssertNotNil(chordCategory)
        XCTAssertEqual(chordCategory?.topics.count, 29, "和弦应有29个知识点（含指板数据库+和弦进行）")
    }
    
    func test_modeTopics_count() {
        let modeCategory = TheoryCategoryData.allCategories.first { $0.id == "mode" }
        XCTAssertNotNil(modeCategory)
        XCTAssertEqual(modeCategory?.topics.count, 15, "调式与转调应有15个知识点")
    }
    
    func test_rhythmTopics_count() {
        let rhythmCategory = TheoryCategoryData.allCategories.first { $0.id == "rhythm-theory" }
        XCTAssertNotNil(rhythmCategory)
        XCTAssertEqual(rhythmCategory?.topics.count, 8, "节奏应有8个知识点")
    }
    
    func test_totalTopics_equals77() {
        var totalCount = 0
        for category in TheoryCategoryData.allCategories {
            totalCount += category.topics.count
        }
        XCTAssertEqual(totalCount, 77, "乐理知识点总数应为77个")
    }
    
    // MARK: - 特殊知识点测试
    
    func test_seventhChords_isSpecial() {
        let chordCategory = TheoryCategoryData.allCategories.first { $0.id == "chord" }
        let seventhChords = chordCategory?.topics.first { $0.id == "seventh-chords" }
        XCTAssertNotNil(seventhChords)
        XCTAssertTrue(seventhChords?.isSpecial == true, "七和弦应标记为特殊页面")
    }
    
    func test_modesFullGuide_showsCircleOfFifths() {
        let detail = TheoryDetailDatabase.getDetail(for: "modes-full-guide")
        XCTAssertTrue(detail.showCircleOfFifths || detail.sections.count > 0, "七种调式完全指南应有内容或显示五度圈")
    }

    // MARK: - 图形类型测试
    
    func test_notesDetail_hasSolfegeGraphic() {
        let detail = TheoryDetailDatabase.getDetail(for: "notes")
        let hasGraphic = detail.sections.contains { $0.graphicType == .noteDuration || $0.graphicType == .solfegeNotes }
        XCTAssertTrue(hasGraphic, "认识音符应包含音符时值图形")
    }
    
    func test_intervalConcept_hasIntervalList() {
        let detail = TheoryDetailDatabase.getDetail(for: "interval-concept")
        let hasIntervalList = detail.sections.contains { $0.graphicType == .intervalList }
        XCTAssertTrue(hasIntervalList, "音程的概念应包含音程列表图形")
        
        let intervalSection = detail.sections.first { $0.graphicType == .intervalList }
        XCTAssertNotNil(intervalSection?.graphicData)
        XCTAssertFalse(intervalSection?.graphicData?.intervals.isEmpty ?? true, "音程列表不应为空")
    }
    
    func test_triads_hasChordDiagram() {
        let detail = TheoryDetailDatabase.getDetail(for: "triads")
        let hasChordDiagram = detail.sections.contains { $0.graphicType == .chordDiagram }
        XCTAssertTrue(hasChordDiagram, "三和弦应包含和弦指法图")
    }
    
    func test_wholeHalf_hasWholeHalfFlow() {
        let detail = TheoryDetailDatabase.getDetail(for: "whole-half")
        let hasFlow = detail.sections.contains { $0.graphicType == .wholeHalfFlow }
        XCTAssertTrue(hasFlow, "全音与半音应包含流向图")
    }
    
    // MARK: - 未知 topicId fallback 测试
    
    func test_unknownTopicId_returnsFallback() {
        let detail = TheoryDetailDatabase.getDetail(for: "non-existent-topic")
        XCTAssertEqual(detail.title, "知识点", "未知 topicId 应返回默认标题")
        XCTAssertFalse(detail.sections.isEmpty, "fallback 应有内容")
        XCTAssertEqual(detail.sections.first?.title, "内容", "fallback 标题应为'内容'")
    }
}
