import SwiftUI

// MARK: - v0 五大练习分类 (严格匹配原型)
struct PracticeCategoryData: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String       // 听得准 / 唱得准 / 拍得稳 / 听和弦 / 能扒谱
    let description: String
    let systemImage: String
    let color: Color
    let exerciseCount: Int
    let progress: Int          // 百分比 0-100
    let exercises: [PracticeExerciseData]
    
    static let allCategories: [PracticeCategoryData] = [
        PracticeCategoryData(
            id: "pitch",
            title: "音准练习",
            subtitle: "听得准",
            description: "训练音高、音程和旋律的听觉判断",
            systemImage: "headphones",
            color: AppTheme.Category.pitch,
            exerciseCount: 7,
            progress: 35,
            exercises: [
                PracticeExerciseData(id: "single-note", title: "单音辨认", description: "给基准音，判断八度内目标音唱名", hasLevels: false, progress: 85),
                PracticeExerciseData(id: "ascending-interval", title: "上行音程听辨", description: "两音从低到高，判断音程距离", hasLevels: true, levelCount: 6, progress: 45),
                PracticeExerciseData(id: "descending-interval", title: "下行音程听辨", description: "两音从高到低，判断音程距离", hasLevels: true, levelCount: 6, progress: 32),
                PracticeExerciseData(id: "harmonic-interval", title: "和声音程听辨", description: "两音同时响起，判断音程关系", hasLevels: true, levelCount: 6, progress: 28),
                PracticeExerciseData(id: "three-note", title: "三音组合听辨", description: "听三音轮廓、结构和具体音高", hasLevels: true, levelCount: 6, progress: 15),
                PracticeExerciseData(id: "melody-direction", title: "听旋律走向", description: "判断旋律上行、下行或轮廓", hasLevels: true, levelCount: 6, progress: 22),
                PracticeExerciseData(id: "melody-dictation", title: "旋律听写", description: "听旋律，转成简谱或选择正确顺序", hasLevels: true, levelCount: 6, progress: 8),
            ]
        ),
        PracticeCategoryData(
            id: "singing",
            title: "唱准练习",
            subtitle: "唱得准",
            description: "看到提示后准确唱出目标音",
            systemImage: "mic.fill",
            color: AppTheme.Category.singing,
            exerciseCount: 6,
            progress: 28,
            exercises: [
                PracticeExerciseData(id: "single-note-sing", title: "单音视唱", description: "看唱名或听起始音，唱出目标单音", hasLevels: true, levelCount: 5, progress: 72),
                PracticeExerciseData(id: "scale-sing", title: "音阶视唱", description: "按顺序或指定模式唱音阶", hasLevels: true, levelCount: 6, progress: 55),
                PracticeExerciseData(id: "interval-imitate", title: "音程模唱", description: "听两个音，跟着模唱音程距离", hasLevels: true, levelCount: 6, progress: 38),
                PracticeExerciseData(id: "interval-construct", title: "音程构唱", description: "给起始音，唱出指定音程的目标音", hasLevels: true, levelCount: 6, progress: 25),
                PracticeExerciseData(id: "three-note-sing", title: "三音组合模唱", description: "听或看提示，模唱三音组合", hasLevels: true, levelCount: 6, progress: 18),
                PracticeExerciseData(id: "melody-sing", title: "旋律视唱", description: "看简谱旋律唱出来", hasLevels: true, levelCount: 6, progress: 12),
            ]
        ),
        PracticeCategoryData(
            id: "rhythm",
            title: "节奏练习",
            subtitle: "拍得稳",
            description: "节奏三部曲：脚打拍、嘴唱、手执行",
            systemImage: "music.note",
            color: AppTheme.Category.rhythm,
            exerciseCount: 7,
            progress: 42,
            exercises: [
                PracticeExerciseData(id: "quarter-eighth", title: "四分八分节奏", description: "一拍一下和一拍两下的稳定感", hasLevels: true, levelCount: 6, progress: 68),
                PracticeExerciseData(id: "sixteenth", title: "十六分音符节奏", description: "一拍四下的细分能力", hasLevels: true, levelCount: 6, progress: 42),
                PracticeExerciseData(id: "syncopation", title: "切分节奏", description: "重音不在强拍上的节奏感", hasLevels: true, levelCount: 6, progress: 35),
                PracticeExerciseData(id: "triplet", title: "三连音", description: "一拍平均分成三份的感觉", hasLevels: true, levelCount: 6, progress: 15),
                PracticeExerciseData(id: "rhythm-sing", title: "节奏视唱", description: "看节奏谱，用哒/空哒唱出来", hasLevels: true, levelCount: 6, progress: 28),
                PracticeExerciseData(id: "rhythm-memory", title: "节奏背唱", description: "隐藏节奏谱，凭记忆唱或打出来", hasLevels: true, levelCount: 6, progress: 10),
                PracticeExerciseData(id: "strum-rhythm", title: "扫弦节奏", description: "下扫、上扫、重音、切音、闷音", hasLevels: true, levelCount: 6, progress: 22),
            ]
        ),
        PracticeCategoryData(
            id: "chord",
            title: "和弦练习",
            subtitle: "听和弦",
            description: "和弦性质、功能和常用进行",
            systemImage: "pianokeys",
            color: AppTheme.Category.chord,
            exerciseCount: 7,
            progress: 18,
            exercises: [
                PracticeExerciseData(id: "triad-identify", title: "三和弦辨认", description: "大三、小三、减三、增三和弦", hasLevels: true, levelCount: 6, progress: 52),
                PracticeExerciseData(id: "seventh-identify", title: "七和弦辨认", description: "属七、大七、小七等七和弦", hasLevels: true, levelCount: 6, progress: 28),
                PracticeExerciseData(id: "tsd-function", title: "TSD功能判断", description: "判断主、下属、属功能", hasLevels: true, levelCount: 6, progress: 35),
                PracticeExerciseData(id: "chord-progression", title: "常用和弦进行", description: "1645、151、451、6415等", hasLevels: true, levelCount: 6, progress: 22),
                PracticeExerciseData(id: "circle-of-fifths", title: "五度圈练习", description: "理解调性关系和调内和弦", hasLevels: true, levelCount: 6, progress: 15),
                PracticeExerciseData(id: "borrowed-chord", title: "离调和弦听感", description: "副属和弦、借用和弦色彩", hasLevels: true, levelCount: 6, progress: 8),
                PracticeExerciseData(id: "open-chord", title: "吉他开放和弦听辨", description: "C、G、Am、F、Em、Dm等", hasLevels: true, levelCount: 6, progress: 45),
            ]
        ),
        PracticeCategoryData(
            id: "transcription",
            title: "扒谱练习",
            subtitle: "能扒谱",
            description: "把听到的转成谱和弹唱内容",
            systemImage: "doc.text.fill",
            color: AppTheme.Category.transcription,
            exerciseCount: 8,
            progress: 12,
            exercises: [
                PracticeExerciseData(id: "melody-transcribe", title: "旋律扒谱", description: "听旋律，扒出简谱或音高", hasLevels: true, levelCount: 6, progress: 18),
                PracticeExerciseData(id: "rhythm-transcribe", title: "节奏扒谱", description: "听节奏，判断或写出节奏型", hasLevels: true, levelCount: 6, progress: 15),
                PracticeExerciseData(id: "chord-transcribe", title: "和弦扒谱", description: "听和声，判断和弦或功能", hasLevels: true, levelCount: 6, progress: 12),
                PracticeExerciseData(id: "song-transcribe", title: "歌曲片段扒谱", description: "2-4小节真实歌曲片段", hasLevels: true, levelCount: 6, progress: 8),
                PracticeExerciseData(id: "jianpu-complete", title: "简谱补全", description: "补出不完整简谱的缺失音符", hasLevels: true, levelCount: 6, progress: 10),
                PracticeExerciseData(id: "tab-complete", title: "六线谱补全", description: "把旋律落到吉他弦品位置", hasLevels: true, levelCount: 6, progress: 5),
                PracticeExerciseData(id: "chord-label", title: "和弦标注", description: "给旋律或歌词选择合适和弦", hasLevels: true, levelCount: 6, progress: 8),
                PracticeExerciseData(id: "transcribe-review", title: "扒谱复盘", description: "分析错误集中在哪里", hasLevels: true, levelCount: 6, progress: 0),
            ]
        ),
    ]
}

