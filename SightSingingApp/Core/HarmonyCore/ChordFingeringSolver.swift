import Foundation

// MARK: - 和弦按法（搜索结果）

/// 指板上的一个完整和弦按法
struct ChordVoicing: Equatable, Sendable {
    let chordName: String            // 和弦名（如 "Cm7"）
    let chordType: ChordIdentity     // 和弦类型
    let root: NoteName               // 根音
    let taps: [ChordStringTap]       // 6根弦的按法（长度固定为6）
    let lowestFret: Int              // 最低品位
    let barreFret: Int?              // 横按品位（若有）
    let difficulty: VoicingDifficulty // 难度评级

    /// 是否为横按按法
    var isBarre: Bool { barreFret != nil }

    /// 按弦的手指数
    var fingerCount: Int {
        Set(taps.compactMap { $0.finger }).count
    }
}

/// 单根弦上的按法
struct ChordStringTap: Equatable, Sendable {
    let string: Int         // 弦号 0-5
    let fret: Int?          // 品位（nil=不弹, 0=空弦）
    let finger: Int?        // 左手指法 1-4
    let note: NoteName?     // 该位置的音名
}

/// 按法难度
enum VoicingDifficulty: String, Sendable {
    case beginner    // 初学者（开放把位、无横按）
    case intermediate // 中级（小横按、5品以内）
    case advanced    // 高级（大横按、高把位）
}

// MARK: - 指法求解器（借鉴 buitar findNextString 递归算法）

/// 给定和弦音 → 搜索指板上所有可行按法
struct ChordFingeringSolver {

    /// 手指最大跨度（品）
    static let maxFingerSpan = 4

    /// 手指最大使用数
    static let maxFingers = 4

    // MARK: - 主入口

    /// 搜索指定和弦的全部可行按法
    /// - Parameters:
    ///   - chordName: 和弦名称（如 "Cm7"）
    ///   - fretboard: 指板模型
    ///   - maxVoicings: 最大返回数量（默认 10）
    /// - Returns: 所有可行按法，按最低品位升序排列
    static func solve(
        chordName: String,
        on fretboard: FretboardModel,
        maxVoicings: Int = 10
    ) -> [ChordVoicing] {
        guard let (root, chordType) = ChordIdentity.parse(chordName) else { return [] }

        let chordTones = chordType.tones(inRoot: root)
        let requiredNotes = Set(chordTones.map { $0.note })

        // Step 1: 递归搜索所有候选按法
        var candidates: [[ChordStringTap?]] = []
        findNextString(
            stringIndex: 0,
            currentVoicing: Array(repeating: nil, count: 6),
            requiredNotes: requiredNotes,
            fretboard: fretboard,
            minFret: 0,
            maxFret: 15,
            result: &candidates
        )

        // Step 2: 三道过滤
        var voicings = candidates
            .compactMap { taps in
                buildVoicing(
                    taps: taps,
                    chordName: chordName,
                    chordType: chordType,
                    root: root,
                    requiredNotes: requiredNotes,
                    fretboard: fretboard
                )
            }
            .filter { validateVoicing($0, requiredNotes: requiredNotes) }

        // Step 3: 去覆盖 — 若A被B完全包含则去掉A
        voicings = deduplicateVoicings(voicings)

        // Step 4: 按最低品位排序
        voicings.sort { $0.lowestFret < $1.lowestFret }

        return Array(voicings.prefix(maxVoicings))
    }

    // MARK: - 递归搜索

    /// 从低音弦到高音弦逐弦递归搜索
    private static func findNextString(
        stringIndex: Int,
        currentVoicing: [ChordStringTap?],
        requiredNotes: Set<NoteName>,
        fretboard: FretboardModel,
        minFret: Int,
        maxFret: Int,
        result: inout [[ChordStringTap?]]
    ) {
        guard stringIndex < 6 else {
            result.append(currentVoicing)
            return
        }

        // 选项：不弹（nil）、空弦（fret=0）、按弦（fret=1..maxFret）
        var options: [ChordStringTap?] = [nil]  // 不弹

        // 空弦
        if let openPoint = fretboard.point(at: stringIndex, fret: 0) {
            let isChordTone = requiredNotes.contains(openPoint.note)
            options.append(ChordStringTap(
                string: stringIndex, fret: 0, finger: isChordTone ? nil : nil,
                note: openPoint.note
            ))
        }

        // 按弦 — 遍历范围受手指跨度限制
        let currentFrets = currentVoicing.compactMap { $0?.fret }.filter { $0 > 0 }
        let spanStart: Int
        if let lowest = currentFrets.min(), let highest = currentFrets.max() {
            spanStart = max(1, highest - maxFingerSpan)
        } else {
            spanStart = 1
        }

        for fret in spanStart...maxFret {
            guard let point = fretboard.point(at: stringIndex, fret: fret) else { continue }
            guard requiredNotes.contains(point.note) else { continue }

            // 检查手指跨度
            var testFrets = currentFrets + [fret]
            if let lo = testFrets.min(), let hi = testFrets.max() {
                guard hi - lo <= maxFingerSpan else { continue }
            }

            options.append(ChordStringTap(
                string: stringIndex, fret: fret, finger: nil,  // finger 后续再分配
                note: point.note
            ))
        }

        for option in options {
            var next = currentVoicing
            next[stringIndex] = option
            findNextString(
                stringIndex: stringIndex + 1,
                currentVoicing: next,
                requiredNotes: requiredNotes,
                fretboard: fretboard,
                minFret: minFret,
                maxFret: maxFret,
                result: &result
            )
        }
    }

