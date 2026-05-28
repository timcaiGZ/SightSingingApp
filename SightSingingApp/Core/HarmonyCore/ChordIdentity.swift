import Foundation

// MARK: - 和弦身份（借鉴 buitar chord key 指纹系统）

/// 和弦类型的完整定义
/// 借鉴 buitar ChordType，通过「半音差距指纹 key」唯一标识和弦类型
struct ChordIdentity: Equatable, Sendable {
    let tag: String               // 标记符号，如 "m" "7" "maj7" "dim"
    let name: String              // 英文名，如 "major triad"
    let nameCN: String            // 中文名，如 "大三和弦"
    let intervals: [ScaleInterval]  // 组成音程（相对根音）
    let key: String               // 和弦指纹：相邻音程半音差拼接 "43" "343" "433"
    let toneCount: Int            // 音数（3=三和弦, 4=七和弦, 5=九和弦...）

    /// 和弦构成音（以根音 C 为例计算）
    var tones: [ChordTone] {
        var result: [ChordTone] = []
        var currentPitch: Int = 0  // 根音 C=0
        for interval in intervals {
            let delta = interval.semitoneOffset
            currentPitch = delta
            let note = NoteName(pitch: currentPitch)
            result.append(ChordTone(note: note, interval: interval))
        }
        return result
    }

    /// 以指定根音的构成音
    func tones(inRoot root: NoteName) -> [ChordTone] {
        let offset = root.pitch
        return intervals.map { interval in
            let pitch = (interval.semitoneOffset + offset) % 12
            return ChordTone(note: NoteName(pitch: pitch), interval: interval)
        }
    }

    /// 生成和弦指纹 key
    /// 例：大三 [1,3,5] 半音距=4,3 → key="43"
    static func computeKey(from intervals: [ScaleInterval]) -> String {
        guard intervals.count > 1 else { return "" }
        var gaps: [Int] = []
        var prev = intervals[0].semitoneOffset
        for i in 1..<intervals.count {
            let curr = intervals[i].semitoneOffset
            gaps.append(curr - prev)
            prev = curr
        }
        return gaps.map(String.init).joined()
    }

    init(tag: String, name: String, nameCN: String, intervals: [ScaleInterval]) {
        self.tag = tag
        self.name = name
        self.nameCN = nameCN
        self.intervals = intervals
        self.key = Self.computeKey(from: intervals)
        self.toneCount = intervals.count
    }
}

// MARK: - 和弦类型库（精选 40+ 常用和弦）

extension ChordIdentity {

    // MARK: 三和弦（ Triads ）

    /// 大三和弦 1-3-5  key=43
    static let major = ChordIdentity(
        tag: "", name: "major triad", nameCN: "大三和弦",
        intervals: [.unison, .third, .fifth]
    )

    /// 小三和弦 1-♭3-5  key=34
    static let minor = ChordIdentity(
        tag: "m", name: "minor triad", nameCN: "小三和弦",
        intervals: [.unison, .flat3, .fifth]
    )

    /// 增三和弦 1-3-#5  key=44
    static let augmented = ChordIdentity(
        tag: "aug", name: "augmented triad", nameCN: "增三和弦",
        intervals: [.unison, .third, .sharp5]
    )

    /// 减三和弦 1-♭3-♭5  key=33
    static let diminished = ChordIdentity(
        tag: "dim", name: "diminished triad", nameCN: "减三和弦",
        intervals: [.unison, .flat3, .flat5]
    )

    /// 挂二和弦 1-2-5  key=25
    static let sus2 = ChordIdentity(
        tag: "sus2", name: "suspended 2nd", nameCN: "挂二和弦",
        intervals: [.unison, .second, .fifth]
    )

    /// 挂四和弦 1-4-5  key=52
    static let sus4 = ChordIdentity(
        tag: "sus4", name: "suspended 4th", nameCN: "挂四和弦",
        intervals: [.unison, .fourth, .fifth]
    )

    // MARK: 七和弦（ Seventh Chords ）

