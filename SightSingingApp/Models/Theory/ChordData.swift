import Foundation
import SwiftUI

// MARK: - 和弦数据模型（从 buitar 乐理全库迁移）

/// 调性模式
enum KeyMode: String, CaseIterable, Codable {
    case major = "大调"
    case minor = "小调"
}

// TSDFunction 已在 HarmonyCore/ScaleEngine.swift 中定义
// 这里添加扩展属性
extension TSDFunction: CaseIterable {}
    var displayName: String {
        switch self {
        case .tonic: return "主功能 Tonic"
        case .subdominant: return "下属功能 Subdominant"
        case .dominant: return "属功能 Dominant"
        }
    }

    var color: Color {
        switch self {
        case .tonic: return Color(hex: "1E6B3A")
        case .subdominant: return Color(hex: "1A5FA8")
        case .dominant: return Color(hex: "C0391A")
        }
    }

    var bgColor: Color {
        switch self {
        case .tonic: return Color(hex: "EDF7F1")
        case .subdominant: return Color(hex: "EDF2FB")
        case .dominant: return Color(hex: "FDF0EE")
        }
    }
}

// MARK: - 和弦分类

enum ChordSectionType: String, CaseIterable, Identifiable {
    case triad = "顺阶三和弦"
    case seventh = "七和弦 7th"
    case sus = "挂留 Sus"
    case add = "Add / 加音"
    case ninth = "九和弦 9th"
    case sixth = "六和弦 6th"
    case eleventh = "十一和弦 11th"
    case thirteenth = "十三和弦 13th"
    case slash = "分数/转位和弦"
    case borrowed = "借用和弦"
    case harmonicMinor = "和声小调特有"
    case secondaryDominant = "副属和弦"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .triad: return Color(hex: "B5680A")
        case .seventh: return Color(hex: "2A5FA8")
        case .sus: return Color(hex: "27774A")
        case .add: return Color(hex: "7B50B0")
        case .ninth: return Color(hex: "C05A20")
        case .sixth: return Color(hex: "1A8080")
        case .eleventh: return Color(hex: "8B2FC9")
        case .thirteenth: return Color(hex: "B02060")
        case .slash: return Color(hex: "C0391A")
        case .borrowed: return Color(hex: "5A7A20")
        case .harmonicMinor: return Color(hex: "1A6080")
        case .secondaryDominant: return Color(hex: "8A4010")
        }
    }
}

// MARK: - 和弦条目

struct ChordEntry: Identifiable, Hashable {
    let id = UUID()
    let root: String
    let tag: String
    let label: String
    let notes: [String]
    let degree: String
    let degreeIndex: Int?
    let info: String
    let earCharacter: String
    let tsd: TSDFunction?

    var voicings: [[TapPoint]] = []
}

// MARK: - 指板品位点

struct TapPoint: Codable, Hashable {
    let string: Int     // 1=6弦(最粗), 6=1弦(最细)
    let grade: Int      // 0=空弦, >0=品位
    let note: String    // 音名

    init(string: Int, grade: Int, note: String) {
        self.string = string
        self.grade = grade
        self.note = note
    }
}

// MARK: - 节奏型

struct RhythmPatternData: Identifiable, Hashable {
    let id: String
    let name: String
    let bpm: Int
    let timeSignature: String
    let beats: [BeatSymbol]
    let description: String
    let tip: String

    struct BeatSymbol: Identifiable, Hashable {
        let id = UUID()
        let position: String
        let symbol: String
        let type: BeatType
    }

    enum BeatType: String, Hashable {
        case down = "下扫"
        case up = "上扫"
        case mute = "哑音"
        case rest = "休止"
        case thumb = "拇指"
        case finger = "手指"
    }
}

// MARK: - 调式信息

