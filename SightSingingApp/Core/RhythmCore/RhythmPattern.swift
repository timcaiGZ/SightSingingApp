import Foundation

/// 节奏模式模型
struct RhythmPattern: Codable, Sendable {
    let name: String
    let events: [RhythmEvent]
    let beatsPerMeasure: Int
    let bpm: Double
    let swingAmount: Double?  // nil = 无 swing

    init(
        name: String = "Custom",
        events: [RhythmEvent] = [],
        beatsPerMeasure: Int = 4,
        bpm: Double = 120,
        swingAmount: Double? = nil
    ) {
        self.name = name
        self.events = events
        self.beatsPerMeasure = beatsPerMeasure
        self.bpm = bpm
        self.swingAmount = swingAmount
    }
}

/// 节奏事件 — 时间线上的一个节奏点
struct RhythmEvent: Codable, Identifiable, Sendable {
    let id: UUID
    let beat: Double             // 拍位
    let accent: Double           // 强调值 0-1
    let articulation: Articulation

    init(
        id: UUID = UUID(),
        beat: Double,
        accent: Double = 1.0,
        articulation: Articulation = .normal
    ) {
        self.id = id
        self.beat = beat
        self.accent = accent
        self.articulation = articulation
    }
}

/// 演奏法
enum Articulation: String, Codable, Sendable {
    case normal    // 正常
    case staccato  // 断奏（短促）
    case tenuto    // 保持（充分时值）
    case rest      // 休止
}
