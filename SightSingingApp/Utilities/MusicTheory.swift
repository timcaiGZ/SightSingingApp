import Foundation

/// 音乐理论工具类 — 完全面向民谣吉他学习者
/// 使用简谱音高和吉他六根弦标准音高

struct MusicTheory {
    // MARK: - 吉他标准音高（EADGBE）
    /// 吉他六根弦标准音高（Hz）
    static let standardTuning: [(string: Int, note: String, frequency: Double)] = [
        (1, "E4", 329.63),  // 1弦（最细）
        (2, "B3", 246.94),  // 2弦
        (3, "G3", 196.00),  // 3弦
        (4, "D3", 146.83),  // 4弦
        (5, "A2", 110.00),  // 5弦
        (6, "E2", 82.41),   // 6弦（最粗）
    ]

    /// 简谱音高映射（以 C 为基准，数字 1-7 对应）
    static let solfegeNotes: [(solfege: String, midiNote: Int, name: String)] = [
        ("1", 60, "C"),  // do
        ("2", 62, "D"),  // re
        ("3", 64, "E"),  // mi
        ("4", 65, "F"),  // fa
        ("5", 67, "G"),  // sol
        ("6", 69, "A"),  // la
        ("7", 71, "B"),  // si
    ]

    /// 升降号简谱表示（支持 # 和 ♭）
    /// - Parameters:
    ///   - solfege: 简谱数字（如 "1", "4"）
    ///   - sharp: 是否升号（true），false 表示降号
    /// - Returns: 带升降号的简谱表示（如 "1#", "5b"）
    static func solfegeWithAccidental(_ solfege: String, sharp: Bool) -> String {
        if sharp {
            return "\(solfege)#".replacingOccurrences(of: "##", with: "♯")
        } else {
            return "\(solfege)♭"
        }
    }
    
    /// 升降号简谱表示（显式指定升降号类型）
    /// - Parameters:
    ///   - solfege: 简谱数字
    ///   - accidental: 升降号类型：.sharp（#）、.flat（♭）、.natural（无）
    /// - Returns: 带升降号的简谱表示
    static func solfegeWithAccidental(_ solfege: String, accidental: Accidental) -> String {
        switch accidental {
        case .sharp:
            return "\(solfege)#".replacingOccurrences(of: "##", with: "♯")
        case .flat:
            return "\(solfege)♭"
        case .natural:
            return solfege
        }
    }
    
    /// 升降号枚举
    enum Accidental {
        case sharp   // 升号 ♯
        case flat    // 降号 ♭
        case natural // 本位音（无升降）
    }

    // MARK: - 音程
    static let intervals: [(name: String, semitones: Int, abbreviation: String)] = [
        ("纯一度", 0, "P1"),
        ("小二度", 1, "m2"),
        ("大二度", 2, "M2"),
        ("小三度", 3, "m3"),
        ("大三度", 4, "M3"),
        ("纯四度", 5, "P4"),
        ("增四度/减五度", 6, "TT"),
        ("纯五度", 7, "P5"),
        ("小六度", 8, "m6"),
        ("大六度", 9, "M6"),
        ("小七度", 10, "m7"),
        ("大七度", 11, "M7"),
        ("纯八度", 12, "P8"),
    ]

    // MARK: - 常用吉他和弦（六线谱数据）

    /// 开放和弦（初学者必学）
    static let openChords: [(name: String, tab: TabData)] = [
        ("C", TabData(frets: [nil, 3, 2, 0, 1, nil], markers: [1, 2, 3, 4], chordName: "C")),
        ("G", TabData(frets: [3, 2, 0, nil, nil, 3], markers: [1, 2, 6], chordName: "G")),
        ("Am", TabData(frets: [nil, nil, 2, 2, 1, nil], markers: [3, 4, 5], chordName: "Am")),
        ("Em", TabData(frets: [nil, 2, 2, 0, nil, nil], markers: [2, 3], chordName: "Em")),
        ("D", TabData(frets: [nil, nil, nil, 2, 3, 2], markers: [4, 5, 6], chordName: "D")),
        ("E", TabData(frets: [0, 2, 2, 1, nil, nil], markers: [2, 3, 4], chordName: "E")),
        ("A", TabData(frets: [nil, nil, 2, 2, 2, nil], markers: [3, 4, 5], chordName: "A")),
    ]

