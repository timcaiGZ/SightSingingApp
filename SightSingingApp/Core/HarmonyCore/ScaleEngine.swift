import Foundation

// MARK: - 调式枚举（借鉴 buitar ModeType）

/// 调式类型
enum ScaleMode: String, CaseIterable, Sendable {
    // 大调族
    case major = "major"                // 自然大调 (Ionian)
    case lydian = "lydian"             // 利底亚
    case mixolydian = "mixolydian"     // 混合利底亚

    // 小调族
    case minor = "minor"                // 自然小调 (Aeolian)
    case dorian = "dorian"             // 多利亚
    case phrygian = "phrygian"         // 弗里几亚
    case locrian = "locrian"           // 洛克里亚

    // 五声音阶
    case majorPentatonic = "major-pentatonic"
    case minorPentatonic = "minor-pentatonic"

    // 布鲁斯音阶
    case majorBlues = "major-blues"
    case minorBlues = "minor-blues"

    /// 中文名称
    var nameCN: String {
        switch self {
        case .major: return "自然大调"
        case .lydian: return "利底亚调式"
        case .mixolydian: return "混合利底亚调式"
        case .minor: return "自然小调"
        case .dorian: return "多利亚调式"
        case .phrygian: return "弗里几亚调式"
        case .locrian: return "洛克里亚调式"
        case .majorPentatonic: return "大调五声音阶"
        case .minorPentatonic: return "小调五声音阶"
        case .majorBlues: return "大调布鲁斯"
        case .minorBlues: return "小调布鲁斯"
        }
    }

    /// 调性色彩（大调/小调/中性）
    var tonality: Tonality {
        switch self {
        case .major, .lydian, .mixolydian, .majorPentatonic, .majorBlues:
            return .major
        case .minor, .dorian, .phrygian, .locrian, .minorPentatonic, .minorBlues:
            return .minor
        }
    }
}

enum Tonality: String, Sendable {
    case major
    case minor
}

// MARK: - 半音偏移表

extension ScaleMode {
    /// 每种调式相对主音的半音偏移量
    var semitoneOffsets: [Int] {
        switch self {
        case .major:
            return [0, 2, 4, 5, 7, 9, 11]           // 全-全-半-全-全-全-半
        case .lydian:
            return [0, 2, 4, 6, 7, 9, 11]           // 全-全-全-半-全-全-半
        case .mixolydian:
            return [0, 2, 4, 5, 7, 9, 10]           // 全-全-半-全-全-半-全
        case .minor:
            return [0, 2, 3, 5, 7, 8, 10]           // 全-半-全-全-半-全-全
        case .dorian:
            return [0, 2, 3, 5, 7, 9, 10]           // 全-半-全-全-全-半-全
        case .phrygian:
            return [0, 1, 3, 5, 7, 8, 10]           // 半-全-全-全-半-全-全
        case .locrian:
            return [0, 1, 3, 5, 6, 8, 10]           // 半-全-全-半-全-全-全
        case .majorPentatonic:
            return [0, 2, 4, 7, 9]                  // 1-2-3-5-6
        case .minorPentatonic:
            return [0, 3, 5, 7, 10]                 // 1-♭3-4-5-♭7
        case .majorBlues:
            return [0, 2, 3, 4, 7, 9]               // 1-2-♭3-3-5-6
        case .minorBlues:
            return [0, 3, 5, 6, 7, 10]              // 1-♭3-4-#4-5-♭7
        }
    }
}

// MARK: - 音阶引擎

/// 调式与音阶核心引擎
/// 借鉴 buitar 的调式半音偏移表 + 顺阶和弦推导
enum ScaleEngine {

    // MARK: - 音阶生成

    /// 生成指定主音+调式的音阶（返回音名+音程列表）
    static func scale(root: NoteName, mode: ScaleMode) -> [ScaleDegree] {
        let offsets = mode.semitoneOffsets
        let intervals = degreeIntervals(for: offsets)

        return zip(offsets, intervals).map { offset, interval in
            let pitch = (root.pitch + offset) % 12
            let note = NoteName(pitch: pitch)
            return ScaleDegree(note: note, interval: interval, pitch: pitch, semitoneOffset: offset)
        }
    }