struct ModeInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let chineseName: String
    let character: String
    let feel: String
    let intervals: [Int]
    let intervalPattern: String
    let color: Color

    static let allModes: [ModeInfo] = [
        ModeInfo(id: "major", name: "Ionian", chineseName: "自然大调",
                 character: "明亮积极", feel: "明亮、欢快、积极",
                 intervals: [0,2,4,5,7,9,11], intervalPattern: "全全半全全全半",
                 color: Color(hex: "B5680A")),
        ModeInfo(id: "dorian", name: "Dorian", chineseName: "多利亚",
                 character: "爵士、蓝调", feel: "介于大小调之间，爵士、funk常用",
                 intervals: [0,2,3,5,7,9,10], intervalPattern: "全半全全全半全",
                 color: Color(hex: "2A5FA8")),
        ModeInfo(id: "phrygian", name: "Phrygian", chineseName: "弗里几亚",
                 character: "西班牙、弗拉明戈", feel: "异域、紧张、弗拉明戈风格",
                 intervals: [0,1,3,5,7,8,10], intervalPattern: "半全全全半全全",
                 color: Color(hex: "C0391A")),
        ModeInfo(id: "lydian", name: "Lydian", chineseName: "利底亚",
                 character: "梦幻飘逸", feel: "梦幻、飘逸、神秘，#4度是特色音",
                 intervals: [0,2,4,6,7,9,11], intervalPattern: "全全全半全全半",
                 color: Color(hex: "7B50B0")),
        ModeInfo(id: "mixolydian", name: "Mixolydian", chineseName: "混合利底亚",
                 character: "摇滚、蓝调", feel: "摇滚、蓝调，大调色彩+小七度",
                 intervals: [0,2,4,5,7,9,10], intervalPattern: "全全半全全半全",
                 color: Color(hex: "27774A")),
        ModeInfo(id: "minor", name: "Aeolian", chineseName: "自然小调",
                 character: "忧郁内敛", feel: "忧郁、深沉、内省",
                 intervals: [0,2,3,5,7,8,10], intervalPattern: "全半全全半全全",
                 color: Color(hex: "5A7A20")),
        ModeInfo(id: "locrian", name: "Locrian", chineseName: "洛克里亚",
                 character: "极度紧张", feel: "最黑暗调式，减三和弦为主，金属乐常用",
                 intervals: [0,1,3,5,6,8,10], intervalPattern: "半全全半全全全",
                 color: Color(hex: "8A4010")),
    ]
}

// MARK: - 和弦进行

struct ProgressionInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let chords: [String]
    let degrees: [String]
    let description: String
    let style: String

    static let classics: [ProgressionInfo] = [
        ProgressionInfo(name: "I-IV-V-I", chords: ["C","F","G","C"], degrees: ["Ⅰ","Ⅳ","Ⅴ","Ⅰ"],
                        description: "最基础的正格终止，几乎所有流行歌曲的基础", style: "经典"),
        ProgressionInfo(name: "I-V-vi-IV", chords: ["C","G","Am","F"], degrees: ["Ⅰ","Ⅴ","Ⅵm","Ⅳ"],
                        description: "卡西欧进行，21世纪最流行的和弦走向", style: "流行"),
        ProgressionInfo(name: "I-vi-IV-V", chords: ["C","Am","F","G"], degrees: ["Ⅰ","Ⅵm","Ⅳ","Ⅴ"],
                        description: "50年代进行，《Stand By Me》经典走向", style: "经典"),
        ProgressionInfo(name: "ii-V-I", chords: ["Dm","G","C","C"], degrees: ["Ⅱm","Ⅴ","Ⅰ","Ⅰ"],
                        description: "爵士二五一，最核心的爵士和弦进行", style: "爵士"),
        ProgressionInfo(name: "vi-IV-I-V", chords: ["Am","F","C","G"], degrees: ["Ⅵm","Ⅳ","Ⅰ","Ⅴ"],
                        description: "小调开头进行，情绪饱满", style: "流行"),
        ProgressionInfo(name: "I-iii-IV-V", chords: ["C","Em","F","G"], degrees: ["Ⅰ","Ⅲm","Ⅳ","Ⅴ"],
                        description: "舒缓上行，常用在桥段", style: "抒情"),
    ]
}

// MARK: - TSD 运动

struct TSDMotion: Identifiable, Hashable {
    let id = UUID()
    let from: TSDFunction
    let to: TSDFunction
    let name: String
    let description: String

    static let allMotions: [TSDMotion] = [
        TSDMotion(from: .tonic, to: .subdominant, name: "离调运动", description: "稳定→离开"),
        TSDMotion(from: .tonic, to: .dominant, name: "半解决期待", description: "制造走向属的张力"),
        TSDMotion(from: .tonic, to: .tonic, name: "同功能平移", description: "同功能组内切换"),
        TSDMotion(from: .subdominant, to: .dominant, name: "趋向进行", description: "最常见的和声运动"),
        TSDMotion(from: .subdominant, to: .tonic, name: "变格终止", description: "阿门终止"),
        TSDMotion(from: .subdominant, to: .subdominant, name: "同功能延伸", description: "下属功能组内"),
        TSDMotion(from: .dominant, to: .tonic, name: "正格终止", description: "最强解决"),
        TSDMotion(from: .dominant, to: .subdominant, name: "欺骗终止", description: "意外解决"),
        TSDMotion(from: .dominant, to: .dominant, name: "属功能延伸", description: "属功能组内"),
    ]
}

