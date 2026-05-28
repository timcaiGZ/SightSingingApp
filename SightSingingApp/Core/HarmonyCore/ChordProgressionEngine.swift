import Foundation

// MARK: - 和弦进行引擎（借鉴 buitar Sequencer + Progression 配置）

/// 和弦进行引擎 — 管理和弦进行序列、播放、转调
enum ChordProgressionEngine {

    // MARK: - 内置和弦进行

    /// 所有内置和弦进行
    static let builtInProgressions: [ChordProgression] = [
        .oneSixFourFive,
        .oneFiveSixFour,
        .oneFourFive,
        .popCanon,
        .fiftyProgress,
        .blues,
        .jazzTwoFiveOne,
        .fourFiveThreeSixTwoFiveOne,
        .andalucianCadence,
        .dooWop,
        .minorOneSixThreeSeven,
    ]

    // MARK: - 转调

    /// 将和弦进行转调到指定调
    static func transpose(_ progression: ChordProgression, to key: NoteName, mode: ScaleMode = .major) -> [ProgressionChord] {
        // 获取该调式的顺阶和弦
        let diatonic = ScaleEngine.diatonicTriads(root: key, mode: mode)

        return progression.chords.compactMap { pc in
            guard let diatonicChord = diatonic.first(where: { $0.degree == pc.degree }) else {
                // 尝试七和弦
                let seventhChords = ScaleEngine.diatonicSeventhChords(root: key, mode: mode)
                guard let match = seventhChords.first(where: { $0.degree == pc.degree }) else { return nil }
                return ProgressionChord(
                    degree: pc.degree,
                    chordName: "\(match.rootNote.rawValue)\(progression.qualityTag(for: match.quality))",
                    beats: pc.beats,
                    function: pc.tsd,
                    voices: match.tones
                )
            }
            return ProgressionChord(
                degree: pc.degree,
                chordName: "\(diatonicChord.rootNote.rawValue)\(progression.qualityTag(for: diatonicChord.quality))",
                beats: pc.beats,
                function: pc.tsd,
                voices: diatonicChord.tones
            )
        }
    }

    /// 获取指定和弦进行在所有12个调中的版本
    static func allKeys(_ progression: ChordProgression) -> [(key: NoteName, chords: [ProgressionChord])] {
        NoteName.allCases.map { key in
            (key, transpose(progression, to: key))
        }
    }
}

// MARK: - 和弦进行数据结构

/// 一个完整的和弦进行模板
struct ChordProgression: Equatable, Sendable {
    let name: String
    let description: String
    let style: ProgressionStyle    // 风格标签
    let chords: [ProgressionTemplateChord]  // 模板和弦（用级数定义）

    /// 和弦总数
    var chordCount: Int { chords.count }

    /// 总拍数
    var totalBeats: Int { chords.reduce(0) { $0 + $1.beats } }

    /// 和弦质量 → 标签转换
    func qualityTag(for quality: ChordQuality) -> String {
        switch quality {
        case .major: return ""
        case .minor: return "m"
        case .diminished: return "dim"
        case .augmented: return "aug"
        case .major7: return "maj7"
        case .dominant7: return "7"
        case .minor7: return "m7"
        case .halfDiminished7: return "m7♭5"
        case .diminished7: return "dim7"
        case .minorMajor7: return "mMaj7"
        }
    }
}

/// 和弦进行风格
enum ProgressionStyle: String, Sendable {
    case pop       // 流行
    case blues     // 布鲁斯
    case jazz      // 爵士
    case classical // 古典
    case rock      // 摇滚
    case folk      // 民谣
}

/// 模板和弦（用级数定义，不依赖具体调）
struct ProgressionTemplateChord: Equatable, Sendable {
    let degree: Int             // 音阶级数 1-7
    let chordType: ChordQualityTemplate  // 和弦类型
    let beats: Int              // 持续拍数（默认4拍=一小节）
    var tsd: TSDFunction? = nil // TSD 功能（可选，自动推导）
}

/// 和弦质量模板（级数中使用的简化质量）
enum ChordQualityTemplate: String, Sendable {
    case major = ""
    case minor = "m"
    case diminished = "dim"
    case dominant7 = "7"
    case minor7 = "m7"
    case major7 = "maj7"
}

