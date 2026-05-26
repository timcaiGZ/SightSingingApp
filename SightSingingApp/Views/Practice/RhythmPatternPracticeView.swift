import SwiftUI

// MARK: - 单组节奏练习页面
//
// 展示一组手脚口协调训练，支持 BPM 调节、4 拍倒计时、节拍器音频播放。
// 播放时当前 position 高亮，每拍触发声音 + 触觉反馈。

// MARK: - 练习会话状态

@Observable
final class RhythmPracticeSession {

    enum State: Equatable {
        case idle
        case countingIn(value: Int)  // 4, 3, 2, 1
        case playing(position: Int)   // 1-4 当前激活位置
        case completed
    }

    var state: State = .idle
    var bpm: Double = 60
    var pattern: RhythmPattern?

    private var playbackTask: Task<Void, Never>?

    // MARK: - Start

    func start(with pattern: RhythmPattern) {
        stop()
        self.pattern = pattern

        playbackTask = Task { @MainActor [weak self] in
            guard let self = self else { return }
            let audioEngine = AudioEngineManager.shared
            let haptic = HapticEngine.shared

            // ---- 1. Count-in: 4 → 3 → 2 → 1 ----
            self.state = .countingIn(value: 4)
            let beatDuration = 60.0 / self.bpm

            for i in (1...4).reversed() {
                guard !Task.isCancelled else { return }
                self.state = .countingIn(value: i)

                let accent: AudioEngineManager.MetronomeAccent = (i == 4) ? .strong : .medium
                await audioEngine.playMetronomeClick(accent: accent)

                if i == 4 {
                    haptic.rhythmAccent()
                } else {
                    haptic.grooveLock()
                }

                try? await Task.sleep(nanoseconds: UInt64(beatDuration * 1_000_000_000))
            }

            guard !Task.isCancelled else { return }

            // ---- 2. Playing loop ----
            let subBeat = (60.0 / self.bpm) / 4.0

            while !Task.isCancelled {
                for pos in 1...4 {
                    guard !Task.isCancelled else { return }
                    self.state = .playing(position: pos)

                    let accent: AudioEngineManager.MetronomeAccent = (pos == 1) ? .strong : .medium
                    await audioEngine.playMetronomeClick(accent: accent)

                    if pos == 1 {
                        haptic.grooveLock()
                    }

                    // 使用当前 BPM 动态计算延时
                    let delay = (60.0 / self.bpm) / 4.0
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
    }

    // MARK: - Stop

    func stop() {
        playbackTask?.cancel()
        playbackTask = nil
        state = .idle
        pattern = nil
    }

    // MARK: - Pause / Resume

    func pause() {
        playbackTask?.cancel()
        playbackTask = nil
    }

    /// 从暂停恢复（从 count-in 重新开始）
    func resume(with pattern: RhythmPattern) {
        start(with: pattern)
    }
}

// MARK: - 单组练习视图

struct RhythmPatternPracticeView: View {
    let pattern: RhythmPattern

    @Environment(\.dismiss) private var dismiss

    @State private var session = RhythmPracticeSession()

    private let color = AppTheme.accent
    private let bgColor = AppTheme.background

    // 当前激活的 position（0 = 无）
    private var activePosition: Int {
        if case .playing(let pos) = session.state { return pos }
        return 0
    }

    // 倒计时数字
    private var countInNumber: Int {
        if case .countingIn(let v) = session.state { return v }
        return 0
    }

    private var isPlaying: Bool {
        if case .playing = session.state { return true }
        return false
    }

    private var isCountingIn: Bool {
        if case .countingIn = session.state { return true }
        return false
    }

    private var isIdle: Bool {
        if case .idle = session.state { return true }
        if case .completed = session.state { return true }
        return false
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ScrollView {
                VStack(spacing: 24) {
                    // 标题区
                    titleSection

                    // 时间线网格（放大版）
                    largeTimelineGrid
                        .padding(.horizontal, 20)

                    // BPM 控制
                    bpmControlSection
                        .padding(.horizontal, 20)

                    // 播放按钮
                    playButtonSection
                        .padding(.horizontal, 20)

                    // 提示
                    tipsSection
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .background(bgColor)
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            session.stop()
        }
    }

    // MARK: - 导航栏

    private var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                    Text("返回")
                        .font(.system(size: 15))
                }
                .foregroundStyle(AppTheme.accent)
            }
            Spacer()
            Text(pattern.name)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.primaryText)
            Spacer()
            HStack(spacing: 2) {
                Image(systemName: "chevron.left").font(.system(size: 18)).opacity(0)
                Text("返回").font(.system(size: 15)).opacity(0)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    // MARK: - 标题

    private var titleSection: some View {
        VStack(spacing: 6) {
            Text("唱「哒」在位置：\(pattern.voicePositions.map(String.init).joined(separator: "、"))")
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(.top, 16)
    }

    // MARK: - 时间线网格（素净紧凑版）

    private var largeTimelineGrid: some View {
        VStack(spacing: 0) {
            // 位置编号行
            timelineRow(label: "", height: 32) { pos in
                Text("\(pos)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.tertiaryText)
            }

            Divider().frame(height: 1).opacity(0.15)

            // 脚行
            timelineRow(label: "🦶", height: 36) { pos in
                if pos == 1 {
                    Circle()
                        .fill(AppTheme.tertiaryText)
                        .frame(width: 10, height: 10)
                }
            }

            Divider().frame(height: 1).opacity(0.15)

            // 手行
            timelineRow(label: "🎸", height: 36) { pos in
                if pos == 1 {
                    Text("↑")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }

            Divider().frame(height: 1).opacity(0.15)

            // 唱行
            timelineRow(label: "👄", height: 38) { pos in
                if pattern.voicePositions.contains(pos) {
                    Text("哒")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.primaryText)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
        .overlay(alignment: .center) {
            statusOverlay
        }
    }

    // MARK: - 状态覆盖层

    @ViewBuilder
    private var statusOverlay: some View {
        if isCountingIn {
            ZStack {
                Color.white.opacity(0.92)
                Text("\(countInNumber)")
                    .font(.system(size: 48, weight: .semibold, design: .rounded))
                    .foregroundStyle(color)
                    .scaleEffect(countInNumber > 0 ? 1.0 : 0.8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: countInNumber)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - 网格行

    private func timelineRow(
        label: String,
        height: CGFloat,
        @ViewBuilder cell: @escaping (Int) -> some View
    ) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.tertiaryText)
                .frame(width: 36, alignment: .trailing)
                .padding(.trailing, 8)

            ForEach(1...4, id: \.self) { pos in
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(activePosition == pos ? 0.08 : 0))
                        .padding(2)

                    cell(pos)
                }
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .overlay(alignment: .leading) {
                    if pos > 1 {
                        Rectangle()
                            .fill(AppTheme.border)
                            .frame(width: 0.5)
                    }
                }
            }
        }
    }

    // MARK: - BPM 控制

    private var bpmControlSection: some View {
        VStack(spacing: 12) {
            // BPM 数值显示
            HStack {
                Image(systemName: "metronome")
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                Text("BPM")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Text("\(Int(session.bpm))")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
            }

            // 滑块 + 步进按钮
            HStack(spacing: 12) {
                Button(action: { adjustBPM(-5) }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(color)
                }
                .disabled(isPlaying)

                Slider(value: $session.bpm, in: 20...180, step: 1)
                    .tint(color)
                    .disabled(isPlaying)

                Button(action: { adjustBPM(5) }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(color)
                }
                .disabled(isPlaying)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private func adjustBPM(_ delta: Double) {
        session.bpm = max(20, min(180, session.bpm + delta))
    }

    // MARK: - 播放按钮

    private var playButtonSection: some View {
        VStack(spacing: 10) {
            if isIdle {
                // 开始按钮
                Button(action: {
                    session.start(with: pattern)
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 22))
                        Text("开始练习")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            } else {
                // 停止按钮
                Button(action: {
                    session.stop()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 22))
                        Text("停止")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppTheme.error)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    // MARK: - 提示

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("练习提示")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.primaryText)

            ForEach(tips, id: \.self) { tip in
                HStack(alignment: .top, spacing: 6) {
                    Text("•")
                        .foregroundStyle(AppTheme.secondaryText)
                    Text(tip)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineSpacing(3)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.border, lineWidth: 0.5)
        )
    }

    private let tips: [String] = [
        "脚始终稳定踩在每个四分音符的第 1 个位置。",
        "吉他右手保持连续自然摆动。",
        "唱「哒」严格对齐网格位置。",
        "先慢速再逐步提高 BPM。",
        "感觉同步后可以调到更快的速度。",
    ]
}

#Preview {
    NavigationStack {
        RhythmPatternPracticeView(pattern: RhythmPattern.allQuarters[4])
    }
}
