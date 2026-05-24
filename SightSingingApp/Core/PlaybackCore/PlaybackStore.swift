import SwiftUI

/// UI 层唯一的播放状态入口。
///
/// 所有页面通过 `@ObservedObject var playback = PlaybackStore.shared` 订阅播放状态。
///
/// 禁止：页面自己维护播放状态、BPM、进度。
@MainActor
final class PlaybackStore: ObservableObject {

    // MARK: - Singleton

    static let shared = PlaybackStore()

    // MARK: - Published State

    /// 当前播放状态
    @Published var state: PlaybackState = .idle

    /// 当前拍号
    @Published var currentBeat: Double = 0

    /// 当前 BPM
    @Published var bpm: Double = 120

    /// 播放进度 0~1
    @Published var progress: Double = 0

    /// 总拍数
    @Published var totalBeats: Double = 0

    /// 是否正在播放
    var isPlaying: Bool { state.isPlaying }

    /// 是否活跃
    var isActive: Bool { state.isActive }

    // MARK: - Init

    private let engine = PlaybackEngine.shared

    private init() {
        setupEngineCallbacks()
    }

    // MARK: - Setup

    private func setupEngineCallbacks() {
        Task {
            await engine.onStateChange { [weak self] newState in
                Task { @MainActor [weak self] in
                    self?.state = newState
                }
            }
        }
    }

    // MARK: - Convenience API

    /// 准备并播放一段旋律（简化版，供练习页使用）
    func prepareAndPlay(events: [PlaybackEngine.TimedAudioEvent], bpm: Double) {
        self.bpm = bpm
        self.totalBeats = events.map { $0.beat + $0.duration }.max() ?? 0
        self.currentBeat = 0
        self.progress = 0

        Task {
            await engine.prepare(timeline: events, bpm: bpm)
            await engine.play()
        }
    }

    func play() {
        Task { await engine.play() }
    }

    func pause() {
        Task { await engine.pause() }
    }

    func resume() {
        Task { await engine.resume() }
    }

    func stop() {
        Task { await engine.stop() }
    }

    func seek(to beat: Double) {
        Task { await engine.scrub(to: beat) }
    }

    func setBPM(_ newBPM: Double) {
        bpm = newBPM
        Task { await MasterMusicClock.shared.setBPM(newBPM) }
    }
}