// MARK: - 和弦听觉色彩

struct EarCharacterData {
    static let characters: [String: String] = [
        "": "明亮、开朗、稳定",
        "m": "忧郁、内敛、温柔",
        "aug": "紧张、神秘、期待",
        "dim": "极度紧张、不稳定",
        "maj7": "温柔、梦幻、浪漫",
        "7": "蓝调感、紧张、解决欲强",
        "m7": "柔和、爵士、内敛",
        "m7b5": "黑暗、爵士、不安定",
        "dim7": "高度紧张、对称感",
        "sus2": "空旷、悬浮、自然",
        "sus4": "悬挂感、期待、未解决",
        "add9": "清新、明亮、通透",
        "maj9": "丰富、温柔、爵士",
        "9": "律动感、R&B、色彩丰富",
        "m9": "柔美、爵士、内省",
        "6": "明亮、复古、爵士",
        "m6": "忧郁中带甜、巴萨诺瓦",
    ]
}

// MARK: - 和弦说明

struct ChordInfoData {
    static let info: [String: String] = [
        "": "大三和弦（1-3-5）：明亮积极，民谣基础。3度跨越带来明亮感。",
        "m": "小三和弦（1-♭3-5）：忧郁感强，♭3度是小调色彩来源。",
        "aug": "增三和弦（1-3-#5）：大三度+增五度，常作经过和弦。",
        "dim": "减三和弦（1-♭3-♭5）：高度紧张，两个小三度叠加。",
        "maj7": "大七和弦（1-3-5-7）：大三+大七音，温柔梦幻。7度与根音形成大七度，产生浪漫感。",
        "7": "属七和弦（1-3-5-♭7）：大三+小七音。3度(导音)+♭7度形成减五度张力，强烈趋向解决到I。",
        "m7": "小七和弦（1-♭3-5-♭7）：小三+小七，柔和忧郁，爵士流行常用。",
        "m7b5": "半减七 Ø（1-♭3-♭5-♭7）：减三+小七，爵士导和弦。",
        "dim7": "减七和弦（1-♭3-♭5-♭♭7）：完全对称，每3个半音可互换。",
        "sus2": "挂二和弦（1-2-5）：大二度替代三度，空旷飘逸。",
        "sus4": "挂四和弦（1-4-5）：纯四度替代三度，悬挂感，需解决。",
        "add9": "加九和弦（1-2-3-5）：三和弦+九音，不含七音，清新明亮。",
        "maj9": "大九和弦（1-3-5-7-9）：大七+九音，丰富温柔。",
        "9": "属九和弦（1-3-5-♭7-9）：属七+九音，R&B/流行色彩浓郁。",
        "m9": "小九和弦（1-♭3-5-♭7-9）：小七+九音，爵士感强。",
        "6": "大六和弦（1-3-5-6）：大三+大六度，明亮复古。",
        "m6": "小六和弦（1-♭3-5-6）：小三+大六度，爵士/巴萨诺瓦。",
        "11": "属十一和弦（1-3-5-♭7-9-11）：属九+十一度。",
        "m11": "小十一和弦（1-♭3-5-♭7-9-11）：小九+十一度。",
        "maj13": "大十三和弦：大七扩展，爵士最丰富和弦之一。",
        "13": "属十三和弦：属七扩展+六度音，爵士必备。",
    ]
}

// MARK: - 音乐理论工具

struct MusicTheoryHelper {
    static let chromatic: [String] = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
    static let flatNames: [String] = ["C","Db","D","Eb","E","F","Gb","G","Ab","A","Bb","B"]

    static let majorKeys: [String] = ["C","G","D","A","E","B","F","Bb","Eb","Ab","Db","Gb"]
    static let minorKeys: [String] = ["Am","Em","Bm","F#m","C#m","G#m","Dm","Gm","Cm","Fm","Bbm","Ebm"]

    static let majorDegrees: [String] = ["Ⅰ","Ⅱm","Ⅲm","Ⅳ","Ⅴ","Ⅵm","Ⅶdim"]
    static let minorDegrees: [String] = ["Ⅰm","Ⅱdim","♭Ⅲ","Ⅳm","Ⅴm","♭Ⅵ","♭Ⅶ"]

    static let tsdMajor: [Int: TSDFunction] = [0:.tonic, 1:.subdominant, 2:.tonic, 3:.subdominant, 4:.dominant, 5:.tonic, 6:.dominant]
    static let tsdMinor: [Int: TSDFunction] = [0:.tonic, 1:.dominant, 2:.tonic, 3:.subdominant, 4:.dominant, 5:.subdominant, 6:.subdominant]