    /// 仅返回音阶中的音名列表
    static func scaleNotes(root: NoteName, mode: ScaleMode = .major) -> [NoteName] {
        scale(root: root, mode: mode).map { $0.note }
    }

    /// 仅返回音阶中的 MIDI 音高（第4八度基准）
    static func scalePitches(root: NoteName, mode: ScaleMode = .major, baseOctave: Int = 4) -> [Int] {
        let baseMIDI = root.pitch + baseOctave * 12
        return mode.semitoneOffsets.map { baseMIDI + $0 }
    }

    // MARK: - 顺阶和弦推导

    /// 给定主音+调式 → 推导七个音级的顺阶三和弦
    static func diatonicTriads(root: NoteName, mode: ScaleMode = .major) -> [DiatonicChord] {
        let scaleDegrees = scale(root: root, mode: mode)
        return (0..<7).map { i in
            let rootDegree = scaleDegrees[i]
            // 叠加三度：取 i, i+2, i+4（循环）
            let third = scaleDegrees[(i + 2) % 7]
            let fifth = scaleDegrees[(i + 4) % 7]
            let tones = [rootDegree.note, third.note, fifth.note]

            // 判断和弦质量
            let thirdInterval = (third.semitoneOffset - rootDegree.semitoneOffset + 12) % 12
            let fifthInterval = (fifth.semitoneOffset - rootDegree.semitoneOffset + 12) % 12

            let quality: ChordQuality = {
                if thirdInterval == 4 && fifthInterval == 7 { return .major }
                if thirdInterval == 3 && fifthInterval == 7 { return .minor }
                if thirdInterval == 3 && fifthInterval == 6 { return .diminished }
                if thirdInterval == 4 && fifthInterval == 8 { return .augmented }
                return .major
            }()

            let roman = romanNumeral(for: i + 1, quality: quality)

            return DiatonicChord(
                degree: i + 1,
                roman: roman,
                rootNote: rootDegree.note,
                quality: quality,
                tones: tones,
                function: tsdFunction(for: i + 1, mode: mode)
            )
        }
    }

    /// 顺阶七和弦
    static func diatonicSeventhChords(root: NoteName, mode: ScaleMode = .major) -> [DiatonicChord] {
        let scaleDegrees = scale(root: root, mode: mode)
        return (0..<7).map { i in
            let rootDegree = scaleDegrees[i]
            let third = scaleDegrees[(i + 2) % 7]
            let fifth = scaleDegrees[(i + 4) % 7]
            let seventh = scaleDegrees[(i + 6) % 7]
            let tones = [rootDegree.note, third.note, fifth.note, seventh.note]

            let thirdInt = (third.semitoneOffset - rootDegree.semitoneOffset + 12) % 12
            let fifthInt = (fifth.semitoneOffset - rootDegree.semitoneOffset + 12) % 12
            let seventhInt = (seventh.semitoneOffset - rootDegree.semitoneOffset + 12) % 12

            let quality: ChordQuality = {
                if thirdInt == 4 && fifthInt == 7 && seventhInt == 11 { return .major7 }
                if thirdInt == 4 && fifthInt == 7 && seventhInt == 10 { return .dominant7 }
                if thirdInt == 3 && fifthInt == 7 && seventhInt == 10 { return .minor7 }
                if thirdInt == 3 && fifthInt == 6 && seventhInt == 10 { return .halfDiminished7 }
                if thirdInt == 3 && fifthInt == 6 && seventhInt == 9 { return .diminished7 }
                if thirdInt == 3 && fifthInt == 7 && seventhInt == 11 { return .minorMajor7 }
                return .dominant7
            }()

            return DiatonicChord(
                degree: i + 1,
                roman: romanNumeral7(for: i + 1, quality: quality),
                rootNote: rootDegree.note,
                quality: quality,
                tones: tones,
                function: tsdFunction(for: i + 1, mode: mode)
            )
        }
    }

    // MARK: - 关系大小调

    /// 获取关系大/小调
    static func relativeMode(for mode: ScaleMode) -> (ScaleMode, semitoneOffset: Int) {
        switch mode {
        case .major: return (.minor, -3)
        case .minor: return (.major, +3)
        default: return (mode, 0)
        }
    }