    /// 大七和弦 1-3-5-7  key=434
    static let major7 = ChordIdentity(
        tag: "maj7", name: "major 7th", nameCN: "大七和弦",
        intervals: [.unison, .third, .fifth, .seventh]
    )

    /// 属七和弦 1-3-5-♭7  key=433
    static let dominant7 = ChordIdentity(
        tag: "7", name: "dominant 7th", nameCN: "属七和弦",
        intervals: [.unison, .third, .fifth, .flat7]
    )

    /// 小七和弦 1-♭3-5-♭7  key=343
    static let minor7 = ChordIdentity(
        tag: "m7", name: "minor 7th", nameCN: "小七和弦",
        intervals: [.unison, .flat3, .fifth, .flat7]
    )

    /// 半减七和弦（m7♭5） 1-♭3-♭5-♭7  key=334
    static let halfDiminished7 = ChordIdentity(
        tag: "m7♭5", name: "half-diminished 7th", nameCN: "半减七和弦",
        intervals: [.unison, .flat3, .flat5, .flat7]
    )

    /// 减七和弦 1-♭3-♭5-6  key=333
    static let diminished7 = ChordIdentity(
        tag: "dim7", name: "diminished 7th", nameCN: "减七和弦",
        intervals: [.unison, .flat3, .flat5, .sixth]
    )

    /// 小大七和弦 1-♭3-5-7  key=344
    static let minorMajor7 = ChordIdentity(
        tag: "mMaj7", name: "minor major 7th", nameCN: "小大七和弦",
        intervals: [.unison, .flat3, .fifth, .seventh]
    )

    /// 增七大七和弦 1-3-#5-7  key=443
    static let augmentedMajor7 = ChordIdentity(
        tag: "augMaj7", name: "augmented major 7th", nameCN: "增大七和弦",
        intervals: [.unison, .third, .sharp5, .seventh]
    )

    /// 属七挂四 1-4-5-♭7  key=523
    static let dominant7sus4 = ChordIdentity(
        tag: "7sus4", name: "dominant 7th sus4", nameCN: "属七挂四",
        intervals: [.unison, .fourth, .fifth, .flat7]
    )

    /// 大六和弦 1-3-5-6  key=434 (同大七key但音不同！这里调整为正确的)
    /// 注意：大六=1-3-5-6 半音距=4,3,4(key=434=大七key) — 通过 interval 区分
    static let major6 = ChordIdentity(
        tag: "6", name: "major 6th", nameCN: "大六和弦",
        intervals: [.unison, .third, .fifth, .sixth]
    )

    /// 小六和弦 1-♭3-5-6  key=344 (同小大七key)
    static let minor6 = ChordIdentity(
        tag: "m6", name: "minor 6th", nameCN: "小六和弦",
        intervals: [.unison, .flat3, .fifth, .sixth]
    )

    // MARK: 九和弦（ Ninth Chords ）

    /// 大九和弦 1-3-5-7-9  key=4343
    static let major9 = ChordIdentity(
        tag: "maj9", name: "major 9th", nameCN: "大九和弦",
        intervals: [.unison, .third, .fifth, .seventh, .second]
    )

    /// 属九和弦 1-3-5-♭7-9  key=4333
    static let dominant9 = ChordIdentity(
        tag: "9", name: "dominant 9th", nameCN: "属九和弦",
        intervals: [.unison, .third, .fifth, .flat7, .second]
    )

    /// 小九和弦 1-♭3-5-♭7-9  key=3433
    static let minor9 = ChordIdentity(
        tag: "m9", name: "minor 9th", nameCN: "小九和弦",
        intervals: [.unison, .flat3, .fifth, .flat7, .second]
    )

    /// 属七降九 1-3-5-♭7-♭9  key=4332
    static let dominant7Flat9 = ChordIdentity(
        tag: "7♭9", name: "dominant 7th flat 9", nameCN: "属七降九",
        intervals: [.unison, .third, .fifth, .flat7, .flat2]
    )

    /// 属七升九 1-3-5-♭7-#9  key=4334
    static let dominant7Sharp9 = ChordIdentity(
        tag: "7#9", name: "dominant 7th sharp 9", nameCN: "属七升九",
        intervals: [.unison, .third, .fifth, .flat7, .sharp2]
    )