/// 具体调内的和弦进行小节
struct ProgressionChord: Equatable, Sendable {
    let degree: Int
    let chordName: String       // 如 "Cm7"
    let beats: Int
    let function: TSDFunction?
    let voices: [NoteName]      // 构成音
}

// MARK: - 内置和弦进行定义

extension ChordProgression {

    /// Ⅰ → Ⅳ → Ⅴ → Ⅰ（经典流行走向）
    static let oneFourFive = ChordProgression(
        name: "Ⅰ-Ⅳ-Ⅴ-Ⅰ",
        description: "最经典的和弦进行，Pop/Rock/Folk 通用",
        style: .pop,
        chords: [
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 4, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 5, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
        ]
    )

    /// 卡农进行：Ⅰ→Ⅴ→Ⅵm→Ⅲm→Ⅳ→Ⅰ→Ⅳ→Ⅴ
    static let popCanon = ChordProgression(
        name: "卡农进行",
        description: "帕赫贝尔卡农和声进行，流行歌曲最爱（如《Let It Be》）",
        style: .pop,
        chords: [
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 5, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 6, chordType: .minor, beats: 4),
            ProgressionTemplateChord(degree: 3, chordType: .minor, beats: 4),
            ProgressionTemplateChord(degree: 4, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 4, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 5, chordType: .major, beats: 4),
        ]
    )

    /// 50年代进行：Ⅰ→Ⅵm→Ⅳ→Ⅴ
    static let fiftyProgress = ChordProgression(
        name: "50年代进行",
        description: "Ⅰ-Ⅵm-Ⅳ-Ⅴ 甜蜜怀旧，Doo-wop 时代的标志（如《Stand By Me》）",
        style: .pop,
        chords: [
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 6, chordType: .minor, beats: 4),
            ProgressionTemplateChord(degree: 4, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 5, chordType: .major, beats: 4),
        ]
    )

    /// 12小节布鲁斯：Ⅰ|Ⅰ|Ⅰ|Ⅰ|Ⅳ|Ⅳ|Ⅰ|Ⅰ|Ⅴ7|Ⅳ|Ⅰ|Ⅴ7
    static let blues = ChordProgression(
        name: "12小节布鲁斯",
        description: "蓝调的根基，摇滚的源头",
        style: .blues,
        chords: [
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 4, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 4, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 5, chordType: .dominant7, beats: 4),
            ProgressionTemplateChord(degree: 4, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 5, chordType: .dominant7, beats: 4),
        ]
    )

    /// 爵士 Ⅱ-Ⅴ-Ⅰ：Ⅱm7→Ⅴ7→Ⅰmaj7
    static let jazzTwoFiveOne = ChordProgression(
        name: "爵士 Ⅱ-Ⅴ-Ⅰ",
        description: "爵士乐最核心的和声进行，贯穿无数标准曲",
        style: .jazz,
        chords: [
            ProgressionTemplateChord(degree: 2, chordType: .minor7, beats: 4),
            ProgressionTemplateChord(degree: 5, chordType: .dominant7, beats: 4),
            ProgressionTemplateChord(degree: 1, chordType: .major7, beats: 8),
        ]
    )

    /// 安达卢西亚终止式：Ⅵm→Ⅴ→Ⅳ→Ⅲ
    static let andalucianCadence = ChordProgression(
        name: "安达卢西亚终止式",
        description: "Ⅵm-Ⅴ-Ⅳ-Ⅲ 弗拉门戈/西班牙风情（如《Hit the Road Jack》）",
        style: .folk,
        chords: [
            ProgressionTemplateChord(degree: 6, chordType: .minor, beats: 4),
            ProgressionTemplateChord(degree: 5, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 4, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 3, chordType: .major, beats: 4),
        ]
    )

    /// Doo-wop：Ⅰ→Ⅵm→Ⅳ→Ⅴ（同50年代，另一个名字）
    static let dooWop = ChordProgression(
        name: "Doo-Wop",
        description: "经典 I-vi-IV-V，地球人都会唱",
        style: .pop,
        chords: [
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 6, chordType: .minor, beats: 4),
            ProgressionTemplateChord(degree: 4, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 5, chordType: .major, beats: 4),
        ]
    )

    /// Ⅰ→Ⅴ→Ⅵm→Ⅳ（四个万能和弦）
    static let oneFiveSixFour = ChordProgression(
        name: "1-5-6-4 万能和弦",
        description: "四个万能和弦走向，如 Let It Go 等无数流行歌",
        style: .pop,
        chords: [
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 5, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 6, chordType: .minor, beats: 4),
            ProgressionTemplateChord(degree: 4, chordType: .major, beats: 4),
        ]
    )

    /// Ⅳ→Ⅴ→Ⅲm→Ⅵm→Ⅱm→Ⅴ→Ⅰ（华语万能走向）
    static let fourFiveThreeSixTwoFiveOne = ChordProgression(
        name: "4-5-3-6-2-5-1 华语万能",
        description: "华语流行万能走向，层层推进、情绪饱满",
        style: .pop,
        chords: [
            ProgressionTemplateChord(degree: 4, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 5, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 3, chordType: .minor, beats: 4),
            ProgressionTemplateChord(degree: 6, chordType: .minor, beats: 4),
            ProgressionTemplateChord(degree: 2, chordType: .minor, beats: 4),
            ProgressionTemplateChord(degree: 5, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
        ]
    )

    /// Ⅰ→Ⅵm→Ⅳ→Ⅴ（同50年代/dooWop，课程中称为1-6-4-5）
    static let oneSixFourFive = ChordProgression(
        name: "1-6-4-5 一路上是我",
        description: "经典 I-vi-IV-V 走向，童年/Let It Be/月亮代表我的心",
        style: .pop,
        chords: [
            ProgressionTemplateChord(degree: 1, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 6, chordType: .minor, beats: 4),
            ProgressionTemplateChord(degree: 4, chordType: .major, beats: 4),
            ProgressionTemplateChord(degree: 5, chordType: .major, beats: 4),
        ]
    )

    /// Ⅵm→Ⅳ→Ⅰ→Ⅴ（小调走向）
    static let minorOneSixThreeSeven = ChordProgression(
        name: "小调 i-VI-III-VII",
        description: "小调经典走向 Am→F→C→G，忧伤有力量",
        style: .folk,
        chords: [
            ProgressionTemplateChord(degree: 1, chordType: .minor, beats: 4),
            ProgressionTemplateChord(degree: 6, chordType: .major, beats: 4, tsd: .subdominant),
            ProgressionTemplateChord(degree: 3, chordType: .major, beats: 4, tsd: .tonic),
            ProgressionTemplateChord(degree: 7, chordType: .major, beats: 4),
        ]
    )
}

