import SwiftUI

// MARK: - 练习模块 (匹配 v0 原型数据)
struct PracticeModuleData: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let exercises: [ExerciseItem]
    
    static let allModules: [PracticeModuleData] = [
        PracticeModuleData(
            id: "hearing",
            title: "听力训练",
            icon: "headphones",
            color: AppTheme.Module.pitch,           // bg-primary
            exercises: [
                ExerciseItem(id: "single-note", title: "单音辨认", mode: .keyboardInput, percentage: 85),
                ExerciseItem(id: "interval-hear", title: "音程听辨", mode: .multipleChoice, percentage: 72),
                ExerciseItem(id: "chord-hear", title: "和弦辨认", mode: .multipleChoice, percentage: 0),
                ExerciseItem(id: "rhythm-hear", title: "节奏辨认", mode: .multipleChoice, percentage: 60),
                ExerciseItem(id: "melody-dictation", title: "旋律听写", mode: .keyboardInput, percentage: 25)
            ]
        ),
        PracticeModuleData(
            id: "sightSinging",
            title: "视唱练习",
            icon: "mic.fill",
            color: AppTheme.Module.melody,          // bg-success
            exercises: [
                ExerciseItem(id: "single-sing", title: "单音视唱", mode: .sightSinging, percentage: 90),
                ExerciseItem(id: "interval-sing", title: "音程构唱", mode: .sightSinging, percentage: 55),
                ExerciseItem(id: "melody-sing", title: "旋律视唱", mode: .sightSinging, percentage: 62),
                ExerciseItem(id: "rhythm-sing", title: "节奏视唱", mode: .sightSinging, percentage: 50)
            ]
        ),
        PracticeModuleData(
            id: "rhythm",
            title: "节奏训练",
            icon: "music.note",
            color: AppTheme.Module.rhythm,          // bg-warning
            exercises: [
                ExerciseItem(id: "quarter", title: "四分音符节奏", mode: .multipleChoice, percentage: 100),
                ExerciseItem(id: "eighth", title: "八分音符节奏", mode: .multipleChoice, percentage: 78),
                ExerciseItem(id: "sixteenth", title: "十六分音符节奏", mode: .multipleChoice, percentage: 35),
                ExerciseItem(id: "syncopation", title: "切分节奏", mode: .multipleChoice, percentage: 20),
                ExerciseItem(id: "triplet", title: "三连音", mode: .multipleChoice, percentage: 15)
            ]
        ),
        PracticeModuleData(
            id: "interval",
            title: "音程训练",
            icon: "square.stack.3d.up",
            color: AppTheme.Module.interval,        // bg-module-interval
            exercises: [
                ExerciseItem(id: "interval-compare", title: "音程比较", mode: .multipleChoice, percentage: 65),
                ExerciseItem(id: "interval-identify", title: "音程辨认", mode: .multipleChoice, percentage: 58),
                ExerciseItem(id: "interval-construct", title: "音程构唱", mode: .sightSinging, percentage: 48)
            ]
        ),
        PracticeModuleData(
            id: "chord",
            title: "和弦训练",
            icon: "pianokeys",
            color: AppTheme.Module.chord,           // bg-module-chord
            exercises: [
                ExerciseItem(id: "triad", title: "三和弦辨认", mode: .multipleChoice, percentage: 52),
                ExerciseItem(id: "seventh-chord", title: "七和弦辨认", mode: .multipleChoice, percentage: 28),
                ExerciseItem(id: "chord-inversion", title: "和弦转位辨认", mode: .multipleChoice, percentage: 12)
            ]
        )
    ]
}

// MARK: - 练习项
struct ExerciseItem: Identifiable, Hashable {
    let id: String
    let title: String
    let mode: ExerciseMode
    let percentage: Int
    
    var totalQuestions: Int { 10 }
}

// MARK: - 练习模式
enum ExerciseMode: String, Hashable {
    case multipleChoice = "选择题"
    case keyboardInput = "键盘输入"
    case sightSinging = "视唱"
    
    var showDecompose: Bool { self != .sightSinging }
}