    /// 将一组音高从原调式转换到关系调式
    static func relativePitches(from root: NoteName, mode: ScaleMode) -> (newRoot: NoteName, newMode: ScaleMode) {
        let (newMode, offset) = relativeMode(for: mode)
        let newRoot = NoteName(pitch: (root.pitch + offset + 12) % 12)
        return (newRoot, newMode)
    }

    // MARK: - TSD 功能组

    /// 判断和弦的功能组（T=主, S=下属, D=属）
    static func tsdFunction(for degree: Int, mode: ScaleMode) -> TSDFunction {
        switch mode.tonality {
        case .major:
            switch degree {
            case 1, 3, 6: return .tonic
            case 2, 4: return .subdominant
            case 5, 7: return .dominant
            default: return .tonic
            }
        case .minor:
            switch degree {
            case 1, 3: return .tonic
            case 4, 6: return .subdominant
            case 5, 7: return .dominant
            case 2: return .subdominant  // ii° 也可以看作属功能
            default: return .tonic
            }
        }
    }

    // MARK: - 辅助方法

    /// 根据半音偏移数组推导对应的音程序列
    private static func degreeIntervals(for offsets: [Int]) -> [ScaleInterval] {
        offsets.map { offset in
            let norm = ((offset % 12) + 12) % 12
            switch norm {
            case 0: return .unison
            case 1: return .flat2
            case 2: return .second
            case 3: return .flat3
            case 4: return .third
            case 5: return .fourth
            case 6: return .sharp4
            case 7: return .fifth
            case 8: return .sharp5
            case 9: return .sixth
            case 10: return .flat7
            case 11: return .seventh
            default: return .unison
            }
        }
    }

    private static func romanNumeral(for degree: Int, quality: ChordQuality) -> String {
        switch quality {
        case .major: return "\(romanNum(degree))"
        case .minor: return "\(romanNum(degree).lowercased())"
        case .diminished: return "\(romanNum(degree).lowercased())°"
        case .augmented: return "\(romanNum(degree))+"
        default: return romanNum(degree)
        }
    }

    private static func romanNumeral7(for degree: Int, quality: ChordQuality) -> String {
        switch quality {
        case .major7: return "\(romanNum(degree))maj7"
        case .dominant7: return "\(romanNum(degree))7"
        case .minor7: return "\(romanNum(degree).lowercased())7"
        case .halfDiminished7: return "\(romanNum(degree).lowercased())ø7"
        case .diminished7: return "\(romanNum(degree).lowercased())°7"
        case .minorMajor7: return "\(romanNum(degree).lowercased())maj7"
        default: return "\(romanNum(degree))7"
        }
    }

    private static func romanNum(_ n: Int) -> String {
        ["", "Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ"][n]
    }
}

// MARK: - 支持类型

/// 音阶中的单个音级
struct ScaleDegree: Equatable, Sendable {
    let note: NoteName
    let interval: ScaleInterval
    let pitch: Int            // 0-11
    let semitoneOffset: Int   // 相对主音半音偏移
}

/// 和弦质量
enum ChordQuality: String, Sendable {
    case major = "大三"
    case minor = "小三"
    case diminished = "减三"
    case augmented = "增三"
    case major7 = "大七"
    case dominant7 = "属七"
    case minor7 = "小七"
    case halfDiminished7 = "半减七"
    case diminished7 = "减七"
    case minorMajor7 = "小大七"
}

/// TSD 功能组
enum TSDFunction: String, Sendable {
    case tonic = "T"          // 主功能
    case subdominant = "S"    // 下属功能
    case dominant = "D"       // 属功能
}

/// 顺阶和弦
struct DiatonicChord: Equatable, Sendable {
    let degree: Int            // 级数 1-7
    let roman: String          // 罗马数字（如 "Ⅰ" "Ⅳ" "Ⅴ7"）
    let rootNote: NoteName     // 根音
    let quality: ChordQuality  // 和弦质量
    let tones: [NoteName]      // 构成音
    let function: TSDFunction  // T/S/D 功能组
}