    static func noteIndex(_ note: String) -> Int {
        if let idx = chromatic.firstIndex(of: note) { return idx }
        let map: [String: Int] = ["Db":1,"Eb":3,"Gb":6,"Ab":8,"Bb":10,"Cb":11,"Fb":4,"E#":5,"B#":0]
        return map[note] ?? 0
    }

    static func getNoteAtSemi(root: String, semi: Int, preferFlat: Bool = false) -> String {
        let ri = noteIndex(root)
        let idx = (ri + semi + 12) % 12
        return preferFlat ? flatNames[idx] : chromatic[idx]
    }

    static func normNote(_ n: String) -> String {
        let map = ["A#":"Bb","D#":"Eb","G#":"Ab","C#":"Db"]
        return map[n] ?? n
    }

    static func keyNotes(for key: String) -> [String] {
        let map: [String: [String]] = [
            "C":["C","D","E","F","G","A","B"],
            "G":["G","A","B","C","D","E","F#"],
            "D":["D","E","F#","G","A","B","C#"],
            "A":["A","B","C#","D","E","F#","G#"],
            "E":["E","F#","G#","A","B","C#","D#"],
            "B":["B","C#","D#","E","F#","G#","A#"],
            "F":["F","G","A","Bb","C","D","E"],
            "Bb":["Bb","C","D","Eb","F","G","A"],
            "Eb":["Eb","F","G","Ab","Bb","C","D"],
            "Ab":["Ab","Bb","C","Db","Eb","F","G"],
            "Db":["Db","Eb","F","Gb","Ab","Bb","C"],
            "Gb":["Gb","Ab","Bb","Cb","Db","Eb","F"],
        ]
        return map[key] ?? ["C","D","E","F","G","A","B"]
    }
}

// MARK: - 和弦构建器

struct ChordBuilder {
    /// 构建指定调的所有顺阶三和弦
    static func buildDiatonicTriads(key: String, mode: KeyMode) -> [ChordEntry] {
        let notes = MusicTheoryHelper.keyNotes(for: key)
        let degrees = mode == .major ? MusicTheoryHelper.majorDegrees : MusicTheoryHelper.minorDegrees
        let majorQualities: [String] = ["","m","m","","","m","dim"]
        let minorQualities: [String] = ["m","dim","","m","m","",""]

        let qualities = mode == .major ? majorQualities : minorQualities

        return zip(notes, qualities).enumerated().map { i, pair in
            let (root, tag) = pair
            let tsd = mode == .major ? MusicTheoryHelper.tsdMajor[i] : MusicTheoryHelper.tsdMinor[i]
            let chordNotes = buildChordNotes(root: root, tag: tag)

            return ChordEntry(
                root: root, tag: tag, label: root + tag,
                notes: chordNotes, degree: degrees[i], degreeIndex: i,
                info: ChordInfoData.info[tag] ?? "",
                earCharacter: EarCharacterData.characters[tag] ?? "",
                tsd: tsd
            )
        }
    }

    /// 计算和弦组成音
    static func buildChordNotes(root: String, tag: String) -> [String] {
        let intervals: [Int] = {
            switch tag {
            case "": return [0,4,7]
            case "m": return [0,3,7]
            case "aug": return [0,4,8]
            case "dim": return [0,3,6]
            case "maj7": return [0,4,7,11]
            case "7": return [0,4,7,10]
            case "m7": return [0,3,7,10]
            case "m7b5": return [0,3,6,10]
            case "dim7": return [0,3,6,9]
            case "sus2": return [0,2,7]
            case "sus4": return [0,5,7]
            case "add9": return [0,2,4,7]
            case "maj9": return [0,4,7,11,2]
            case "9": return [0,4,7,10,2]
            case "m9": return [0,3,7,10,2]
            case "6": return [0,4,7,9]
            case "m6": return [0,3,7,9]
            case "11": return [0,4,7,10,2,5]
            case "m11": return [0,3,7,10,2,5]
            default: return [0,4,7]
            }
        }()

        let preferFlat = ["F","Bb","Eb","Ab","Db","Gb"].contains(root)
        return intervals.map { MusicTheoryHelper.getNoteAtSemi(root: root, semi: $0, preferFlat: preferFlat) }
    }
}

// MARK: - 节奏型数据