    /// 大横按和弦（进阶必学）
    static let barreChords: [(name: String, tab: TabData)] = [
        ("F", TabData(frets: [1, 3, 3, 2, 1, 1], markers: [1, 2, 3, 4, 5, 6], chordName: "F")),
        ("Bm", TabData(frets: [nil, 3, 5, 5, 4, nil], markers: [2, 3, 4, 5], chordName: "Bm")),
        ("B", TabData(frets: [nil, 3, 5, 4, 2, nil], markers: [2, 3, 4, 5], chordName: "B")),
    ]

    // MARK: - CAGED 系统

    /// CAGED 系统把位
    static let cagedShapes: [(name: String, root: String, tab: TabData)] = [
        ("C 型", "C", TabData(frets: [nil, 3, 5, 5, 5, 3], markers: [2, 3, 4, 5, 6], chordName: "C")),
        ("A 型", "A", TabData(frets: [nil, nil, 2, 2, 2, nil], markers: [3, 4, 5], chordName: "A")),
        ("G 型", "G", TabData(frets: [3, 2, 0, nil, nil, 3], markers: [1, 2, 6], chordName: "G")),
        ("E 型", "E", TabData(frets: [0, 2, 2, 1, nil, nil], markers: [2, 3, 4], chordName: "E")),
        ("D 型", "D", TabData(frets: [nil, nil, nil, 2, 3, 2], markers: [4, 5, 6], chordName: "D")),
    ]

    // MARK: - 扫弦节奏型（简谱节奏标记）

    /// 常见扫弦节奏型
    static let strummingPatterns: [(name: String, notation: String, beats: Int)] = [
        ("下上下上", "↓↑↓↑", 4),
        ("下下下上", "↓↓↓↑", 4),
        ("下上下下上", "↓↑↓↑↓↑", 6),
        ("下下上下", "↓↓↑↓", 4),
        ("分解T323", "T 3 2 3", 4),
        ("分解T135", "T 1 3 5", 4),
    ]

    // MARK: - 音高计算

    /// 从 MIDI note 转换为频率
    static func frequencyFromMIDI(_ midiNote: Int) -> Double {
        440.0 * pow(2.0, Double(midiNote - 69) / 12.0)
    }

    /// 从简谱（solfege）转换为 MIDI note
    static func midiNote(from solfege: String, octave: Int = 4) -> Int? {
        guard let note = solfegeNotes.first(where: { $0.solfege == solfege }) else {
            return nil
        }
        return note.midiNote + (octave - 4) * 12
    }

    /// 计算两个 MIDI note 之间的音分（cents）
    static func centsBetween(_ note1: Int, _ note2: Int) -> Double {
        let freq1 = frequencyFromMIDI(note1)
        let freq2 = frequencyFromMIDI(note2)
        return 1200.0 * log2(freq2 / freq1)
    }

    /// 从频率计算音分偏差
    static func centsDeviation(detected: Double, target: Double) -> Double {
        1200.0 * log2(detected / target)
    }

    /// 音准评分（基于音分偏差）
    static func pitchScore(cents: Double) -> Int {
        let absCents = abs(cents)
        if absCents <= 10 {
            return 100
        } else if absCents <= 30 {
            return Int(100 - (absCents - 10) * 1.5) // 线性递减到70
        } else if absCents <= 50 {
            return Int(70 - (absCents - 30) * 0.5)  // 线性递减到60
        } else {
            return max(0, Int(60 - (absCents - 50) * 1.2)) // 线性递减到0
        }
    }
}