    // MARK: - 构建和弦按法

    private static func buildVoicing(
        taps: [ChordStringTap?],
        chordName: String,
        chordType: ChordIdentity,
        root: NoteName,
        requiredNotes: Set<NoteName>,
        fretboard: FretboardModel
    ) -> ChordVoicing? {
        let filledTaps: [ChordStringTap] = taps.enumerated().compactMap { si, tap in
            guard let t = tap else { return nil }
            return ChordStringTap(
                string: t.string, fret: t.fret,
                finger: t.finger,
                note: t.note ?? fretboard.point(at: si, fret: t.fret ?? 0)?.note
            )
        }

        // 分配手指编号
        let assigned = assignFingers(filledTaps)

        // 转换为6弦数组（未按的弦为 nil）
        var finalTaps: [ChordStringTap] = []
        for si in 0..<6 {
            if let match = assigned.first(where: { $0.string == si }) {
                finalTaps.append(match)
            } else {
                finalTaps.append(ChordStringTap(string: si, fret: nil, finger: nil, note: nil))
            }
        }

        let pressedFrets = assigned.compactMap { $0.fret }.filter { $0 > 0 }
        let lowestFret = pressedFrets.min() ?? 0
        let barreFret = detectBarre(taps: assigned)

        let difficulty: VoicingDifficulty = {
            if lowestFret <= 3 && barreFret == nil { return .beginner }
            if lowestFret <= 7 { return .intermediate }
            return .advanced
        }()

        return ChordVoicing(
            chordName: chordName,
            chordType: chordType,
            root: root,
            taps: finalTaps,
            lowestFret: lowestFret,
            barreFret: barreFret,
            difficulty: difficulty
        )
    }

    // MARK: - 手指分配

    /// 为按弦分配手指编号（1-4）
    private static func assignFingers(_ taps: [ChordStringTap]) -> [ChordStringTap] {
        let pressed = taps.filter { ($0.fret ?? 0) > 0 }
        guard !pressed.isEmpty else { return taps }

        // 按品位从低到高排序
        let sorted = pressed.sorted { ($0.fret ?? 0) < ($1.fret ?? 0) }

        return taps.map { tap in
            guard let fret = tap.fret, fret > 0 else { return tap }
            let index = sorted.firstIndex(where: { $0.string == tap.string && $0.fret == fret }) ?? 0
            let finger = min(index + 1, 4)
            return ChordStringTap(string: tap.string, fret: fret, finger: finger, note: tap.note)
        }
    }

    // MARK: - 横按检测

    /// 检测是否存在横按（同一品位至少2根相邻弦）
    private static func detectBarre(taps: [ChordStringTap]) -> Int? {
        let pressed = taps.filter { ($0.fret ?? 0) > 0 }
        let fretGroups = Dictionary(grouping: pressed) { $0.fret! }
        for (fret, group) in fretGroups where group.count >= 2 {
            let strings = group.map { $0.string }.sorted()
            // 检查是否为相邻弦
            if zip(strings, strings.dropFirst()).allSatisfy({ $1 - $0 == 1 }) {
                return fret
            }
        }
        return nil
    }

    // MARK: - 验证

    /// 验证按法的有效性
    private static func validateVoicing(_ voicing: ChordVoicing, requiredNotes: Set<NoteName>) -> Bool {
        let playedTaps = voicing.taps.compactMap { $0.note }
        let playedNotes = Set(playedTaps)

        // 必须包含所有和弦音
        guard requiredNotes.isSubset(of: playedNotes) else { return false }

        // 按弦手指 ≤ 4
        let fingerSet = Set(voicing.taps.compactMap { $0.finger })
        guard fingerSet.count <= maxFingers else { return false }

        // 最低品位 < 12（太高的把位实际很少用）
        guard voicing.lowestFret < 12 else { return false }

        // 至少按 3 根弦
        let pressedCount = voicing.taps.filter { ($0.fret ?? 0) > 0 }.count
        guard pressedCount >= 3 else { return false }

        // 不能连续两弦相同音名+相同八度
        for i in 0..<voicing.taps.count - 1 {
            guard let a = voicing.taps[i].note,
                  let b = voicing.taps[i + 1].note,
                  let fa = voicing.taps[i].fret,
                  let fb = voicing.taps[i + 1].fret else { continue }
            if a == b && fa == fb { return false }
        }

        return true
    }

    // MARK: - 去覆盖

    /// 若按法 A 被按法 B 完全包含（B 的品位 ≤ A 的同弦品位），去掉 A
    private static func deduplicateVoicings(_ voicings: [ChordVoicing]) -> [ChordVoicing] {
        var result = voicings
        var i = 0
        while i < result.count {
            var j = 0
            var covered = false
            while j < result.count {
                guard i != j else { j += 1; continue }
                if isCovered(result[i], by: result[j]) {
                    covered = true
                    break
                }
                j += 1
            }
            if covered {
                result.remove(at: i)
            } else {
                i += 1
            }
        }
        return result
    }

    private static func isCovered(_ a: ChordVoicing, by b: ChordVoicing) -> Bool {
        for si in 0..<6 {
            let af = a.taps[si].fret ?? Int.max
            let bf = b.taps[si].fret ?? Int.max
            if bf > af { return false }
        }
        return a.lowestFret > b.lowestFret
    }
}
