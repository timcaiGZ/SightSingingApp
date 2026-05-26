import SwiftUI

// MARK: - 乐理知识点详细内容数据模型

/// 知识点章节
struct TheorySection: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    var graphicType: GraphicType = .none
    var graphicData: GraphicData? = nil
}

/// 图形类型
enum GraphicType: String {
    case none
    case solfegeNotes        // 简谱音符展示
    case intervalList        // 音程列表
    case chordDiagram        // 和弦指法图
    case cagedShapes         // CAGED五大形状展示
    case cagedScaleChords    // CAGED调性和弦级数展示
    case fretboardHalfNotes  // 吉他指板半音图
    case scaleStructure      // 音阶结构图
    case noteDuration        // 音符时值关系
    case wholeHalfFlow       // 全音半音流向图
    case circleOfFifths      // 五度圈交互
    case chordType           // 和弦类型展示
    case beatSignature       // 拍号展示
    case rhythmPattern       // 节奏型展示
    // 新增：王大园+小艾课程图形
    case chordConstruction   // 和弦构成公式+指板对照
    case chordProgression    // 和弦进行流程图（含TSD色彩）
    case tsdFunctionalGroup  // TSD功能组色彩图
    case bassLine            // Leading Bass低音线图
    case chordComparison     // 对比图（并排+差异高亮）
    case modulationPath      // 转调路径图
    case colorChordTable     // 色彩和弦对照表
}

/// 图形数据
struct GraphicData {
    var notes: [String] = []           // 音符/唱名列表
    var labels: [String] = []          // 标签
    var intervals: [IntervalItem] = [] // 音程列表
    var chords: [ChordGraphicItem] = []// 和弦图
    var cagedChordName: String = ""    // CAGED形状目标和弦名
    var cagedScaleName: String = ""    // CAGED调性名称
    var flowItems: [String] = []       // 流向图标签
    var highlightIndices: Set<Int> = []// 高亮索引
    // 新增字段
    var progressionChords: [String] = []  // 和弦进行如 ["C","Am","F","G"]
    var progressionDegrees: [String] = [] // 级数如 ["I","vi","IV","V"]
    var progressionLabels: [String] = []  // TSD标签如 ["T","T","S","D"]
    var bassNotes: [String] = []       // 低音线如 ["C","B","A","G","F","G"]
    var bassChords: [String] = []      // 对应和弦如 ["C","C/B","Am","Am/G","F","G"]
    var comparisonLeft: [String] = []  // 左边内容
    var comparisonRight: [String] = [] // 右边内容
    var comparisonDiff: String = ""    // 差异说明
    var modulationFrom: String = ""    // 起始调
    var modulationTo: String = ""      // 目标调
    var modulationDiffNotes: [String] = [] // 变化音如 ["♭E","♭A","♭B"]
    var modulationUnchangedNotes: [String] = [] // 不变音
    var colorChordBase: String = ""    // 基础和弦
    var colorChordVariants: [String] = [] // 色彩变体和弦名
    var colorChordFeelings: [String] = [] // 色彩感受描述
    var tsdGroups: [(group: String, color: String, chords: [String], desc: String)] = [] // TSD组
    var chordFormula: String = ""      // 和弦公式如 "1-3-5"
    var chordNotes: [String] = []      // 和弦构成音如 ["C","E","G"]
    var chordIntervals: [String] = []  // 和弦音程如 ["大三度","小三度"]
    var chordNoteRoles: [String] = []  // 音的角色如 ["根音","三音","五音"]
}

/// 音程条目
struct IntervalItem: Identifiable {
    let id = UUID()
    let name: String
    let notes: String
    let semitones: Int
}

/// 和弦图形条目
struct ChordGraphicItem: Identifiable {
    let id = UUID()
    let name: String
    let frets: [Int?]
    let fingers: [Int?]
}

/// 知识点详情
struct TheoryDetailData: Identifiable {
    let id = UUID()
    let topicId: String
    let title: String
    let sections: [TheorySection]
    var showCircleOfFifths: Bool = false
    var audioExample: String? = nil   // 音频示例说明
}

// MARK: - 知识点内容数据库

enum TheoryDetailDatabase {
    
