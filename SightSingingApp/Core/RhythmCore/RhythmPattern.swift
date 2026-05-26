import Foundation

// MARK: - 四分音符手脚口协调节奏训练数据模型
//
// 每个四分音符有 4 个均匀的 subdivision 位置（1 / 2 / 3 / 4）：
//   - 脚：始终踩在每个四分音符的第 1 个位置
//   - 手（吉他）：始终扫在每个四分音符的第 1 个位置
//   - 唱（嘴）：「哒」可以出现在 1/2/3/4 任意位置
//
// 15 组训练按唱的音符数量分组：
//   第 1 组：唱一下哒（4 种：在 1/2/3/4 位置唱）
//   第 2 组：唱两下哒（6 种：12/13/14/23/24/34 位置）
//   第 3 组：唱三下哒（4 种：123/124/134/234 位置）
//   第 4 组：唱四下哒（1 种：1234 全部位置）

enum StrumDirection: String, CaseIterable {
    case down = "↓"
    case up = "↑"
    case rest = "−"
}

struct RhythmSlot {
    let strum: StrumDirection
    let vocal: Bool
    let foot: Bool
}

enum Articulation {
    case normal
}

struct RhythmEvent {
    let beat: Double
    let accent: Double
    let articulation: Articulation

    init(beat: Double, accent: Double, articulation: Articulation = .normal) {
        self.beat = beat
        self.accent = accent
        self.articulation = articulation
    }
}

/// 单组手脚口协调练习定义
struct RhythmPattern: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: RhythmPattern, rhs: RhythmPattern) -> Bool { lhs.id == rhs.id }

    let id: Int           // 1~15
    let name: String      // 卡片标题，如 "在 1 位置唱"、"12 位置"
    let groupIndex: Int   // 1=唱一下哒, 2=唱两下哒, 3=唱三下哒, 4=唱四下哒
    let description: String
    let recommendedBPM: Int
    let voicePositions: [Int]  // 每个四分音符中「哒」出现的位置 (1-based, 1~4)
    let slots: [RhythmSlot]    // 4 个格子 = 1 个四分音符
    let swingAmount: Double?   // 兼容旧代码

    var beatCount: Int { 1 }
    var subdivision: Int { 4 }

    // 兼容旧代码
    var bpm: Double { Double(recommendedBPM) }
    var beatsPerMeasure: Int { 1 }

    var events: [RhythmEvent] {
        var evs: [RhythmEvent] = []
        for (idx, slot) in slots.enumerated() {
            if slot.strum != .rest || slot.vocal {
                let beat = Double(idx) / 4.0
                let accent = slot.foot ? 1.0 : (slot.strum != .rest ? 0.7 : 0.4)
                evs.append(RhythmEvent(beat: beat, accent: accent))
            }
        }
        return evs
    }

    // 生成 4 拍完整小节的 slots（每拍重复 1 次该模式）
    var barSlots: [RhythmSlot] { slots + slots + slots + slots }
    var barBeatCount: Int { 4 }

    init(id: Int = 0, name: String, groupIndex: Int = 1, description: String = "", recommendedBPM: Int = 60, voicePositions: [Int], slots: [RhythmSlot]? = nil, swingAmount: Double? = nil) {
        self.id = id
        self.name = name
        self.groupIndex = groupIndex
        self.description = description
        self.recommendedBPM = recommendedBPM
        self.voicePositions = voicePositions

        if let providedSlots = slots {
            self.slots = providedSlots
        } else {
            // 根据 voicePositions 自动生成：脚和手在位置1，唱在指定位置
            var generatedSlots: [RhythmSlot] = []
            for pos in 1...4 {
                generatedSlots.append(RhythmSlot(
                    strum: pos == 1 ? .up : .rest,
                    vocal: voicePositions.contains(pos),
                    foot: pos == 1
                ))
            }
            self.slots = generatedSlots
        }
        self.swingAmount = swingAmount
    }
}

// MARK: - 15组手脚口协调训练定义

extension RhythmPattern {

    /// 全部 15 组训练
    static let allQuarters: [RhythmPattern] = [
        // 第 1 组：唱一下哒（4 种）
        makePattern(id: 1,  group: 1, name: "在 1 位置唱",  positions: [1]),
        makePattern(id: 2,  group: 1, name: "在 2 位置唱",  positions: [2]),
        makePattern(id: 3,  group: 1, name: "在 3 位置唱",  positions: [3]),
        makePattern(id: 4,  group: 1, name: "在 4 位置唱",  positions: [4]),
        // 第 2 组：唱两下哒（6 种）
        makePattern(id: 5,  group: 2, name: "12 位置",        positions: [1, 2]),
        makePattern(id: 6,  group: 2, name: "13 位置",        positions: [1, 3]),
        makePattern(id: 7,  group: 2, name: "14 位置",        positions: [1, 4]),
        makePattern(id: 8,  group: 2, name: "23 位置",        positions: [2, 3]),
        makePattern(id: 9,  group: 2, name: "24 位置",        positions: [2, 4]),
        makePattern(id: 10, group: 2, name: "34 位置",        positions: [3, 4]),
        // 第 3 组：唱三下哒（4 种）
        makePattern(id: 11, group: 3, name: "123 位置",       positions: [1, 2, 3]),
        makePattern(id: 12, group: 3, name: "124 位置",       positions: [1, 2, 4]),
        makePattern(id: 13, group: 3, name: "134 位置",       positions: [1, 3, 4]),
        makePattern(id: 14, group: 3, name: "234 位置",       positions: [2, 3, 4]),
        // 第 4 组：唱四下哒（1 种）
        makePattern(id: 15, group: 4, name: "1234 全部位置",  positions: [1, 2, 3, 4]),
    ]

    private static func makePattern(id: Int, group: Int, name: String, positions: [Int]) -> RhythmPattern {
        RhythmPattern(
            id: id,
            name: name,
            groupIndex: group,
            recommendedBPM: 60,
            voicePositions: positions
        )
    }

    // MARK: 分组描述

    static let groupTitles = [
        1: ("唱一下哒", "四个位置任选一个位置唱"),
        2: ("唱两下哒", "四个位置中任选两个位置"),
        3: ("唱三下哒", "四个位置中任选三个位置"),
        4: ("唱四下哒", "四个位置全部都唱"),
    ]

    static let groupColors = [
        1: (badge: "blue",   bg: "sectionBlue"),
        2: (badge: "pink",   bg: "sectionPink"),
        3: (badge: "green",  bg: "sectionGreen"),
        4: (badge: "purple", bg: "sectionPurple"),
    ]

    /// 按 groupIndex 分组的模式
    static var groupedPatterns: [[RhythmPattern]] {
        [1, 2, 3, 4].map { group in
            allQuarters.filter { $0.groupIndex == group }
        }
    }
}
