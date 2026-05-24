import Foundation
import SwiftUI

// MARK: - Rhythm Playback State

enum RhythmPlaybackState: Sendable {
    case idle
    case countIn
    case playing
    case evaluating
    case completed

    var label: String {
        switch self {
        case .idle: return "准备"
        case .countIn: return "预备拍"
        case .playing: return "进行中"
        case .evaluating: return "评估中"
        case .completed: return "已完成"
        }
    }
}

// MARK: - Timing Result

struct TimingResult: Sendable {
    let beat: Double
    let accuracy: Int       // 0-100
    let deviation: Double   // 拍数偏差
    let isOnBeat: Bool
}

// MARK: - Rhythm Runtime

/// 节奏运行时 —— 全 App 节奏页面的统一状态源。
///
/// 桥接 MasterMusicClock (actor) → SwiftUI (@Observable/MainActor)。
/// 驱动所有 pulse / playhead / breathing / subdivision 的 UI 更新。
@Observable
final class RhythmRuntime {

    // MARK: - Singleton

    static let shared = RhythmRuntime()

    // MARK: - State

    var playbackState: RhythmPlaybackState = .idle
    var currentBeat: Double = 0
    var currentSubdivision: Int = 1       // 1=四分, 2=八分, 3=三连音, 4=十六分
    var currentMeasure: Int = 1
    var currentBPM: Double = 120
    var grooveConfidence: Double = 0      // 0.0 ~ 1.0
    var timingAccuracy: Double = 0        // 0.0 ~ 1.0
    var playheadPosition: Double = 0      // 0.0 ~ 1.0（当前小节内位置）

    // Count-in
    var countInBeat: Int = 0              // 当前 count-in 拍号 (1-based)
    var totalCountInBeats: Int = 4

    // Pattern
    var currentPattern: RhythmPattern?
    var currentPatternName: String = ""

    // Beat events for visualization
    var beatEvents: [RhythmEvent] = []

    // MARK: - Private

    private let clock = MasterMusicClock.shared
    private var clockSubscription: UUID?
    private var beatStartTime: Date?

    // MARK: - Init

    private init() {}

    // MARK: - Count-in

    func beginCountIn(bpm: Double, beats: Int = 4) async {
        await stop()
        currentBPM = bpm
        totalCountInBeats = beats
        countInBeat = 0
        playbackState = .countIn

        await clock.setBPM(bpm)
        await clock.reset()

        if let old = clockSubscription {
            await clock.unsubscribe(old)
        }

        let runtime = self
        clockSubscription = await clock.subscribe { @Sendable tick in
            Task { @MainActor [weak runtime] in
                guard let self = runtime else { return }
                let beat = Int(tick.beat)
                self.countInBeat = beat
                // 轻触觉：每拍 count-in pulse
                if beat <= self.totalCountInBeats {
                    HapticEngine.shared.grooveLock()
                }
            }
        }

        await clock.start()
    }

    func completeCountIn() async {
        if let sub = clockSubscription {
            await clock.unsubscribe(sub)
            clockSubscription = nil
        }
        await clock.stop()
        countInBeat = 0
    }

    // MARK: - Playback

    func startPlaying(pattern: RhythmPattern) async {
        await completeCountIn()

        currentPattern = pattern
        currentPatternName = pattern.name
        currentBPM = pattern.bpm
        beatEvents = pattern.events
        currentSubdivision = detectSubdivision(pattern)
        currentMeasure = 1
        currentBeat = 0
        playheadPosition = 0
        grooveConfidence = 0.5
        timingAccuracy = 0.7
        beatStartTime = Date()

        await clock.setBPM(pattern.bpm)
        await clock.reset()

        playbackState = .playing

        if let old = clockSubscription {
            await clock.unsubscribe(old)
        }

        let beatsPerMeasure = pattern.beatsPerMeasure
        let runtime = self
        clockSubscription = await clock.subscribe { @Sendable tick in
            Task { @MainActor [weak runtime] in
                guard let self = runtime else { return }
                let bpm = tick.bpm
                self.currentBPM = bpm
                self.currentBeat = tick.beat
                self.currentMeasure = Int(tick.beat / Double(beatsPerMeasure)) + 1
                let beatInMeasure = tick.beat.truncatingRemainder(dividingBy: Double(beatsPerMeasure))
                self.playheadPosition = beatInMeasure / Double(beatsPerMeasure)

                // Strong beat accent
                if beatInMeasure < 0.01 {
                    HapticEngine.shared.grooveLock()
                }
            }
        }

        await clock.start()
    }

    // MARK: - Tap Evaluation

    func evaluateTap(at tapDate: Date) -> TimingResult? {
        guard playbackState == .playing, let pattern = currentPattern else { return nil }

        let beatInterval = 60.0 / currentBPM
        let elapsed = tapDate.timeIntervalSince(beatStartTime ?? Date())
        let tappedBeat = elapsed / beatInterval

        // Find nearest expected event
        var bestDeviation = Double.infinity
        var closestEvent: RhythmEvent?
        for event in pattern.events {
            let deviation = abs(tappedBeat - event.beat)
            if deviation < bestDeviation {
                bestDeviation = deviation
                closestEvent = event
            }
        }

        guard let event = closestEvent else { return nil }

        let score = RhythmEngine.evaluateTiming(actual: tappedBeat, expected: event.beat)
        let isOnBeat = score >= 70

        // Update groove
        if isOnBeat {
            grooveConfidence = min(1.0, grooveConfidence + 0.12 * (event.accent))
            timingAccuracy = (timingAccuracy * 0.7) + (Double(score) / 100.0 * 0.3)
        } else {
            grooveConfidence = max(0.0, grooveConfidence - 0.08)
        }

        return TimingResult(
            beat: tappedBeat,
            accuracy: score,
            deviation: bestDeviation,
            isOnBeat: isOnBeat
        )
    }

    // MARK: - Answer Evaluation

    func evaluateAnswer(selectedPattern: RhythmPattern) -> Int {
        guard let current = currentPattern else { return 0 }
        return selectedPattern.name == current.name ? 100 : 0
    }

    // MARK: - Stop / Reset

    func stop() async {
        playbackState = .completed
        await clock.stop()
        if let sub = clockSubscription {
            await clock.unsubscribe(sub)
            clockSubscription = nil
        }
    }

    func reset() async {
        await stop()
        playbackState = .idle
        grooveConfidence = 0
        timingAccuracy = 0
        countInBeat = 0
        currentMeasure = 1
        currentBeat = 0
        playheadPosition = 0
        currentPattern = nil
        currentPatternName = ""
        beatEvents = []
        beatStartTime = nil
    }

    // MARK: - Groove Decay (when idle)

    func applyDecay() {
        guard playbackState != .playing else { return }
        if grooveConfidence > 0 {
            grooveConfidence = max(0, grooveConfidence - 0.02)
        }
    }

    // MARK: - Private

    private func detectSubdivision(_ pattern: RhythmPattern) -> Int {
        guard pattern.events.count > 1 else { return 1 }
        let sorted = pattern.events.map(\.beat).sorted()
        var minGap = Double.infinity
        for i in 1..<sorted.count {
            let gap = sorted[i] - sorted[i - 1]
            if gap > 0.001 && gap < minGap {
                minGap = gap
            }
        }
        if minGap <= 0.26 { return 4 }
        if minGap <= 0.35 { return 3 }
        if minGap <= 0.6 { return 2 }
        return 1
    }
}
