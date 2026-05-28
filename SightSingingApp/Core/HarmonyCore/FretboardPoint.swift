import Foundation

// MARK: - 音名体系

/// 十二平均律音名（统一用升号表示）
enum NoteName: String, CaseIterable, Sendable {
    case C = "C"
    case CSharp = "C#"
    case D = "D"
    case DSharp = "D#"
    case E = "E"
    case F = "F"
    case FSharp = "F#"
    case G = "G"
    case GSharp = "G#"
    case A = "A"
    case ASharp = "A#"
    case B = "B"

    /// 相对音高（C=0, B=11）
    var pitch: Int {
        switch self {
        case .C: return 0
        case .CSharp: return 1
        case .D: return 2
        case .DSharp: return 3
        case .E: return 4
        case .F: return 5
        case .FSharp: return 6
        case .G: return 7
        case .GSharp: return 8
        case .A: return 9
        case .ASharp: return 10
        case .B: return 11
        }
    }

    /// 从相对音高创建
    init(pitch: Int) {
        let normalized = ((pitch % 12) + 12) % 12
        self = NoteName.allCases[normalized]
    }

    /// 降号别名
    static func flatAlias(for sharp: NoteName) -> NoteName? {
        switch sharp {
        case .CSharp: return .D
        case .DSharp: return .E
        case .FSharp: return .G
        case .GSharp: return .A
        case .ASharp: return .B
        default: return nil
        }
    }
}

// MARK: - 音程枚举

/// 调内音程（以数字1-7为基础，支持升降）
enum ScaleInterval: String, Sendable {
    case unison = "1"
    case flat2 = "♭2"
    case second = "2"
    case sharp2 = "#2"
    case flat3 = "♭3"
    case third = "3"
    case fourth = "4"
    case sharp4 = "#4"
    case flat5 = "♭5"
    case fifth = "5"
    case sharp5 = "#5"
    case flat6 = "♭6"
    case sixth = "6"
    case sharp6 = "#6"
    case flat7 = "♭7"
    case seventh = "7"

    /// 半音偏移（相对主音）
    var semitoneOffset: Int {
        switch self {
        case .unison: return 0
        case .flat2: return 1
        case .second: return 2
        case .sharp2: return 3
        case .flat3: return 3
        case .third: return 4
        case .fourth: return 5
        case .sharp4: return 6
        case .flat5: return 6
        case .fifth: return 7
        case .sharp5: return 8
        case .flat6: return 8
        case .sixth: return 9
        case .sharp6: return 10
        case .flat7: return 10
        case .seventh: return 11
        }
    }
}

// MARK: - 指板点模型（借鉴 buitar Point）

/// 吉他指板上任意位置的完整音高信息
/// 参考 buitar 的 Point 模型，统一编码音名/音高/音程/位置
struct FretboardPoint: Identifiable, Equatable, Sendable {
    let id: Int                    // 唯一索引 = string * 100 + fret
    let note: NoteName             // 音名（C/C#/D/.../B）
    let pitch: Int                 // 相对音高 0-11（C=0）
    let midiNote: Int              // 绝对 MIDI 音高
    let octave: Int                // 八度级别（如 C4 的 4）
    let string: Int                // 吉他弦号（0=低音E .. 5=高音E）
    let fret: Int                  // 品位（0=空弦）

    // 调内属性（在指定调式上下文中设置）
    var interval: ScaleInterval?   // 调内音程（如 "3" "♭7"）
    var isInScale: Bool            // 是否在当前调式内

    init(string: Int, fret: Int, tuningMidi: Int) {
        self.string = string
        self.fret = fret
        self.id = string * 100 + fret

        let totalMidi = tuningMidi + fret
        self.midiNote = totalMidi
        self.pitch = totalMidi % 12
        self.octave = (totalMidi / 12) - 1  // MIDI 0 = C-1
        self.note = NoteName(pitch: self.pitch)
        self.interval = nil
        self.isInScale = false
    }
}

// MARK: - 和弦音（和弦构成音）

/// 和弦中的单个构成音
struct ChordTone: Equatable, Sendable {
    let note: NoteName
    let interval: ScaleInterval    // 相对根音的音程
    let pitch: Int                 // 0-11 半音位置

    /// 从音名+音程构造
    init(note: NoteName, interval: ScaleInterval) {
        self.note = note
        self.interval = interval
        self.pitch = note.pitch
    }
}

// MARK: - 常用音程常量

extension ScaleInterval {
    /// 和弦常见音程列表
    static let chordIntervals: [ScaleInterval] = [
        .unison, .flat2, .second, .flat3, .third, .fourth,
        .sharp4, .flat5, .fifth, .sharp5, .flat6, .sixth, .flat7, .seventh
    ]

    /// 音程所含半音数
    var semitones: Int { semitoneOffset }

    /// 音程的中文名
    var chineseName: String {
        switch self {
        case .unison: return "根音"
        case .flat2: return "降二音"
        case .second: return "二音"
        case .sharp2: return "升二音"
        case .flat3: return "小三度"
        case .third: return "大三度"
        case .fourth: return "纯四度"
        case .sharp4: return "增四度"
        case .flat5: return "减五度"
        case .fifth: return "纯五度"
        case .sharp5: return "增五度"
        case .flat6: return "小六度"
        case .sixth: return "大六度"
        case .sharp6: return "增六度"
        case .flat7: return "小七度"
        case .seventh: return "大七度"
        }
    }
}