// MARK: - 练习项数据
struct PracticeExerciseData: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let hasLevels: Bool
    var levelCount: Int? = nil
    let progress: Int
}

// MARK: - 练习层级分组数据 (匹配 v0 ExerciseLevelsPage)
struct ExerciseLevelData: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let items: [String]
    let progress: Int
    var completed: Bool { progress >= 100 }
}

// MARK: - 练习项 (保留兼容旧版 ExerciseContainerView)
struct ExerciseItem: Identifiable, Hashable {
    let id: String
    let title: String
    let mode: ExerciseMode
    let percentage: Int
    
    var totalQuestions: Int { 10 }
}

enum ExerciseMode: String, Hashable {
    case multipleChoice = "选择题"
    case keyboardInput = "键盘输入"
    case sightSinging = "视唱"
    
    var showDecompose: Bool { self != .sightSinging }
}

// MARK: - 课时/章节 (CourseTab 保留)
struct CourseLesson: Identifiable, Hashable {
    let id: String
    let title: String
    let difficulty: String
    let duration: String
    var isCompleted: Bool = false
}

struct CourseChapter: Identifiable, Hashable {
    let id: String
    let title: String
    let lessons: [CourseLesson]
    
    var completedCount: Int {
        lessons.filter(\.isCompleted).count
    }
}

