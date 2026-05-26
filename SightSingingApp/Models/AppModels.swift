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
            exerciseCount: 8,
            progress: 42,
            exercises: [
                PracticeExerciseData(id: "quarter-eighth", title: "四分音符节奏", description: "每拍一下的稳定节拍感", hasLevels: true, levelCount: 15, progress: 68),
                PracticeExerciseData(id: "eighth", title: "八分音符节奏", description: "一拍两下的均匀感", hasLevels: true, levelCount: 6, progress: 0),
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
    let levelItems: [String]          // 当前关卡的选项约束（从 LevelData.items 传入）
    
    var totalQuestions: Int { 10 }
    
    init(id: String, title: String, mode: ExerciseMode, percentage: Int, levelItems: [String] = []) {
        self.id = id
        self.title = title
        self.mode = mode
        self.percentage = percentage
        self.levelItems = levelItems
    }
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
        // MARK: 模块零：吉他与大脑科学
        TheoryCategoryData(id: "brain-science", title: "吉他与大脑科学",
            description: "先理解「为什么这么练」，再开始练。认知决定效率。", icon: "brain.head.profile", color: AppTheme.Theory.brainScience, topics: [
            TheoryTopicData(id: "brain-left-right", title: "左右手分工：课题分离", description: "左手是技术，右手是艺术"),
            TheoryTopicData(id: "brain-relaxation", title: "左放松：最小按压力", description: "找到「刚好能响」的力度"),
            TheoryTopicData(id: "brain-right-hand", title: "右手稳定：小脑+基底节训练", description: "节奏不好不是天赋问题"),
            TheoryTopicData(id: "brain-neural", title: "神经连接需要时间", description: "从大脑控制到身体自动化"),
        ]),
        // MARK: 模块一：基础乐理
        TheoryCategoryData(id: "basic", title: "基础乐理", description: "音符、节拍、音阶、五度圈，搭建音乐的底层认知", icon: "book.fill", color: AppTheme.Theory.basic, topics: [
            TheoryTopicData(id: "pitch-sound", title: "音与音高", description: "十二平均律与吉他指板"),
            TheoryTopicData(id: "interval-core", title: "音程（核心中的核心）⭐", description: "所有和弦、音阶的建造材料"),
            TheoryTopicData(id: "scale-modes-basic", title: "音阶与调式", description: "大调、小调、五声音阶"),
            TheoryTopicData(id: "beat-time-sig", title: "节拍与拍号", description: "4/4、3/4、6/8拍"),
            TheoryTopicData(id: "note-values", title: "音符时值", description: "全音符到三十二分音符"),
            TheoryTopicData(id: "measures", title: "小节与节拍线", description: "强弱规律与跨小节"),
            TheoryTopicData(id: "bpm-speed", title: "速度（BPM）", description: "从极慢板到极速"),
            TheoryTopicData(id: "circle-of-fifths-intro", title: "五度圈（必学）⭐", description: "调性地图与和弦推导", isSpecial: true),
        ]),
        // MARK: 模块二：识谱
        TheoryCategoryData(id: "notation", title: "识谱", description: "六线谱、五线谱、和弦图，轻松读懂各类记谱", icon: "music.note.list", color: AppTheme.Theory.notation, topics: [
            TheoryTopicData(id: "tab-basics", title: "六线谱（TAB）", description: "吉他专用地图"),
            TheoryTopicData(id: "staff-basics", title: "五线谱基础", description: "通用音乐语言"),
            TheoryTopicData(id: "rhythm-notation", title: "节奏符号", description: "决定每个音「弹多久」"),
            TheoryTopicData(id: "chord-diagrams", title: "和弦图", description: "和弦的「照片」"),
            TheoryTopicData(id: "guitar-symbols", title: "吉他专用符号", description: "击勾滑推揉技巧标记"),
            TheoryTopicData(id: "reading-practice", title: "看谱实战", description: "《平凡之路》主歌全拆解"),
        ]),
        // MARK: 模块三：音程
        TheoryCategoryData(id: "interval", title: "音程", description: "12个音程全部掌握，扒歌和即兴的基石", icon: "square.stack.3d.up", color: AppTheme.Theory.interval, topics: [
            TheoryTopicData(id: "interval-review", title: "音程回顾与深化", description: "完整音程表+转位规律"),
            TheoryTopicData(id: "interval-ear-training", title: "音程听辨训练 ⭐", description: "5级难度递进听辨"),
            TheoryTopicData(id: "interval-fretboard", title: "音程在指板上的位置", description: "同弦与跨弦音程指型"),
            TheoryTopicData(id: "interval-chords", title: "音程与和弦的关系", description: "和弦=音程的叠加"),
            TheoryTopicData(id: "bass-perception", title: "Bass音感知训练", description: "听歌先听Bass，最快扒歌法"),
        ]),
        // MARK: 模块四：和弦
        TheoryCategoryData(id: "chord", title: "和弦", description: "三和弦、七和弦、CAGED系统，弹唱的骨架所在", icon: "pianokeys", color: AppTheme.Theory.chord, topics: [
            TheoryTopicData(id: "triad-construction", title: "三和弦构成", description: "大、小、减、增四种三和弦"),
            TheoryTopicData(id: "caged-system", title: "CAGED系统 ⭐", description: "5种指型覆盖全指板"),
            TheoryTopicData(id: "seventh-chords", title: "七和弦", description: "属七、大七、小七和弦", isSpecial: true),
            TheoryTopicData(id: "suspended-chords", title: "挂留和弦", description: "sus2/sus4，悬而未决的美"),
            TheoryTopicData(id: "slash-chords", title: "转位与斜杠和弦", description: "制造流畅低音线"),
            TheoryTopicData(id: "scale-degrees", title: "级数思维 ⭐⭐", description: "一套走向=任何调都能弹"),
            TheoryTopicData(id: "tsd-function", title: "和弦功能组TSD ⭐", description: "家→出发→回家 的情绪弧线"),
            TheoryTopicData(id: "major-progressions", title: "大调常用和弦走向 ⭐⭐⭐", description: "1645、1564、卡农走向"),
            TheoryTopicData(id: "minor-progressions", title: "小调常用和弦走向", description: "小调独特的情绪色彩"),
            TheoryTopicData(id: "chord-substitution", title: "和弦替换与色彩", description: "同一个走向，不同的色彩"),
        ]),
        // MARK: 模块五：调式与转调
        TheoryCategoryData(id: "mode", title: "调式与转调", description: "关系大小调、Capo、中古调式，听懂调性的秘密", icon: "tuningfork", color: AppTheme.Theory.mode, topics: [
            TheoryTopicData(id: "relative-keys", title: "关系大小调", description: "共享同一组音的大小调"),
            TheoryTopicData(id: "parallel-keys", title: "同主音大小调", description: "主音相同，情绪巨变"),
            TheoryTopicData(id: "twelve-keys", title: "十二个调的推导", description: "用五度圈推导所有调"),
            TheoryTopicData(id: "capo-usage", title: "变调夹（Capo）使用", description: "移动的琴枕，简单指法弹高调"),
            TheoryTopicData(id: "modulation-methods", title: "转调的几种方式", description: "直接转、共同和弦转、半音转"),
            TheoryTopicData(id: "church-modes-advanced", title: "调式音阶（进阶）", description: "Dorian、Mixolydian等"),
            TheoryTopicData(id: "mode-identification", title: "调式辨识训练", description: "听歌判断大小调和主音"),
            TheoryTopicData(id: "key-finding", title: "定调实战", description: "三步确定一首歌的调"),
        ]),
        // MARK: 模块六：节奏
        TheoryCategoryData(id: "rhythm-theory", title: "节奏", description: "节拍感三部曲、扫弦节奏型、右手独立性训练", icon: "metronome", color: AppTheme.Theory.rhythmTheory, topics: [
            TheoryTopicData(id: "beat-feeling", title: "节拍感建立", description: "脚打拍子+嘴唱，训练小脑"),
            TheoryTopicData(id: "basic-rhythm-patterns", title: "基本节奏型", description: "四分、八分、十六分、附点"),
            TheoryTopicData(id: "strum-patterns", title: "常用扫弦节奏型 ⭐", description: "万能民谣扫弦、分解和弦"),
            TheoryTopicData(id: "syncopation", title: "切分音", description: "弱拍变重，创造律动"),
            TheoryTopicData(id: "rest-usage", title: "休止符的运用", description: "敢停=节奏感好的标志"),
            TheoryTopicData(id: "right-hand-independence", title: "右手独立性训练 ⭐⭐", description: "右手永不断，像钟摆一样"),
            TheoryTopicData(id: "rhythm-layers", title: "节奏层次", description: "主歌轻→副歌重 的情绪设计"),
            TheoryTopicData(id: "rubato", title: "Rubato（自由速度）", description: "先练稳，再学自由"),
        ]),
        // MARK: 模块七：和弦指板数据库
        TheoryCategoryData(id: "fretboard", title: "和弦指板数据库", description: "四/五/六弦根音三和弦+七和弦+转位全指板位置", icon: "square.grid.3x3", color: AppTheme.Theory.fretboard, topics: [
            TheoryTopicData(id: "4string-root-triads", title: "四弦根音·三和弦指型", description: "以D弦为根音的大/小/减/增"),
            TheoryTopicData(id: "5string-root-triads", title: "五弦根音·三和弦指型", description: "以A弦为根音的三和弦"),
            TheoryTopicData(id: "6string-root-triads", title: "六弦根音·三和弦指型", description: "以E弦为根音，横按指型基础"),
            TheoryTopicData(id: "triad-inversions", title: "三和弦转位", description: "原位、一转、二转全指板位置"),
            TheoryTopicData(id: "4string-root-sevenths", title: "四弦根音·七和弦指型", description: "maj7/m7/7/m7♭5/dim7"),
            TheoryTopicData(id: "5string-root-sevenths", title: "五弦根音·七和弦指型", description: "微调一品就能换和弦性质"),
            TheoryTopicData(id: "6string-root-sevenths", title: "六弦根音·七和弦指型", description: "C调2-5-1-6全把位串联"),
            TheoryTopicData(id: "color-chords", title: "常见色彩和弦大全", description: "sus2/sus4/add9/69/maj9/m11等"),
        ]),
        // MARK: 模块八：和弦进行与替代
        TheoryCategoryData(id: "progressions", title: "和弦进行与替代",
            description: "顺阶和弦、2-5-1、四度圈替代、Leading Bass", icon: "arrow.triangle.branch", color: AppTheme.Theory.progressions, topics: [
            TheoryTopicData(id: "diatonic-chords", title: "顺阶和弦系统", description: "自然音阶构建的七级和弦"),
            TheoryTopicData(id: "two-five-one-2", title: "2-5-1进行构建（二级法）", description: "爵士最核心的和弦进行"),
            TheoryTopicData(id: "two-five-one-3", title: "2-5-1进行构建（三级法）", description: "三级作为临时一级"),
            TheoryTopicData(id: "1645-substitutions", title: "1-6-4-5万能替代", description: "从三和弦到七和弦到色彩替代"),
            TheoryTopicData(id: "1564-substitutions", title: "1-5-6-4万能替代", description: "爵士版、丰富版、实战案例"),
            TheoryTopicData(id: "4536251-substitutions", title: "4-5-3-6-2-5-1替代", description: "华语万能走向的终极丰富版"),
            TheoryTopicData(id: "leading-bass", title: "Leading Bass套路", description: "低音像一条旋律独立行走"),
            TheoryTopicData(id: "chromatic-bass", title: "半音低音进行", description: "细腻的半音下行和声色彩"),
        ]),
        // MARK: 模块九：转调实战
        TheoryCategoryData(id: "transposition", title: "转调实战",
            description: "同主音转调、降六级转调、五度圈转调", icon: "arrow.left.arrow.right", color: AppTheme.Theory.transposition, topics: [
            TheoryTopicData(id: "major-to-parallel-minor", title: "同主音大调转小调", description: "C大→C小，明亮→暗淡"),
            TheoryTopicData(id: "minor-to-parallel-major", title: "同主音小调转大调", description: "暗淡→明亮，情绪反转"),
            TheoryTopicData(id: "flat-6-modulation", title: "降六级转调法", description: "♭6级和弦作桥过渡"),
            TheoryTopicData(id: "relative-key-modulation", title: "关系大小调转调", description: "最自然的转调方式"),
            TheoryTopicData(id: "circle-modulation", title: "五度圈转调法", description: "相邻调与隔调转调"),
            TheoryTopicData(id: "modulation-practice", title: "转调实战综合", description: "转调决策树与吉他实现"),
        ]),
        // MARK: 模块十：伴奏思维与实战
        TheoryCategoryData(id: "accompaniment", title: "伴奏思维与实战",
            description: "服务思维、扫弦讲故事、力度层次、切音编配", icon: "music.mic", color: AppTheme.Theory.accompaniment, topics: [
            TheoryTopicData(id: "accompaniment-essence", title: "伴奏的本质：服务", description: "不抢戏、节奏稳、听歌手"),
            TheoryTopicData(id: "drummer-thinking", title: "鼓手思维", description: "2拍和4拍是节奏的骨架"),
            TheoryTopicData(id: "strum-storytelling", title: "用扫弦讲故事", description: "主歌轻→副歌重→高潮爆发"),
            TheoryTopicData(id: "dynamics-training", title: "力度层次训练", description: "四级力度梯度 20%→80%"),
            TheoryTopicData(id: "palm-muting", title: "切音技巧", description: "用停顿制造律动"),
            TheoryTopicData(id: "accompaniment-layers", title: "伴奏层次实战", description: "分解→扫弦→拍弦的层次设计"),
        ]),
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