    /// 根据 topicId 获取知识点详情
    static func getDetail(for topicId: String) -> TheoryDetailData {
        guard let data = allDetails[topicId] else {
            return TheoryDetailData(
                topicId: topicId,
                title: "知识点",
                sections: [
                    TheorySection(title: "内容", content: "该知识点的详细内容正在完善中，敬请期待...")
                ]
            )
        }
        return data
    }
    
    // MARK: - 全部知识点
    
    static let allDetails: [String: TheoryDetailData] = {
        var map: [String: TheoryDetailData] = [:]
        for detail in allDetailsArray {
            map[detail.topicId] = detail
        }
        return map
    }()
    
    static let allDetailsArray: [TheoryDetailData] = [
        // ========== 基础乐理 ==========
        TheoryDetailData(topicId: "notes", title: "认识音符", sections: [
            TheorySection(title: "音符的构成", content: "音符由三个部分组成：符头、符干和符尾。符头决定音高位置，符干和符尾决定音符时值。", graphicType: .noteDuration),
            TheorySection(title: "时值关系", content: "每种音符的时值是前一种的一半。在吉他中最常用四分音符和八分音符。", graphicType: .noteDuration),
        ]),
        
        TheoryDetailData(topicId: "pitch-names", title: "音名与唱名", sections: [
            TheorySection(title: "音名系统 (C-D-E-F-G-A-B)", content: "西方音乐使用七个字母表示音名，对应钢琴白键。这七个音构成一个完整的八度音阶。", graphicType: .solfegeNotes, graphicData: GraphicData(notes: ["C", "D", "E", "F", "G", "A", "B"])),
            TheorySection(title: "唱名系统 (Do-Re-Mi)", content: "唱名帮助我们更容易地视唱乐谱。首调唱名法中主音唱Do，更适合吉他弹唱。", graphicType: .solfegeNotes, graphicData: GraphicData(notes: ["1", "2", "3", "4", "5", "6", "7"], labels: ["do", "re", "mi", "fa", "sol", "la", "si"])),
        ]),
        
        TheoryDetailData(topicId: "whole-half", title: "全音与半音", sections: [
            TheorySection(title: "半音的定义", content: "半音是音程中最小的单位。在吉他上，相邻两个品位之间就是一个半音。从第1品到第2品就是1个半音。", graphicType: .fretboardHalfNotes),
            TheorySection(title: "自然音阶中的全半音", content: "在自然音阶中，E-F 和 B-C 之间是天然半音，其他相邻音之间都是全音（两个半音）。这是理解调式的基础。", graphicType: .wholeHalfFlow, graphicData: GraphicData(flowItems: ["C", "全", "D", "全", "E", "半", "F", "全", "G", "全", "A", "全", "B", "半", "C"], highlightIndices: [4, 13])),
        ]),
        
        TheoryDetailData(topicId: "note-duration", title: "音符时值", sections: [
            TheorySection(title: "音符时值体系", content: "在以四分音符为一拍的体系中，全音符持续4拍，二分音符2拍，四分音符1拍，八分音符半拍，十六分音符1/4拍。", graphicType: .solfegeNotes, graphicData: GraphicData(notes: ["4拍", "2拍", "1拍", "½拍", "¼拍"], labels: ["全音符", "二分", "四分", "八分", "十六分"])),
            TheorySection(title: "附点音符", content: "附点增加原音符时值的一半。例如附点四分音符 = 1拍 + 半拍 = 1.5拍。"),
            TheorySection(title: "在吉他中的运用", content: "掌握时值是节奏精准的基础。弹唱中需要准确判断每个和弦持续几拍、什么时候切换。"),
        ]),
        
        TheoryDetailData(topicId: "beat-signature", title: "节拍与拍号", sections: [
            TheorySection(title: "拍号的含义", content: "拍号用两个数字表示，如4/4：上方数字表示每小节有几拍，下方数字表示以几分音符为一拍。4/4是最常见的拍号。", graphicType: .beatSignature),
            TheorySection(title: "常见拍号", content: "4/4（强-弱-次强-弱）用于大多数流行歌；3/4（强-弱-弱）用于圆舞曲；6/8（强-弱-弱-次强-弱-弱）有流动感。"),
            TheorySection(title: "拍子在吉他中的体现", content: "弹唱时右脚打拍是最基本的节奏训练，跟着节拍器练习可以极大提升节奏感。"),
        ]),
        
        TheoryDetailData(topicId: "rhythm-basics", title: "节奏基础", sections: [
            TheorySection(title: "基本节奏型", content: "最常见的节奏型包括：四分音符节奏（每一拍一个音）、八分音符节奏（一拍两个音）、切分节奏（重音在弱拍）。", graphicType: .rhythmPattern),
            TheorySection(title: "休止符", content: "休止符表示不发声的时值。全休止（4拍）、二分休止（2拍）、四分休止（1拍）、八分休止（半拍）。在弹唱中，休止同样重要。"),
            TheorySection(title: "节奏训练方法", content: "1. 先听节拍器建立稳定拍感 2. 用'哒'唱出节奏型 3. 手脚配合：脚打拍+手拍节奏 4. 融入弹唱。"),
        ]),
        
        // ========== 识谱知识 ==========
        TheoryDetailData(topicId: "staff-intro", title: "五线谱入门", sections: [
            TheorySection(title: "五线谱的构成", content: "五线谱由五条平行的线组成，音符可以放在线上或线间。从下往上数，分别是第一线到第五线。"),
            TheorySection(title: "高音谱号", content: "高音谱号（G谱号）标记在第二线上，表示第二线上的音名为G。吉他弹唱主要用于高音谱号。"),
            TheorySection(title: "加线", content: "当音高超出五线谱范围时，使用短小的加线来扩展记谱范围。C4（中央C）在五线谱下方加一线上。"),
        ]),
        
        TheoryDetailData(topicId: "solfege-intro", title: "简谱入门", sections: [
            TheorySection(title: "数字简谱基础", content: "简谱用数字1-7表示七个基本音级，对应do/re/mi/fa/sol/la/si。上方加点表示高八度，下方加点表示低八度。", graphicType: .solfegeNotes, graphicData: GraphicData(notes: ["1", "2", "3", "4", "5", "6", "7"], labels: ["do", "re", "mi", "fa", "sol", "la", "si"])),
            TheorySection(title: "简谱中的时值", content: "简谱在数字下方加横线表示减时：一条横线表示八分音符，两条横线表示十六分音符。数字右方加附点表示延长一半时值。"),
            TheorySection(title: "吉他弹唱中的简谱", content: "简谱最常用于吉他弹唱记谱，简单直观。和弦标记放在简谱上方，便于自弹自唱。"),
        ]),
        
        TheoryDetailData(topicId: "tab-reading", title: "六线谱识谱", sections: [
            TheorySection(title: "六线谱结构", content: "六线谱（TAB）专为吉他设计。六条线代表吉他的六根弦，最上线代表最细的第1弦（高音E），最下线代表第6弦（低音E）。"),
            TheorySection(title: "品位数字", content: "线上的数字表示左手按弦的品位：0表示空弦，1表示第1品，2表示第2品，以此类推。同时出现的数字在同一拍弹响。"),
            TheorySection(title: "节奏的表示", content: "六线谱通常与五线谱或简谱配合使用。音符的符干和符尾会标记在六线谱上方，用于表示节奏时值。"),
        ]),
        
        TheoryDetailData(topicId: "clef-key", title: "谱号与调号", sections: [
            TheorySection(title: "谱号的作用", content: "谱号确定五线谱每条线上的音名。高音谱号使第二线为G，低音谱号使第四线为F。吉他使用高音谱号。"),
            TheorySection(title: "调号的读写", content: "调号标记在谱号之后，表示全曲固定的升降音。一个升号是G大调，两个升号是D大调。每个升号按F-C-G-D-A-E-B顺序出现。"),
            TheorySection(title: "吉他视角", content: "理解调号有助于快速判断歌曲的调性，从而选择合适的变调夹位置和和弦进行。"),
        ]),
        
        // ========== 音程 ==========
        TheoryDetailData(topicId: "interval-concept", title: "音程的概念", sections: [
            TheorySection(title: "什么是音程", content: "音程是两个音之间的音高距离，用'度'来表示。度数由两个音之间包含的音名数量决定，性质描述具体的半音数量。"),
            TheorySection(title: "常见音程", content: "以下是吉他中常用的音程及其半音数量：", graphicType: .intervalList, graphicData: GraphicData(intervals: [
                IntervalItem(name: "小二度", notes: "E → F", semitones: 1),
                IntervalItem(name: "大二度", notes: "C → D", semitones: 2),
                IntervalItem(name: "小三度", notes: "A → C", semitones: 3),
                IntervalItem(name: "大三度", notes: "C → E", semitones: 4),
                IntervalItem(name: "纯四度", notes: "C → F", semitones: 5),
                IntervalItem(name: "纯五度", notes: "C → G", semitones: 7),
                IntervalItem(name: "纯八度", notes: "C → C", semitones: 12),
            ])),
        ]),
        
        TheoryDetailData(topicId: "guitar-intervals", title: "吉他常用音程", sections: [
            TheorySection(title: "从吉他视角理解音程", content: "在吉他指板上，每一品是一个半音。例如从第5弦第3品（C）到同弦第5品（D）是两个半音，即大二度。", graphicType: .fretboardHalfNotes),
            TheorySection(title: "弦间音程关系", content: "标准调音下，相邻弦（除3-2弦外）相差纯四度（5个半音）。3弦到2弦相差大三度（4个半音）。理解这个关系是快速推算指板音名的基础。"),
            TheorySection(title: "常用音程的音色特点", content: "纯五度：稳定、强力（强力和弦）；大三度：明亮、快乐；小三度：柔和、忧伤；纯四度：空旷；小二度：紧张、不协和。"),
        ]),
        
        TheoryDetailData(topicId: "interval-quality", title: "音程的性质", sections: [
            TheorySection(title: "性质的分类", content: "音程按性质分为：纯音程（纯一度、纯四度、纯五度、纯八度）、大/小音程（二度、三度、六度、七度）、增/减音程（扩大或缩小半音）。"),
            TheorySection(title: "性质与半音", content: "大音程比小音程多一个半音。例如大三度=4个半音，小三度=3个半音。纯四度=5个半音，增四度=6个半音（也称三全音）。"),
            TheorySection(title: "协和与不协和", content: "纯音程（纯四度/五度/八度）完全协和；大小三度/六度不完全协和、悦耳；二度/七度/增四度不协和，制造紧张感。"),
        ]),
        
        TheoryDetailData(topicId: "interval-hearing", title: "音程的听辨技巧", sections: [
            TheorySection(title: "用熟悉的歌曲记忆音程", content: "上行纯四度 = 《婚礼进行曲》开头'当当当当'；上行纯五度 = 《小星星》'一闪一闪'；大六度 = 《茉莉花》开头。"),
            TheorySection(title: "训练方法", content: "1. 先用基准音建立音高记忆 2. 逐对听辨同向音程 3. 区分大三度/小三度的明亮/柔和区别 4. 加入增减音程。"),
            TheorySection(title: "在吉他上练习", content: "在同一弦上弹奏两个不同品位的音，听辨它们的音程关系。先练纯音程（纯四/五/八度），再练大小音程。"),
        ]),
        
        // ========== 和弦 ==========
        TheoryDetailData(topicId: "triads", title: "三和弦", sections: [
            TheorySection(title: "大三和弦", content: "由根音、大三度和纯五度构成。以C大三和弦为例：C(根音) → E(大三度, 4半音) → G(纯五度, 7半音)。声音明亮、稳定、有力量感。", graphicType: .chordDiagram, graphicData: GraphicData(chords: [
                ChordGraphicItem(name: "C", frets: [nil, 3, 2, 0, 1, 0], fingers: [nil, 3, 2, nil, 1, nil]),
                ChordGraphicItem(name: "G", frets: [3, 2, 0, 0, 0, 3], fingers: [2, 1, nil, nil, nil, 3]),
                ChordGraphicItem(name: "D", frets: [nil, nil, 0, 2, 3, 2], fingers: [nil, nil, nil, 1, 3, 2])
            ])),
            TheorySection(title: "小三和弦", content: "由根音、小三度和纯五度构成。以Am为例：A → C(小三度, 3半音) → E(纯五度)。声音柔和、略带忧伤、有情感深度。", graphicType: .chordDiagram, graphicData: GraphicData(chords: [
                ChordGraphicItem(name: "Am", frets: [nil, 0, 2, 2, 1, 0], fingers: [nil, nil, 2, 3, 1, nil]),
                ChordGraphicItem(name: "Em", frets: [0, 2, 2, 0, 0, 0], fingers: [nil, 2, 3, nil, nil, nil]),
                ChordGraphicItem(name: "Dm", frets: [nil, nil, 0, 2, 3, 1], fingers: [nil, nil, nil, 2, 3, 1])
            ])),
            TheorySection(title: "增三和弦与减三和弦", content: "增三和弦由大三度+大三度构成（如Caug: C-E-G#），声音紧张、膨胀。减三和弦由小三度+小三度构成（如Bdim: B-D-F），声音暗沉、不稳定。"),
            TheorySection(title: "C大调各级和弦 · CAGED按法", content: "CAGED系统将五度基本形状移动到不同把位，演奏各级和弦。点击展开查看各级和弦的CAGED五大按法：", graphicType: .cagedScaleChords, graphicData: GraphicData(cagedScaleName: "C")),
        ]),
        
        TheoryDetailData(topicId: "inversions", title: "和弦转位", sections: [
            TheorySection(title: "什么是转位", content: "和弦转位是指和弦中最低的音不再是根音。原位：根音在最下方；第一转位：三音在最下方；第二转位：五音在最下方。"),
            TheorySection(title: "C大三和弦的转位", content: "原位：C-E-G（根音C在最低）；第一转位：E-G-C（三音E在最低，标记C/E）；第二转位：G-C-E（五音G在最低，标记C/G）。"),
            TheorySection(title: "吉他上的应用", content: "转位和弦可以让和声连接更流畅。例如G/B（G和弦第一转位）常用作C到Am之间的过渡和弦，低音线形成C→B→A的流畅下行。"),
        ]),
        
        TheoryDetailData(topicId: "guitar-chords", title: "吉他和弦指法", sections: [
            TheorySection(title: "C 大三和弦 · CAGED 五大按法", content: "CAGED系统用5种基本形状覆盖整个指板。以C和弦为例，C型在开放把位，A型在第3品，G型在第5品，E型在第8品，D型在第10品。掌握这5种按法等于在指板上随处可弹C和弦。", graphicType: .cagedShapes, graphicData: GraphicData(cagedChordName: "C")),
            TheorySection(title: "常用开放和弦", content: "开放和弦利用空弦音，音色丰富、饱满，是民谣吉他最常用的和弦形式。C、G、Am、Em是初学者最先掌握的四个和弦。", graphicType: .chordDiagram, graphicData: GraphicData(chords: [
                ChordGraphicItem(name: "C", frets: [nil, 3, 2, 0, 1, 0], fingers: [nil, 3, 2, nil, 1, nil]),
                ChordGraphicItem(name: "G", frets: [3, 2, 0, 0, 0, 3], fingers: [2, 1, nil, nil, nil, 3]),
                ChordGraphicItem(name: "Am", frets: [nil, 0, 2, 2, 1, 0], fingers: [nil, nil, 2, 3, 1, nil]),
                ChordGraphicItem(name: "Em", frets: [0, 2, 2, 0, 0, 0], fingers: [nil, 2, 3, nil, nil, nil])
            ])),
            TheorySection(title: "F和弦（横按和弦）", content: "F和弦需要食指横按第1品全部6根弦，中指按3弦2品，无名指和小指分别按4弦和5弦的第3品。掌握F和弦后可以移把位演奏各种和弦。"),
            TheorySection(title: "F 大三和弦 · CAGED 五大按法", content: "F和弦的CAGED五大形状：E型在第1品（常用横按），D型在第3品，C型在第5品，A型在第8品，G型在第10品。", graphicType: .cagedShapes, graphicData: GraphicData(cagedChordName: "F")),
        ]),
        
        // CAGED系统专题
        TheoryDetailData(topicId: "caged-chords", title: "CAGED和弦按法", sections: [
            TheorySection(title: "什么是 CAGED 系统", content: "CAGED 系统用 5 种开放和弦形状覆盖整个吉他指板：C型、A型、G型、E型、D型。每种形状都可以移动到不同品位，从而在指板任意位置演奏同一个和弦。"),
            TheorySection(title: "C 大三和弦五大按法", content: "以C大和弦为例，只需移动5种基本形状：C型在开放把位（最常用），A型在第3品横按，G型在第5品，E型在第8品横按，D型在第10品。根音用R标记。", graphicType: .cagedShapes, graphicData: GraphicData(cagedChordName: "C")),
            TheorySection(title: "Am 小三和弦五大按法", content: "同样原理适用于小三和弦。以Am为例：A型在开放把位，G型在第2品，E型在第5品横按，D型在第7品，C型在第9品。", graphicType: .cagedShapes, graphicData: GraphicData(cagedChordName: "Am")),
            TheorySection(title: "F 大三和弦五大按法", content: "F和弦本身就是E型在第1品的横按。五大形状为：E型第1品，D型第3品，C型第5品，A型第8品，G型第10品。", graphicType: .cagedShapes, graphicData: GraphicData(cagedChordName: "F")),
            TheorySection(title: "G 大三和弦五大按法", content: "G和弦G型在开放把位，E型在第3品横按，D型在第5品，C型在第7品，A型在第10品。掌握了CAGED就掌握了G和弦全指板。", graphicType: .cagedShapes, graphicData: GraphicData(cagedChordName: "G")),
            TheorySection(title: "Dm 小三和弦五大按法", content: "Dm小三和弦：D型在开放把位，C型在第5品，A型在第5品横按，G型在第7品，E型在第10品横按。", graphicType: .cagedShapes, graphicData: GraphicData(cagedChordName: "Dm")),
            TheorySection(title: "Em 小三和弦五大按法", content: "Em小三和弦：E型在开放把位，D型在第2品，C型在第4品，A型在第7品横按，G型在第9品。Em的E型开放把位是入门必会。", graphicType: .cagedShapes, graphicData: GraphicData(cagedChordName: "Em")),
            TheorySection(title: "C大调各级和弦CAGED按法", content: "点击展开查看C大调各级和弦（Ⅰ-ⅶ°）在CAGED系统下的五种按法。掌握这些就等于掌握了C大调所有和弦的全指板位置。", graphicType: .cagedScaleChords, graphicData: GraphicData(cagedScaleName: "C")),
        ]),

        TheoryDetailData(topicId: "chord-hearing", title: "和弦听辨", sections: [
            TheorySection(title: "听辨方法", content: "先听低音（根音位置）→ 听色彩（大/小/属七）→ 听功能（主/下属/属）。训练时从大三和弦和小三和弦的二选一开始。"),
            TheorySection(title: "和弦色彩速记", content: "大三和弦→明亮快乐；小三和弦→柔和忧伤；属七和弦→有张力想解决到主；减三和弦→紧张不稳定；增三和弦→梦幻漂浮。"),
            TheorySection(title: "在练习中训练", content: "推荐使用本App的和弦辨认测试来系统训练和弦听辨能力。"),
        ]),
        
        // ========== 调式 ==========
        TheoryDetailData(topicId: "major-scale", title: "大调音阶", sections: [
            TheorySection(title: "自然大调结构", content: "大调音阶由'全全半全全全半'的音程结构组成。以C大调为例：C -全- D -全- E -半- F -全- G -全- A -全- B -半- C。", graphicType: .scaleStructure),
            TheorySection(title: "常用大调", content: "C大调无升降号最易学习；G大调（1个升号#F）和D大调（2个升号#F,#C）是吉他最常用的调。E大调和A大调也是吉他常用调。"),
            TheorySection(title: "吉他上的大调音阶", content: "从C音（5弦3品）开始弹奏C大调音阶：C→D→E→F→G→A→B→C，感受'全全半全全全半'的音响结构。"),
        ], showCircleOfFifths: true),
        
        TheoryDetailData(topicId: "minor-scale", title: "小调音阶", sections: [
            TheorySection(title: "自然小调", content: "自然小调的结构为'全半全全半全全'。以A自然小调为例：A -全- B -半- C -全- D -全- E -半- F -全- G -全- A。与C大调使用完全相同的音集，只是主音不同。"),
            TheorySection(title: "和声小调", content: "将自然小调的第七级音升高半音，得到和声小调。A和声小调为A-B-C-D-E-F-G#-A。特色是从第6级到第7级的增二度跳进。"),
            TheorySection(title: "旋律小调", content: "旋律小调上行时升高第6、7级，下行时还原（同自然小调）。上行：A-B-C-D-E-F#-G#-A。"),
        ]),
        
        TheoryDetailData(topicId: "church-modes", title: "中古调式", sections: [
            TheorySection(title: "七种中古调式", content: "以C大调的七个音分别作为主音，得到七种调式：Ionian（自然大调）、Dorian、Phrygian、Lydian、Mixolydian、Aeolian（自然小调）、Locrian。"),
            TheorySection(title: "吉他常用的调式", content: "Dorian调式（如D Dorian=D-E-F-G-A-B-C-D）常用于Funk和Blues；Mixolydian调式（如G Mixolydian=G-A-B-C-D-E-F-G）常用于摇滚和Blues。"),
            TheorySection(title: "调式与和弦", content: "每种调式有其特色和弦进行。Dorian常用Im-IV7；Mixolydian常用I-bVII-IV。"),
        ]),
        
        // ========== 节奏 ==========
        TheoryDetailData(topicId: "time-signatures", title: "节拍与拍号", sections: [
            TheorySection(title: "单拍子", content: "每一拍都可以分成两个等分的拍子。如2/4（二拍子）、3/4（三拍子）、4/4（四拍子）。流行音乐绝大多数是4/4拍。", graphicType: .beatSignature),
            TheorySection(title: "复拍子", content: "每一拍可以分成三个等分的拍子。如6/8（每小节两拍，每拍三等分）、9/8、12/8。6/8有一种摇摆流动的感觉。"),
            TheorySection(title: "吉他弹唱应用的拍子", content: "4/4：民谣、摇滚、流行标配；3/4：圆舞曲风格弹唱；6/8：慢摇、抒情歌曲。"),
        ]),
        
        TheoryDetailData(topicId: "rhythm-patterns", title: "常用节奏型", sections: [
            TheorySection(title: "切分节奏", content: "切分节奏打破正常的强拍规律，让弱拍或弱位上的音获得重音。典型切分：X   X   在'1 2 3 4'中重音落在2和4。", graphicType: .rhythmPattern),
            TheorySection(title: "附点节奏", content: "附点增加原时值的一半。附点四分音符+八分音符是最常见的附点节奏型，产生'长-短'的律动感。"),
            TheorySection(title: "吉他扫弦节奏型", content: "基础扫弦：↓ ↓ ↑ ↓ ↓ ↑ 或 ↓ ↓ ↑ ↑ ↓ ↑。根据歌曲情绪选择轻重和方向。"),
        ]),
        
        TheoryDetailData(topicId: "tuplets", title: "三连音与多连音", sections: [
            TheorySection(title: "三连音", content: "三连音是将一拍（或一个音符）平均分成三等分。用数字3标记。在一拍内均匀弹出三个音。", graphicType: .rhythmPattern),
            TheorySection(title: "多连音", content: "五连音、六连音、七连音等将拍子分为更多等分。在吉他独奏和Solo中常见。六连音其实就是一拍六个音。"),
            TheorySection(title: "三连音训练", content: "先感受'1-2-3, 1-2-3'的均匀三等分节奏，再到吉他上练习。从慢速开始，每次练习都用节拍器。"),
        ]),
        
        TheoryDetailData(topicId: "compound-rhythm", title: "复合节奏", sections: [
            TheorySection(title: "什么是复合节奏", content: "复合节奏是同时听到或感受到两种或更多不同的节奏划分。例如4/4拍中同时有三连音的感觉（4对3）。"),
            TheorySection(title: "Polymeter与Polyrhythm", content: "Polymeter是不同声部使用不同拍号；Polyrhythm是不同声部在同一拍号内使用不同的节奏划分，如3对2、4对3。"),
            TheorySection(title: "在吉他中的应用", content: "指弹吉他中，低音维持4/4，旋律可能用三连音，这就是最简单的复合节奏。大师级的指弹往往充满了精妙的复合节奏。"),
        ]),
    ]
}
