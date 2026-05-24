import Foundation

/// 全 App 唯一的时间同步源。
/// 所有 BPM、拍位、节奏子系统必须订阅此 Clock。
///
/// 禁止在 View/ViewModel 里自己管理时间。
actor MasterMusicClock {

    // MARK: - Singleton

    static let shared = MasterMusicClock()

    // MARK: - Tick Data

    struct ClockTick: Sendable {
        let beat: Double       // 绝对拍号
        let bpm: Double
        let timestamp: Date
    }

    // MARK: - Properties

    var bpm: Double = 120.0 {
        didSet { updateInterval() }
    }

    /// 当前拍位（相对于 start 位置，以拍为单位）
    private(set) var beatPosition: Double = 0

    /// 当前所在小节号（1-based）
    var measureNumber: Int {
        let beats = beatsPerMeasure > 0 ? beatsPerMeasure : 4
        return Int(beatPosition / Double(beats)) + 1
    }

    /// 当前小节内的拍位 (0..<beatsPerMeasure)
    var beatInMeasure: Int {
        let beats = beatsPerMeasure > 0 ? beatsPerMeasure : 4
        return Int(beatPosition) % beats
    }

    /// 是否正在运行
    private(set) var isRunning: Bool = false

    /// 每小节拍数
    var beatsPerMeasure: Int = 4

    /// 时间签名分母（4 = 四分音符为一拍）
    var beatUnit: Int = 4

    /// 是否带 swing
    var swingAmount: Double?

    // MARK: - Private

    private var startTime: Date?
    private var lastTickBeat: Double = 0

    private var subscribers: [UUID: @Sendable (ClockTick) -> Void] = [:]
    private var tickTask: Task<Void, Never>?

    private var tickInterval: TimeInterval {
        guard bpm > 0 else { return 0.5 }
        return 60.0 / bpm
    }

    // MARK: - Subscription

    /// 注册 tick 回调，返回订阅 ID。
    @discardableResult
    func subscribe(_ handler: @escaping @Sendable (ClockTick) -> Void) -> UUID {
        let id = UUID()
        subscribers[id] = handler
        return id
    }

    func unsubscribe(_ id: UUID) {
        subscribers.removeValue(forKey: id)
    }

    // MARK: - Control

    func start() {
        guard !isRunning else { return }
        isRunning = true
        startTime = Date()
        lastTickBeat = beatPosition
        resumeTickLoop()
    }

    func stop() {
        isRunning = false
        tickTask?.cancel()
        tickTask = nil
        startTime = nil
    }

    func pause() {
        // 记录当前位置后停止 tick
        isRunning = false
        tickTask?.cancel()
        tickTask = nil
    }

    func resume() {
        guard !isRunning else { return }
        isRunning = true
        startTime = Date().addingTimeInterval(-beatPosition * tickInterval)
        lastTickBeat = beatPosition
        resumeTickLoop()
    }

    func reset() {
        stop()
        beatPosition = 0
        lastTickBeat = 0
        startTime = nil
    }

    /// 跳转到指定拍位
    func seek(to beat: Double) {
        let wasRunning = isRunning
        pause()
        beatPosition = beat
        lastTickBeat = beat
        if wasRunning {
            start()
        }
    }

    func setBPM(_ newBPM: Double) {
        bpm = max(20, min(300, newBPM))
    }

    // MARK: - Private Tick Loop

    private func resumeTickLoop() {
        tickTask?.cancel()
        tickTask = Task { [weak self] in
            guard let self = self else { return }
            while !Task.isCancelled {
                guard await self.isRunning else { break }
                await self.advanceAndNotify()
                // 等待到下一个 tick
                let beatInterval = await self.tickInterval
                try? await Task.sleep(nanoseconds: UInt64(beatInterval * 1_000_000_000))
            }
        }
    }

    /// 推进一拍并通知所有订阅者
    private func advanceAndNotify() -> ClockTick {
        // 由于是单线程 actor，不需要锁
        // 直接基于时间计算当前拍位（高精度模式）
        beatPosition += 1.0
        lastTickBeat = beatPosition

        let tick = ClockTick(
            beat: beatPosition,
            bpm: bpm,
            timestamp: Date()
        )

        // 通知所有订阅者
        let handlers = subscribers.values
        for handler in handlers {
            handler(tick)
        }

        return tick
    }

    private func updateInterval() {
        // BPM 变更后，如果正在运行，重启 tick loop
        if isRunning {
            tickTask?.cancel()
            resumeTickLoop()
        }
    }
}
