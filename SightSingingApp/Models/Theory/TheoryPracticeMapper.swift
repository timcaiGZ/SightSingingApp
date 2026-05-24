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

    /// 全部映射表
    static let mapping: [String: PracticeLink] = [
        // MARK: 基础乐理
        "notes": PracticeLink(
            categoryId: "pitch",
            exerciseId: "single-note",
            exerciseTitle: "单音辨认",
            reason: "辨认音符是视唱练耳的第一步"
        ),
        "pitch-names": PracticeLink(
            categoryId: "singing",
            exerciseId: "single-note-sing",
            exerciseTitle: "单音视唱",
            reason: "学会音名与唱名的对应，开始视唱训练"
        ),
        "whole-half": PracticeLink(
            categoryId: "pitch",
            exerciseId: "ascending-interval",
            exerciseTitle: "上行音程听辨",
            reason: "全音与半音是理解音程的基础"
        ),
        "note-duration": PracticeLink(
            categoryId: "rhythm",
            exerciseId: "quarter-eighth",
            exerciseTitle: "四分音符节奏",
            reason: "掌握音符时值，训练稳定节拍"
        ),
        "beat-signature": PracticeLink(
            categoryId: "rhythm",
            exerciseId: "quarter-eighth",
            exerciseTitle: "四分音符节奏",
            reason: "理解拍号后，练习基础节奏型"
        ),
        "rhythm-basics": PracticeLink(
            categoryId: "rhythm",
            exerciseId: "syncopation",
            exerciseTitle: "切分节奏",
            reason: "在基础节奏之上训练复杂节奏型"
        ),

        // MARK: 识谱知识
        "staff-intro": PracticeLink(
            categoryId: "transcription",
            exerciseId: "jianpu-complete",
            exerciseTitle: "简谱补全",
            reason: "五线谱与简谱识读互补训练"
        ),
        "solfege-intro": PracticeLink(
            categoryId: "singing",
            exerciseId: "scale-sing",
            exerciseTitle: "音阶视唱",
            reason: "用唱名系统视唱音阶"
        ),
        "tab-reading": PracticeLink(
            categoryId: "transcription",
            exerciseId: "tab-complete",
            exerciseTitle: "六线谱补全",
            reason: "把旋律落到吉他弦品位置"
        ),
        "clef-key": PracticeLink(
            categoryId: "chord",
            exerciseId: "circle-of-fifths",
            exerciseTitle: "五度圈练习",
            reason: "调号与五度圈密切相关"
        ),

        // MARK: 音程
        "interval-concept": PracticeLink(
            categoryId: "pitch",
            exerciseId: "ascending-interval",
            exerciseTitle: "上行音程听辨",
            reason: "学习音程概念后，开始听辨训练"
        ),
        "guitar-intervals": PracticeLink(
            categoryId: "pitch",
            exerciseId: "ascending-interval",
            exerciseTitle: "上行音程听辨",
            reason: "在吉他指板上理解音程关系"
        ),
        "interval-quality": PracticeLink(
            categoryId: "pitch",
            exerciseId: "harmonic-interval",
            exerciseTitle: "和声音程听辨",
            reason: "深入理解音程性质，训练同时发声的音程"
        ),
        "interval-hearing": PracticeLink(
            categoryId: "pitch",
            exerciseId: "descending-interval",
            exerciseTitle: "下行音程听辨",
            reason: "综合训练各方向的音程听辨"
        ),

        // MARK: 和弦
        "triads": PracticeLink(
            categoryId: "chord",
            exerciseId: "triad-identify",
            exerciseTitle: "三和弦辨认",
            reason: "学习三和弦后，直接训练听辨"
        ),
        "seventh-chords": PracticeLink(
            categoryId: "chord",
            exerciseId: "seventh-identify",
            exerciseTitle: "七和弦辨认",
            reason: "七和弦的进阶听辨训练"
        ),
        "inversions": PracticeLink(
            categoryId: "chord",
            exerciseId: "tsd-function",
            exerciseTitle: "TSD功能判断",
            reason: "转位和弦与和声功能紧密相关"
        ),
        "guitar-chords": PracticeLink(
            categoryId: "chord",
            exerciseId: "open-chord",
            exerciseTitle: "吉他开放和弦听辨",
            reason: "辨认吉他上常用的开放和弦"
        ),
        "chord-hearing": PracticeLink(
            categoryId: "chord",
            exerciseId: "triad-identify",
            exerciseTitle: "三和弦辨认",
            reason: "从基础和弦听辨开始训练"
        ),

        // MARK: 调式
        "major-scale": PracticeLink(
            categoryId: "chord",
            exerciseId: "circle-of-fifths",
            exerciseTitle: "五度圈练习",
            reason: "大调音阶与五度圈调性关系"
        ),
        "minor-scale": PracticeLink(
            categoryId: "singing",
            exerciseId: "scale-sing",
            exerciseTitle: "音阶视唱",
            reason: "小调音阶的视唱训练"
        ),
        "mode-relation": PracticeLink(
            categoryId: "chord",
            exerciseId: "circle-of-fifths",
            exerciseTitle: "五度圈练习",
            reason: "关系大小调在五度圈上的位置"
        ),
        "church-modes": PracticeLink(
            categoryId: "singing",
            exerciseId: "scale-sing",
            exerciseTitle: "音阶视唱",
            reason: "中古调式的视唱训练"
        ),

        // MARK: 节奏
        "time-signatures": PracticeLink(
            categoryId: "rhythm",
            exerciseId: "quarter-eighth",
            exerciseTitle: "四分音符节奏",
            reason: "在稳定拍感中体验不同拍号"
        ),
        "rhythm-patterns": PracticeLink(
            categoryId: "rhythm",
            exerciseId: "syncopation",
            exerciseTitle: "切分节奏",
            reason: "训练常用节奏型的听辨与演奏"
        ),
        "tuplets": PracticeLink(
            categoryId: "rhythm",
            exerciseId: "triplet",
            exerciseTitle: "三连音",
            reason: "三连音与多连音专项训练"
        ),
        "compound-rhythm": PracticeLink(
            categoryId: "rhythm",
            exerciseId: "strum-rhythm",
            exerciseTitle: "扫弦节奏",
            reason: "复合节奏在吉他扫弦中的体现"
        ),
    ]

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