// MARK: - 乐理分类 (匹配 v0 TheoryTab)
struct TheoryCategoryData: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String  // v0: 分类描述文本
    let icon: String
    let color: Color
    let topics: [TheoryTopicData]
    
    static let allCategories: [TheoryCategoryData] = [
        TheoryCategoryData(id: "basic", title: "基础乐理", description: "音符、节拍、拍号，搭建音乐的底层认知", icon: "book.fill", color: AppTheme.Theory.basic, topics: [
            TheoryTopicData(id: "notes", title: "认识音符", description: "音符的构成、时值关系"),
            TheoryTopicData(id: "pitch-names", title: "音名与唱名", description: "C-D-E-F-G-A-B 系统"),
            TheoryTopicData(id: "whole-half", title: "全音与半音", description: "吉他指板上的全半音关系"),
            TheoryTopicData(id: "note-duration", title: "音符时值", description: "全音符到十六分音符"),
            TheoryTopicData(id: "beat-signature", title: "节拍与拍号", description: "4/4, 3/4, 6/8 等常见拍号"),
            TheoryTopicData(id: "rhythm-basics", title: "节奏基础", description: "基本节奏型和休止符")
        ]),
        TheoryCategoryData(id: "notation", title: "识谱知识", description: "五线谱、简谱、六线谱，轻松读懂各类记谱", icon: "music.note.list", color: AppTheme.Theory.notation, topics: [
            TheoryTopicData(id: "staff-intro", title: "五线谱入门", description: "五线谱构成与谱号"),
            TheoryTopicData(id: "solfege-intro", title: "简谱入门", description: "数字记谱法"),
            TheoryTopicData(id: "tab-reading", title: "六线谱识谱", description: "吉他专用谱表"),
            TheoryTopicData(id: "clef-key", title: "谱号与调号", description: "调号的识别与应用")
        ]),
        TheoryCategoryData(id: "interval", title: "音程", description: "两音之间的距离，听辨的核心基础", icon: "square.stack.3d.up", color: AppTheme.Theory.interval, topics: [
            TheoryTopicData(id: "interval-concept", title: "音程的概念", description: "度数与音数"),
            TheoryTopicData(id: "guitar-intervals", title: "吉他常用音程", description: "纯一度到纯八度"),
            TheoryTopicData(id: "interval-quality", title: "音程的性质", description: "大、小、纯、增、减"),
            TheoryTopicData(id: "interval-hearing", title: "音程的听辨技巧", description: "协和与不协和音程")
        ]),
        TheoryCategoryData(id: "chord", title: "和弦", description: "多音叠置的色彩，弹唱的骨架所在", icon: "pianokeys", color: AppTheme.Theory.chord, topics: [
            TheoryTopicData(id: "triads", title: "三和弦", description: "大三、小三、增三、减三"),
            TheoryTopicData(id: "seventh-chords", title: "七和弦", description: "属七、大七、小七和弦", isSpecial: true),
            TheoryTopicData(id: "inversions", title: "和弦转位", description: "第一、第二转位"),
            TheoryTopicData(id: "guitar-chords", title: "吉他和弦指法", description: "开放和弦与横按和弦"),
            TheoryTopicData(id: "chord-hearing", title: "和弦听辨", description: "和弦色彩与进行")
        ]),
        TheoryCategoryData(id: "mode", title: "调式", description: "音阶的组织方式，决定音乐的情绪色彩", icon: "tuningfork", color: AppTheme.Theory.mode, topics: [
            TheoryTopicData(id: "major-scale", title: "大调音阶", description: "自然大调结构"),
            TheoryTopicData(id: "minor-scale", title: "小调音阶", description: "自然、和声、旋律小调"),
            TheoryTopicData(id: "mode-relation", title: "调式关系", description: "关系大小调", isSpecial: true),
            TheoryTopicData(id: "church-modes", title: "中古调式", description: "多利亚、弗里几亚等")
        ]),
        TheoryCategoryData(id: "rhythm-theory", title: "节奏", description: "音乐的律动脉搏，让弹唱更有感觉", icon: "metronome", color: AppTheme.Theory.rhythm, topics: [
            TheoryTopicData(id: "time-signatures", title: "节拍与拍号", description: "单拍子、复拍子"),
            TheoryTopicData(id: "rhythm-patterns", title: "常用节奏型", description: "切分、附点节奏"),
            TheoryTopicData(id: "tuplets", title: "三连音与多连音", description: "连音的演奏"),
            TheoryTopicData(id: "compound-rhythm", title: "复合节奏", description: "复节奏训练")
        ])
    ]
}

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
