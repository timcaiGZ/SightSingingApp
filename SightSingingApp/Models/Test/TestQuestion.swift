import Foundation

/// 测试题目结构体，支持简谱/六线谱图示
struct TestQuestion: Identifiable, Codable {
    let id: UUID
    let dimension: String         // ExerciseModule.rawValue
    let difficulty: String        // Difficulty.rawValue
    let questionType: String     // QuestionType.rawValue
    let prompt: String           // 题目描述
    let audioNote: String        // 播放的音符/和弦（简谱表示）
    let options: [TestOption]    // 选项列表
    let correctAnswerIndex: Int  // 正确答案索引

    init(
        id: UUID = UUID(),
        dimension: ExerciseModule,
        difficulty: Difficulty,
        questionType: QuestionType,
        prompt: String,
        audioNote: String,
        options: [TestOption],
        correctAnswerIndex: Int
    ) {
        self.id = id
        self.dimension = dimension.rawValue
        self.difficulty = difficulty.rawValue
        self.questionType = questionType.rawValue
        self.prompt = prompt
        self.audioNote = audioNote
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
    }

    var dimensionValue: ExerciseModule? {
        ExerciseModule(rawValue: dimension)
    }

    var difficultyValue: Difficulty? {
        Difficulty(rawValue: difficulty)
    }

    var questionTypeValue: QuestionType? {
        QuestionType(rawValue: questionType)
    }
}

/// 测试选项
struct TestOption: Identifiable, Codable {
    let id: UUID
    let label: String          // 显示文本，如 "C" / "Am"
    let tabData: TabData?       // 六线谱图示数据（可选）

    init(id: UUID = UUID(), label: String, tabData: TabData? = nil) {
        self.id = id
        self.label = label
        self.tabData = tabData
    }
}

/// 六线谱数据
struct TabData: Codable, Hashable {
    /// 每根弦的品位（0 = 空弦，1-12 = 品位，nil = 不弹奏）
    let frets: [Int?]
    /// 需要按弦的品位标记
    let markers: Set<Int>
    /// 和弦名称（可选）
    let chordName: String?

    init(frets: [Int?], markers: Set<Int> = [], chordName: String? = nil) {
        self.frets = frets
        self.markers = markers
        self.chordName = chordName
    }
}
