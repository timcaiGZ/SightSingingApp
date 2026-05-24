import Foundation

// MARK: - 节奏型数据模型
//
// 基于《刁Sir吉他扫弦干货铺》教材中的15组四分节奏练习。
// 每组练习定义了16个十六分音符格子（4/4拍）：
//   - 脚：每拍第一格打拍子
//   - 手：按格子扫弦（↓ 下扫 / ↑ 上扫 / - 休止）
//   - 嘴：在标记为「X」的格子唱「嗒」
//

enum StrumDirection: String, CaseIterable {
    case down = "↓"
    case up = "↑"
    case rest = "−"
}

struct RhythmSlot {
    let strum: StrumDirection
    let vocal: Bool      // 是否唱「嗒」
    let foot: Bool       // 脚是否打拍子
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

struct RhythmPattern {
    let id: Int           // 1~15
    let name: String
    let description: String
    let recommendedBPM: Int
    let slots: [RhythmSlot]   // 16个格子 = 1小节（4/4）
    let swingAmount: Double?  // 兼容旧代码

    var beatCount: Int { 4 }
    var subdivision: Int { 4 } // 每拍4个十六分格

    // 兼容旧代码
    var bpm: Double { Double(recommendedBPM) }
    var beatsPerMeasure: Int { beatCount }

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

    // 兼容旧代码初始化器
    init(id: Int = 0, name: String, description: String = "", recommendedBPM: Int = 120, slots: [RhythmSlot], swingAmount: Double? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.recommendedBPM = recommendedBPM
        self.slots = slots
        self.swingAmount = swingAmount
    }
}

// MARK: - 15组四分节奏练习定义

extension RhythmPattern {

    /// 全部15组「四分节奏」练习
    static let allQuarters: [RhythmPattern] = [
        pattern01, pattern02, pattern03, pattern04, pattern05,
        pattern06, pattern07, pattern08, pattern09, pattern10,
        pattern11, pattern12, pattern13, pattern14, pattern15
    ]