struct RhythmPatternLibrary {
    static let patterns: [RhythmPatternData] = [
        RhythmPatternData(id: "basic44", name: "基础4/4下扫", bpm: 80, timeSignature: "4/4",
            beats: [
                RhythmPatternData.BeatSymbol(position: "1", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "2", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "3", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "4", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "—", type: .rest),
            ],
            description: "最基础的扫弦节奏，所有下扫。适合练习稳定节拍感",
            tip: "保持手腕放松，像钟摆一样匀速摆动，每拍都要下扫"),
        RhythmPatternData(id: "folk1", name: "民谣 ↓↓↑↑↓↑", bpm: 80, timeSignature: "4/4",
            beats: [
                RhythmPatternData.BeatSymbol(position: "1", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "2", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
                RhythmPatternData.BeatSymbol(position: "3", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
                RhythmPatternData.BeatSymbol(position: "4", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
            ],
            description: "最常见的民谣节奏型，适合大部分4/4拍歌曲",
            tip: "手腕始终保持上下摆动，↑扫时只扫1-3弦（细弦侧）"),
        RhythmPatternData(id: "cut", name: "切分节奏 ↓↑×↑↓↑", bpm: 85, timeSignature: "4/4",
            beats: [
                RhythmPatternData.BeatSymbol(position: "1", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
                RhythmPatternData.BeatSymbol(position: "2", symbol: "×", type: .mute),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
                RhythmPatternData.BeatSymbol(position: "3", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
                RhythmPatternData.BeatSymbol(position: "4", symbol: "×", type: .mute),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
            ],
            description: "带哑音的切分节奏，摇滚/流行必备，律动感强",
            tip: "× 是用右手轻触弦面同时扫弦发出哑音，要练到干净不刺耳"),
        RhythmPatternData(id: "reggae", name: "雷鬼节奏 反拍强调", bpm: 76, timeSignature: "4/4",
            beats: [
                RhythmPatternData.BeatSymbol(position: "1", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
                RhythmPatternData.BeatSymbol(position: "2", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
                RhythmPatternData.BeatSymbol(position: "3", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
                RhythmPatternData.BeatSymbol(position: "4", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
            ],
            description: "只在反拍扫弦，是雷鬼音乐的核心节奏感",
            tip: "拍点（1234）不发声，只在&位上扫，配合脚踩拍更容易感受"),
        RhythmPatternData(id: "waltz", name: "华尔兹 3/4拍", bpm: 90, timeSignature: "3/4",
            beats: [
                RhythmPatternData.BeatSymbol(position: "1", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "2", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
                RhythmPatternData.BeatSymbol(position: "3", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
            ],
            description: "3/4拍圆舞曲节奏，第一拍重音，二三拍轻",
            tip: "数\"1-2-3 1-2-3\"，第1拍扫全弦（重），2-3拍轻扫"),
        RhythmPatternData(id: "travis", name: "Travis指弹分解", bpm: 72, timeSignature: "4/4",
            beats: [
                RhythmPatternData.BeatSymbol(position: "1", symbol: "T", type: .thumb),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "2", symbol: "●", type: .finger),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "●", type: .finger),
                RhythmPatternData.BeatSymbol(position: "3", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "●", type: .finger),
                RhythmPatternData.BeatSymbol(position: "4", symbol: "T", type: .thumb),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "—", type: .rest),
            ],
            description: "Travis Picking：拇指交替弹Bass弦，手指弹旋律弦",
            tip: "拇指(T)交替拨4弦→5弦→4弦→5弦，手指同步弹高音弦"),
        RhythmPatternData(id: "arpeg", name: "443式分解", bpm: 70, timeSignature: "4/4",
            beats: [
                RhythmPatternData.BeatSymbol(position: "1", symbol: "T", type: .thumb),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "●", type: .finger),
                RhythmPatternData.BeatSymbol(position: "2", symbol: "●", type: .finger),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "3", symbol: "T", type: .thumb),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "●", type: .finger),
                RhythmPatternData.BeatSymbol(position: "4", symbol: "●", type: .finger),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "—", type: .rest),
            ],
            description: "拇指弹低音弦，食中指依次弹2弦1弦，适合指弹民谣",
            tip: "拇指固定在5弦或6弦，手指每次弹1-2弦，节奏要匀速"),
        RhythmPatternData(id: "bossa", name: "Bossa Nova切分", bpm: 88, timeSignature: "4/4",
            beats: [
                RhythmPatternData.BeatSymbol(position: "1", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "2", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
                RhythmPatternData.BeatSymbol(position: "3", symbol: "—", type: .rest),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "↑", type: .up),
                RhythmPatternData.BeatSymbol(position: "4", symbol: "↓", type: .down),
                RhythmPatternData.BeatSymbol(position: "&", symbol: "—", type: .rest),
            ],
            description: "巴萨诺瓦的招牌节奏，爵士+桑巴融合的感觉",
            tip: "注意3&位置有上扫但4&位置没有，形成切分律动感"),
    ]
}
