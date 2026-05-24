import Foundation

/// 统一播放引擎 —— 管理整个 App 的播放生命周期。
///
/// 职责：
/// - 将音频事件按时间线调度
/// - 确保音频与动画同步
/// - 全 App 只有一个实例（Singleton）
///
/// 禁止：View/ViewModel 直接管理播放状态、自行创建 Timer 调度音频。
actor PlaybackEngine {

    // MARK: - Singleton

    static let shared = PlaybackEngine()

    // MARK: - Types

    /// 时间线上的一个音频事件
    struct TimedAudioEvent: Sendable, Identifiable {
        let id: UUID
        let beat: Double              // 触发拍号
        let midiNote: Int             // MIDI 音高
        let duration: Double          // 持续拍数
        let velocity: Double          // 力度 0-1
        let isChord: Bool             // 是否和弦（同时触发多个音）
        let chordNotes: [Int]?        // 和弦音列表

        init(
            id: UUID = UUID(),
            beat: Double,
            midiNote: Int,
            duration: Double = 1.0,
            velocity: Double = 0.7,
            isChord: Bool = false,
            chordNotes: [Int]? = nil
        ) {
            self.id = id
            self.beat = beat
            self.midiNote = midiNote
            self.duration = duration
            self.velocity = velocity
            self.isChord = isChord
            self.chordNotes = chordNotes
        }
    }

    /// 播放完成回调
    typealias CompletionHandler = @Sendable () -> Void

    // MARK: - Properties

    let clock = MasterMusicClock.shared

    /// 当前播放状态
    private(set) var state: PlaybackState = .idle

    /// 时间线事件列表
    private var timeline: [TimedAudioEvent] = []

    /// 总拍数
    private var totalBeats: Double = 0

    /// 循环区域
    private var loopRegion: ClosedRange<Double>?

    /// 状态变更回调（给 UI 层）
    private var stateChangeHandler: (@Sendable (PlaybackState) -> Void)?

    /// 事件触发回调（给 AudioCore 调度音频）
    private var eventHandler: (@Sendable (TimedAudioEvent) -> Void)?

    /// 完成回调
    private var completionHandler: CompletionHandler?

    /// 下一个待触发事件的索引
    private var nextEventIndex: Int = 0

    /// 进度观察订阅
    private var progressSubscription: UUID?

    // MARK: - Callback Registration

    func onStateChange(_ handler: @escaping @Sendable (PlaybackState) -> Void) {
        stateChangeHandler = handler
    }

    func onEvent(_ handler: @escaping @Sendable (TimedAudioEvent) -> Void) {
        eventHandler = handler
    }

    func onComplete(_ handler: @escaping CompletionHandler) {
        completionHandler = handler
    }

    // MARK: - Timeline Management

    /// 准备播放时间线
    func prepare(timeline events: [TimedAudioEvent], bpm: Double = 120) async {
        await stop()

        timeline = events.sorted { $0.beat < $1.beat }
        totalBeats = events.map { $0.beat + $0.duration }.max() ?? 0
        nextEventIndex = 0

        await clock.setBPM(bpm)
        await clock.reset()

        await updateState(.preparing)

        // 预加载 buffer（如果有 AudioBufferStore）
        await updateState(.idle)
    }

    /// 准备单音彩排时间线（支持倒计时）
    func prepareCountIn(beats: Int, bpm: Double) async {
        await stop()

        timeline = []
        totalBeats = Double(beats)
        nextEventIndex = 0

        await clock.setBPM(bpm)
        await clock.reset()

        await updateState(.idle)
    }

    // MARK: - Playback Control

    func play() async {
        guard state == .idle || state == .paused || state == .completed else { return }

        if state == .paused {
            await clock.resume()
        } else {
            await clock.reset()
            nextEventIndex = 0
            await clock.start()
        }

        await updateState(.playing)

        // 订阅 clock tick，按时间线触发事件
        await subscribeToClock()
    }

    func pause() async {
        guard state.isActive else { return }
        await clock.pause()
        await updateState(.paused)
    }

    func resume() async {
        guard state == .paused else { return }
        await clock.resume()
        await updateState(.playing)
    }

    func stop() async {
        if let sub = progressSubscription {
            await clock.unsubscribe(sub)
        }
        progressSubscription = nil
        await clock.stop()
        nextEventIndex = 0
        await updateState(.idle)
    }

    /// 设置循环区域
    func setLoop(region: ClosedRange<Double>) async {
        loopRegion = region
        if state == .playing {
            await updateState(.looping(region: region))
        }
    }

    /// 拖动到指定拍位
    func scrub(to beat: Double) async {
        await updateState(.scrubbing)
        await clock.seek(to: beat)

        // 重置事件索引
        nextEventIndex = timeline.firstIndex(where: { $0.beat >= beat }) ?? timeline.count
        await updateState(.paused)
    }

    // MARK: - Private

    private func updateState(_ newState: PlaybackState) {
        state = newState
        let handler = stateChangeHandler
        Task { @MainActor in
            handler?(newState)
        }
    }

    private func subscribeToClock() async {
        // 移除旧的订阅
        if let old = progressSubscription {
            await clock.unsubscribe(old)
        }

        let engine = self
        progressSubscription = await clock.subscribe { [weak engine] tick in
            guard let engine = engine else { return }

            Task { [weak engine] in
                guard let engine = engine else { return }
                await engine.handleTick(tick)
            }
        }
    }

    private func handleTick(_ tick: MasterMusicClock.ClockTick) async {
        // 检查循环
        if let loop = loopRegion, tick.beat > loop.upperBound {
            await clock.seek(to: loop.lowerBound)
            nextEventIndex = timeline.firstIndex(where: { $0.beat >= loop.lowerBound }) ?? 0
            return
        }

        // 触发所有在当前拍号的事件
        while nextEventIndex < timeline.count {
            let event = timeline[nextEventIndex]
            if event.beat <= tick.beat + 0.05 {
                eventHandler?(event)
                nextEventIndex += 1
            } else {
                break
            }
        }

        // 检查是否播放完所有事件
        if nextEventIndex >= timeline.count, totalBeats > 0, tick.beat >= totalBeats {
            await complete()
        }
    }

    private func complete() async {
        if let sub = progressSubscription {
            await clock.unsubscribe(sub)
        }
        progressSubscription = nil
        await clock.stop()
        await updateState(.completed)

        let handler = completionHandler
        Task { @MainActor in
            handler?()
        }
    }
}