    // MARK: 加音和弦（ Add Chords ）

    /// 加九和弦 1-3-5-9  key=435
    static let add9 = ChordIdentity(
        tag: "add9", name: "add 9", nameCN: "加九和弦",
        intervals: [.unison, .third, .fifth, .second]
    )

    /// 小加九 1-♭3-5-9  key=345
    static let minorAdd9 = ChordIdentity(
        tag: "madd9", name: "minor add 9", nameCN: "小加九和弦",
        intervals: [.unison, .flat3, .fifth, .second]
    )

    /// 加十一 1-3-5-11  key=434
    static let add11 = ChordIdentity(
        tag: "add11", name: "add 11", nameCN: "加十一和弦",
        intervals: [.unison, .third, .fifth, .fourth]
    )

    // MARK: - 全集与查询

    /// 所有已注册的和弦类型
    static let allTypes: [ChordIdentity] = [
        .major, .minor, .augmented, .diminished, .sus2, .sus4,
        .major7, .dominant7, .minor7, .halfDiminished7, .diminished7,
        .minorMajor7, .augmentedMajor7, .dominant7sus4,
        .major6, .minor6,
        .major9, .dominant9, .minor9,
        .dominant7Flat9, .dominant7Sharp9,
        .add9, .minorAdd9, .add11,
    ]

    /// 通过和弦指纹 key 查找（可能有多个匹配，key 不唯一——如 大六和大七都是434）
    static func findByKey(_ key: String) -> [ChordIdentity] {
        allTypes.filter { $0.key == key }
    }

    /// 通过标签查找（如 "m7" → 小七和弦）
    static func findByTag(_ tag: String) -> ChordIdentity? {
        allTypes.first { $0.tag == tag }
    }

    /// 通过音程组合查找
    static func findByIntervals(_ intervals: [ScaleInterval]) -> ChordIdentity? {
        let targetKey = computeKey(from: intervals)
        let candidates = findByKey(targetKey)
        return candidates.first  // 取第一个匹配
    }

    // MARK: - 和弦名解析

    /// 将和弦名解析为根音 + 和弦类型
    /// 示例："Cm7" → (root: "C", type: .minor7)
    static func parse(_ chordName: String) -> (root: NoteName, type: ChordIdentity)? {
        guard !chordName.isEmpty else { return nil }

        // 提取根音
        var remaining = chordName
        var rootStr: String = ""

        // 第一个字符一定是根音
        if !remaining.isEmpty {
            rootStr.append(remaining.removeFirst())
        }
        // 检查是否有升号
        if remaining.first == "#" {
            rootStr.append(remaining.removeFirst())
        }

        guard let root = NoteName.fromString(rootStr) else { return nil }

        // 剩余部分为标签
        let tag = remaining.isEmpty ? "" : remaining

        // 按标签长度从长到短尝试匹配
        let sorted = allTypes.sorted { $0.tag.count > $1.tag.count }
        for type in sorted where tag.hasPrefix(type.tag) {
            return (root, type)
        }

        // 无标签 → 大三和弦
        if tag.isEmpty { return (root, .major) }

        return nil
    }

    /// 将和弦名转为带有具体音名的和弦构成音
    static func tonesFor(_ chordName: String) -> [ChordTone]? {
        guard let (root, type) = parse(chordName) else { return nil }
        return type.tones(inRoot: root)
    }
}

// MARK: - NoteName 扩展

extension NoteName {
    static func fromString(_ s: String) -> NoteName? {
        switch s.uppercased() {
        case "C": return .C
        case "C#", "C♯", "DB", "D♭": return .CSharp
        case "D": return .D
        case "D#", "D♯", "EB", "E♭": return .DSharp
        case "E": return .E
        case "F": return .F
        case "F#", "F♯", "GB", "G♭": return .FSharp
        case "G": return .G
        case "G#", "G♯", "AB", "A♭": return .GSharp
        case "A": return .A
        case "A#", "A♯", "BB", "B♭": return .ASharp
        case "B": return .B
        default: return nil
        }
    }
}
