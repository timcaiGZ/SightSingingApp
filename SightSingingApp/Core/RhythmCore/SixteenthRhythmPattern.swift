import Foundation

// MARK: - 十六分音符手脚口协调节奏训练数据模型
//
// 4/4 拍：1 小节 = 4 拍，每拍 = 4 个十六分音符位置（1/2/3/4）
// 总共 16 个位置（1~16）
//
// 脚：始终踩在 1、5、9、13（每拍第 1 位）
// 手（吉他）：固定扫弦节奏 ↓ ↓↑↓ ↓↑↓ ↓↑↓
// 唱（嘴）：「哒」按指定位置出现

// MARK: - 固定手扫弦节奏

/// 所有十六分音符训练通用的右手扫弦模式
struct SixteenthHandStrum {
    /// 位置 → 扫弦方向，未指定的位置为空拍
    static let pattern: [Int: StrumDirection] = [
        1: .down,
        5: .down,  7: .up,   8: .down,
        9: .down,  10: .up,  11: .down,
        13: .down, 15: .up,  16: .down,
    ]

    static func direction(at position: Int) -> StrumDirection {
        pattern[position] ?? .rest
    }
}

// MARK: - 十六分音符训练模式

/// 单个十六分音符手脚口协调训练模式
struct SixteenthRhythmPattern: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: SixteenthRhythmPattern, rhs: SixteenthRhythmPattern) -> Bool { lhs.id == rhs.id }

    let id: Int                    // 1~5
    let name: String               // 卡片标题
    let description: String        // 简要说明
    let voicePositions: [Int]      // 唱「哒」的位置 (1-based, 1~16)
    let recommendedBPM: Int        // 推荐 BPM

    /// 每拍的位置映射
    var beats: [(beat: Int, subPositions: [Int])] {
        stride(from: 1, through: 16, by: 4).map { startPos in
            let beatNum = (startPos + 3) / 4
            return (beat: beatNum, subPositions: Array(startPos..<(startPos + 4)))
        }
    }
}

// MARK: - 5 组训练定义

extension SixteenthRhythmPattern {

    static let allPatterns: [SixteenthRhythmPattern] = [
        SixteenthRhythmPattern(
            id: 1, name: "全部在每拍第 1 位唱",
            description: "脚踩拍点 1/5/9/13，唱在每拍第 1 位",
            voicePositions: [1, 5, 9, 13],
            recommendedBPM: 60
        ),
        SixteenthRhythmPattern(
            id: 2, name: "全部在每拍第 3 位唱",
            description: "脚踩拍点 1/5/9/13，唱在每拍第 3 位",
            voicePositions: [3, 7, 11, 15],
            recommendedBPM: 60
        ),
        SixteenthRhythmPattern(
            id: 3, name: "拍 1-1、拍 2-3、拍 3-1、拍 4-3",
            description: "非对称唱位练习",
            voicePositions: [1, 7, 9, 15],
            recommendedBPM: 60
        ),
        SixteenthRhythmPattern(
            id: 4, name: "拍 1-3、拍 2-1、拍 3-3、拍 4-1",
            description: "非对称唱位练习",
            voicePositions: [3, 5, 11, 13],
            recommendedBPM: 60
        ),
        SixteenthRhythmPattern(
            id: 5, name: "拍 1 空、拍 2-3、拍 3-1+3、拍 4-1",
            description: "复杂对位练习",
            voicePositions: [7, 9, 11, 13],
            recommendedBPM: 60
        ),
    ]
}
