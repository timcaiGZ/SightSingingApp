import Foundation

// MARK: - 吉他指板模型（借鉴 buitar GuitarBoard）

/// 完整的吉他指板二维网格
/// 弦（0-5）× 品（0-15），每个位置为一个 FretboardPoint
struct FretboardModel: Sendable {
    let tuning: [Int]              // 6根弦空弦 MIDI 音高
    let tuningNotes: [NoteName]    // 6根弦空弦音名
    let fretCount: Int             // 品位范围（含空弦）
    private(set) var points: [[FretboardPoint]]  // [string][fret]

    // MARK: - 预定义调弦

    /// 标准吉他调弦 EADGBE
    static let standardTuningMIDI: [Int] = [40, 45, 50, 55, 59, 64]  // E2 A2 D3 G3 B3 E4
    /// 尤克里里调弦 GCEA
    static let ukuleleTuningMIDI: [Int] = [67, 60, 64, 69]           // G4 C4 E4 A4
    /// 贝斯调弦 EADG
    static let bassTuningMIDI: [Int] = [28, 33, 38, 43]              // E1 A1 D2 G2

    /// 根据全局 TimbreSettings 获取当前调弦 MIDI
    static var currentTuningMIDI: [Int] {
        let raw = UserDefaults.standard.string(forKey: "timbre.guitarTuning") ?? "guitar-eadgbe"
        switch raw {
        case "ukulele-gcea": return ukuleleTuningMIDI
        case "bass-eadg":    return bassTuningMIDI
        default:             return standardTuningMIDI
        }
    }

    init(tuning: [Int] = currentTuningMIDI, fretCount: Int = 16) {
        self.tuning = tuning
        self.tuningNotes = tuning.map { NoteName(pitch: $0 % 12) }
        self.fretCount = fretCount
        self.points = Self.generatePoints(tuning: tuning, fretCount: fretCount)
    }

    // MARK: - 指板生成

    private static func generatePoints(tuning: [Int], fretCount: Int) -> [[FretboardPoint]] {
        tuning.enumerated().map { stringIndex, openMidi in
            (0..<fretCount).map { fret in
                FretboardPoint(string: stringIndex, fret: fret, tuningMidi: openMidi)
            }
        }
    }

    // MARK: - 查询

    /// 获取指板上特定位置的音高
    func point(at string: Int, fret: Int) -> FretboardPoint? {
        guard string >= 0, string < points.count,
              fret >= 0, fret < points[string].count else { return nil }
        return points[string][fret]
    }

    /// 获取指定弦上的所有品位
    func points(on string: Int) -> [FretboardPoint] {
        guard string >= 0, string < points.count else { return [] }
        return points[string]
    }

    /// 在指板上查找特定音高的所有位置
    func findPositions(of note: NoteName) -> [FretboardPoint] {
        points.flatMap { string in
            string.filter { $0.note == note }
        }
    }

    /// 在指板上查找特定 MIDI 音高的位置
    func findPosition(of midi: Int) -> FretboardPoint? {
        for string in points {
            for point in string where point.midiNote == midi {
                return point
            }
        }
        return nil
    }

    // MARK: - 调式上下文更新

    /// 根据给定调式和主音更新指板上每个点的调内信息
    mutating func applyScale(root: NoteName, mode: ScaleMode) {
        let scale = ScaleEngine.scale(root: root, mode: mode)
        let scalePitches = Set(scale.map { $0.pitch })

        for si in 0..<points.count {
            for fi in 0..<points[si].count {
                let pp = (points[si][fi].note.pitch - root.pitch + 12) % 12
                points[si][fi].isInScale = scalePitches.contains(points[si][fi].note.pitch)

                // 找到对应的音程
                if let tone = scale.first(where: { $0.note.pitch == points[si][fi].note.pitch }) {
                    points[si][fi].interval = tone.interval
                } else {
                    points[si][fi].interval = nil
                }
            }
        }
    }

    // MARK: - 和弦高亮

    /// 获取指板上属于指定和弦音的位置集合
    func chordPositions(chord: ChordIdentity) -> [FretboardPoint] {
        let chordPitches = Set(chord.tones.map { ($0.note.pitch + 12) % 12 })
        return points.flatMap { string in
            string.filter { chordPitches.contains($0.note.pitch) }
        }
    }

    /// 找出吉他上某根弦、某个音名的最低可用品位
    func lowestFret(for note: NoteName, on string: Int, above minFret: Int = 0) -> Int? {
        guard let stringPoints = points.element(at: string) else { return nil }
        return stringPoints
            .filter { $0.note == note && $0.fret >= minFret }
            .map { $0.fret }
            .min()
    }
}

// MARK: - 数组安全访问

private extension Array {
    func element(at index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