// MARK: - 乐理分类 (匹配 v0 TheoryTab 数据)
struct TheoryCategoryData: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let topics: [TheoryTopicData]
    
    static let allCategories: [TheoryCategoryData] = [
        TheoryCategoryData(
            id: "basic",
            title: "基础乐理",
            icon: "book.fill",
            color: AppTheme.accent,                   // primary / bg-primary
            topics: [
                TheoryTopicData(id: "notes", title: "认识音符", description: "音符的构成、时值关系"),
                TheoryTopicData(id: "pitch-names", title: "音名与唱名", description: "C-D-E-F-G-A-B 系统"),
                TheoryTopicData(id: "whole-half", title: "全音与半音", description: "吉他指板上的全半音关系"),
                TheoryTopicData(id: "note-duration", title: "音符时值", description: "全音符到十六分音符"),
                TheoryTopicData(id: "beat-signature", title: "节拍与拍号", description: "4/4, 3/4, 6/8 等常见拍号"),
                TheoryTopicData(id: "rhythm-basics", title: "节奏基础", description: "基本节奏型和休止符")
            ]
        ),
        TheoryCategoryData(
            id: "notation",
            title: "识谱知识",
            icon: "music.note.list",
            color: AppTheme.Module.melody,            // success / bg-success
            topics: [
                TheoryTopicData(id: "staff-intro", title: "五线谱入门", description: "五线谱构成与谱号"),
                TheoryTopicData(id: "solfege-intro", title: "简谱入门", description: "数字记谱法"),
                TheoryTopicData(id: "tab-reading", title: "六线谱识谱", description: "吉他专用谱表"),
                TheoryTopicData(id: "clef-key", title: "谱号与调号", description: "调号的识别与应用")
            ]
        ),
        TheoryCategoryData(
            id: "interval",
            title: "音程",
            icon: "square.stack.3d.up",
            color: AppTheme.Module.interval,          // bg-module-interval
            topics: [
                TheoryTopicData(id: "interval-concept", title: "音程的概念", description: "度数与音数"),
                TheoryTopicData(id: "guitar-intervals", title: "吉他常用音程", description: "纯一度到纯八度"),
                TheoryTopicData(id: "interval-quality", title: "音程的性质", description: "大、小、纯、增、减"),
                TheoryTopicData(id: "interval-hearing", title: "音程的听辨技巧", description: "协和与不协和音程")
            ]
        ),
        TheoryCategoryData(
            id: "chord",
            title: "和弦",
            icon: "pianokeys",
            color: AppTheme.Module.chord,             // bg-module-chord
            topics: [
                TheoryTopicData(id: "triads", title: "三和弦", description: "大三、小三、增三、减三"),
                TheoryTopicData(id: "seventh-chords", title: "七和弦", description: "属七、大七、小七和弦", isSpecial: true),
                TheoryTopicData(id: "inversions", title: "和弦转位", description: "第一、第二转位"),
                TheoryTopicData(id: "guitar-chords", title: "吉他和弦指法", description: "开放和弦与横按和弦"),
                TheoryTopicData(id: "chord-hearing", title: "和弦听辨", description: "和弦色彩与进行")
            ]
        ),
        TheoryCategoryData(
            id: "mode",
            title: "调式",
            icon: "music.quaversign",
            color: AppTheme.Module.scale,              // bg-module-scale
            topics: [
                TheoryTopicData(id: "major-scale", title: "大调音阶", description: "自然大调结构"),
                TheoryTopicData(id: "minor-scale", title: "小调音阶", description: "自然、和声、旋律小调"),
                TheoryTopicData(id: "mode-relation", title: "调式关系", description: "关系大小调", isSpecial: true),
                TheoryTopicData(id: "church-modes", title: "中古调式", description: "多利亚、弗里几亚等")
            ]
        ),
        TheoryCategoryData(
            id: "rhythm",
            title: "节奏",
            icon: "metronome",
            color: AppTheme.Module.rhythm,             // bg-warning
            topics: [
                TheoryTopicData(id: "time-signatures", title: "节拍与拍号", description: "单拍子、复拍子"),
                TheoryTopicData(id: "rhythm-patterns", title: "常用节奏型", description: "切分、附点节奏"),
                TheoryTopicData(id: "tuplets", title: "三连音与多连音", description: "连音的演奏"),
                TheoryTopicData(id: "compound-rhythm", title: "复合节奏", description: "复节奏训练")
            ]
        )
    ]
}

// MARK: - 乐理知识点
struct TheoryTopicData: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    var isSpecial: Bool = false
}

// MARK: - 测试项 (匹配 v0 TestTab)
struct TestItemData: Identifiable, Hashable {
    let id: String
    let title: String
    let category: String
    let questionCount: Int
    let timeLimit: Int
    var bestScore: Int? = nil
    var attempts: Int = 0
    var isCompleted: Bool { bestScore != nil }
    
    static let allTests: [TestItemData] = [
        TestItemData(id: "basic-theory", title: "乐理基础测试", category: "乐理", questionCount: 20, timeLimit: 15, bestScore: 85, attempts: 3),
        TestItemData(id: "interval-test", title: "音程听辨测试", category: "听力", questionCount: 15, timeLimit: 10, bestScore: 72, attempts: 2),
        TestItemData(id: "chord-test", title: "和弦辨认测试", category: "听力", questionCount: 15, timeLimit: 12, bestScore: nil, attempts: 0),
        TestItemData(id: "rhythm-test", title: "节奏测试", category: "节奏", questionCount: 10, timeLimit: 8, bestScore: 90, attempts: 5),
        TestItemData(id: "sight-singing-test", title: "视唱综合测试", category: "视唱", questionCount: 10, timeLimit: 15, bestScore: nil, attempts: 0)
    ]
}

// MARK: - 练习结果
struct ExerciseResult: Identifiable, Codable {
    let id: UUID
    let testId: String
    let score: Int
    let correctCount: Int
    let totalQuestions: Int
    let timeSpent: Int
    let date: Date
    
    init(testId: String, score: Int, correctCount: Int, totalQuestions: Int, timeSpent: Int) {
        self.id = UUID()
        self.testId = testId
        self.score = score
        self.correctCount = correctCount
        self.totalQuestions = totalQuestions
        self.timeSpent = timeSpent
        self.date = Date()
    }
}