    // MARK: 1. 基础四分 — X X X X（全上扫，每拍唱「嗒」）
    private static let pattern01 = RhythmPattern(
        id: 1,
        name: "基础四分",
        description: "每拍一个四分音符，最基础的稳定律动",
        recommendedBPM: 60,
        slots: [
            // 拍1      拍2      拍3      拍4
            Slot(sD, T, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
        ]
    )

    // MARK: 2. 后半拍进入·手四分 — 0 X• XX• XX• XX•
    //   第一拍前半拍休止，后半拍进入；手保持每拍一下
    private static let pattern02 = RhythmPattern(
        id: 2,
        name: "后半拍进入·手四分",
        description: "嘴从后半拍开始唱，手每拍稳定扫一下",
        recommendedBPM: 60,
        slots: [
            Slot(sR, F, T), Slot(sR, F, F), Slot(sD, T, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sD, T, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sD, T, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sD, T, F), Slot(sR, F, F),
        ]
    )

    // MARK: 3. 后半拍进入·手八分 — 0 X X X X X X X
    //   嘴和手同步，从第一拍后半拍开始，每半拍一下
    private static let pattern03 = RhythmPattern(
        id: 3,
        name: "后半拍进入·手八分",
        description: "手嘴同步，下上交替扫弦，从后半拍进入",
        recommendedBPM: 60,
        slots: [
            Slot(sR, F, T), Slot(sR, F, F), Slot(sD, T, F), Slot(sR, F, F),
            Slot(sU, T, T), Slot(sR, F, F), Slot(sD, T, F), Slot(sR, F, F),
            Slot(sU, T, T), Slot(sR, F, F), Slot(sD, T, F), Slot(sR, F, F),
            Slot(sU, T, T), Slot(sR, F, F), Slot(sD, T, F), Slot(sR, F, F),
        ]
    )

    // MARK: 4. 二分休止·八分连音 — 0- XX• XX• XX• X
    //   前两拍休止，后两拍每拍两个八分，最后半拍收
    private static let pattern04 = RhythmPattern(
        id: 4,
        name: "二分休止·八分连音",
        description: "前两拍休止，后两拍嘴唱八分连音，手四分",
        recommendedBPM: 60,
        slots: [
            Slot(sR, F, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sR, F, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sD, T, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
        ]
    )

    // MARK: 5. 大附点节奏 — X X• X X• X X• X X•
    //   附点八分 + 十六分，每拍「哒-哒」感觉
    private static let pattern05 = RhythmPattern(
        id: 5,
        name: "大附点节奏",
        description: "附点八分接十六分，手每拍扫一下",
        recommendedBPM: 55,
        slots: [
            Slot(sD, T, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sD, T, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sD, T, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sD, T, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sD, T, F),
        ]
    )

    // MARK: 6. 全八分音符 — X X X X X X X X
    //   每半拍一个八分，手嘴同步下上扫
    private static let pattern06 = RhythmPattern(
        id: 6,
        name: "全八分音符",
        description: "每半拍一个八分音符，手下上交替扫弦",
        recommendedBPM: 55,
        slots: [
            Slot(sD, T, T), Slot(sR, F, F), Slot(sU, T, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sU, T, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sU, T, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sU, T, F), Slot(sR, F, F),
        ]
    )

    // MARK: 7. 切分·八分 — X• XX• XX• XX• X
    //   第一拍后半拍进入，中间连续八分，最后一拍前半拍收
    private static let pattern07 = RhythmPattern(
        id: 7,
        name: "切分·八分",
        description: "带切分感的八分节奏，手八分下上扫",
        recommendedBPM: 55,
        slots: [
            Slot(sR, F, T), Slot(sR, F, F), Slot(sD, T, F), Slot(sR, F, F),
            Slot(sU, T, T), Slot(sR, F, F), Slot(sD, T, F), Slot(sR, F, F),
            Slot(sU, T, T), Slot(sR, F, F), Slot(sD, T, F), Slot(sR, F, F),
            Slot(sU, T, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
        ]
    )

    // MARK: 8. 三连音入门 — 0 X X XXX XXX XXX
    //   第一拍休止，第二拍两个八分，后三拍三连音
    private static let pattern08 = RhythmPattern(
        id: 8,
        name: "三连音入门",
        description: "第一拍休止，逐步进入三连音律动",
        recommendedBPM: 50,
        slots: [
            Slot(sR, F, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sD, T, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
        ]
    )

    // MARK: 9. 三连音基础 — 0 X XXX XXX XXX X
    //   三连音为主体，首尾八分点缀
    private static let pattern09 = RhythmPattern(
        id: 9,
        name: "三连音基础",
        description: "三连音为主体，手嘴协调三连音扫法",
        recommendedBPM: 50,
        slots: [
            Slot(sR, F, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
        ]
    )

    // MARK: 10. 三连音进阶 — 0 XXX XXX XXX XXX
    //   第一拍四分休止，后三拍全三连音
    private static let pattern10 = RhythmPattern(
        id: 10,
        name: "三连音进阶",
        description: "第一拍休止后进入连续三连音",
        recommendedBPM: 50,
        slots: [
            Slot(sR, F, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
        ]
    )

    // MARK: 11. 全三连音 — XXX XXX XXX XXX
    //   每拍一组三连音，全小节连续
    private static let pattern11 = RhythmPattern(
        id: 11,
        name: "全三连音",
        description: "整小节四组三连音，手下上下来回扫",
        recommendedBPM: 50,
        slots: [
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
        ]
    )

    // MARK: 12. 十六分组合 — XX XX XX XX XX X
    //   以八分为基础，加入十六分点缀
    private static let pattern12 = RhythmPattern(
        id: 12,
        name: "十六分组合",
        description: "八分与十六分混合，手开始加速",
        recommendedBPM: 50,
        slots: [
            Slot(sD, T, T), Slot(sU, T, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, T, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, T, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, T, F), Slot(sR, F, F), Slot(sR, F, F),
        ]
    )

    // MARK: 13. 十六分切分 — X XXX XXX XXX XXX
    //   正拍加重，后半拍十六分三连缀
    private static let pattern13 = RhythmPattern(
        id: 13,
        name: "十六分切分",
        description: "正拍四分加重，后半拍十六分连缀",
        recommendedBPM: 50,
        slots: [
            Slot(sD, T, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, F, F), Slot(sD, F, F), Slot(sR, F, F),
        ]
    )

    // MARK: 14. 全十六分前奏 — 0 XXXXXXXXXXXXXXXX
    //   第一拍休止，后三拍全十六分
    private static let pattern14 = RhythmPattern(
        id: 14,
        name: "全十六分前奏",
        description: "第一拍休止，后三拍连续十六分音符",
        recommendedBPM: 45,
        slots: [
            Slot(sR, F, T), Slot(sR, F, F), Slot(sR, F, F), Slot(sR, F, F),
            Slot(sD, T, T), Slot(sU, T, F), Slot(sD, T, F), Slot(sU, T, F),
            Slot(sD, T, T), Slot(sU, T, F), Slot(sD, T, F), Slot(sU, T, F),
            Slot(sD, T, T), Slot(sU, T, F), Slot(sD, T, F), Slot(sU, T, F),
        ]
    )

    // MARK: 15. 全十六分音符 — XXXXXXXXXXXXXXXX
    //   整小节16个十六分音符，最高速
    private static let pattern15 = RhythmPattern(
        id: 15,
        name: "全十六分音符",
        description: "整小节16个十六分，手脚嘴全速协调",
        recommendedBPM: 45,
        slots: [
            Slot(sD, T, T), Slot(sU, T, F), Slot(sD, T, F), Slot(sU, T, F),
            Slot(sD, T, T), Slot(sU, T, F), Slot(sD, T, F), Slot(sU, T, F),
            Slot(sD, T, T), Slot(sU, T, F), Slot(sD, T, F), Slot(sU, T, F),
            Slot(sD, T, T), Slot(sU, T, F), Slot(sD, T, F), Slot(sU, T, F),
        ]
    )
}

// MARK: - Helpers

private let T = true
private let F = false
private let sD = StrumDirection.down
private let sU = StrumDirection.up
private let sR = StrumDirection.rest

private func Slot(_ strum: StrumDirection, _ vocal: Bool, _ foot: Bool) -> RhythmSlot {
    RhythmSlot(strum: strum, vocal: vocal, foot: foot)
}