// MARK: - 和弦进行上下文（实时播放状态）

/// 和弦进行的实时播放状态
struct ProgressionContext {
    let progression: ChordProgression
    let key: NoteName
    let mode: ScaleMode
    let bpm: Double
    let chords: [ProgressionChord]  // 已转调到指定调的和弦序列

    var totalBeats: Int { progression.totalBeats }
    var chordCount: Int { chords.count }

    /// 在指定拍数位置的和弦索引
    func chordIndex(at beat: Int) -> Int {
        var accumulated = 0
        for (i, pc) in chords.enumerated() {
            accumulated += pc.beats
            if beat < accumulated { return i }
        }
        return chords.count - 1
    }

    /// 当前播放到的和弦名称
    func currentChord(at beat: Int) -> String {
        let idx = chordIndex(at: beat)
        guard idx < chords.count else { return "" }
        return chords[idx].chordName
    }

    /// 创建播放上下文
    static func create(
        progression: ChordProgression,
        key: NoteName = .C,
        mode: ScaleMode = .major,
        bpm: Double = 80
    ) -> ProgressionContext {
        let chords = ChordProgressionEngine.transpose(progression, to: key, mode: mode)
        return ProgressionContext(
            progression: progression,
            key: key,
            mode: mode,
            bpm: bpm,
            chords: chords
        )
    }
}
