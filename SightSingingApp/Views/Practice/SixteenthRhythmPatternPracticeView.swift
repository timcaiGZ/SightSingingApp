import SwiftUI

// MARK: - 十六分音符单组练习页面
//
// 展示一组十六分音符手脚口协调训练，支持 BPM 调节、4 拍倒计时、节拍器音频播放。
// 播放时当前 position 高亮，每拍触发声音 + 触觉反馈。

// MARK: - 十六分音符练习会话状态

@Observable
final class SixteenthPracticeSession {

    enum State: Equatable {
        case idle
        case countingIn(value: Int)  // 4, 3, 2, 1
        case playing(position: Int)   // 1-16 当前激活位置
        case completed
    }

    var state: State = .idle
    var bpm: Double = 60
    var pattern: SixteenthRhythmPattern?

    private var playbackTask: Task<Void, Never>?

    // MARK: - Start

    func start(with pattern: SixteenthRhythmPattern) {
        stop()
        self.pattern = pattern

        playbackTask = Task { @MainActor [weak self] in
            guard let self = self else { return }
            let audioEngine = AudioEngineManager.shared
            let haptic = HapticEngine.shared

            // ---- 1. Count-in: 4 → 3 → 2 → 1 ----
            let beatDuration = 60.0 / self.bpm

            for i in (1...4).reversed() {
                guard !Task.isCancelled else { return }
                self.state = .countingIn(value: i)

                // 倒计时第 1 拍（i==4）用重音
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

            // ---- 2. Playing loop (16 positions per measure) ----
            let subBeat = (60.0 / self.bpm) / 4.0

            while !Task.isCancelled {
                for pos in 1...16 {
                    guard !Task.isCancelled else { return }
                    self.state = .playing(position: pos)

                    let isBeatOne = [1, 5, 9, 13].contains(pos)
                    let accent: AudioEngineManager.MetronomeAccent
                    if pos == 1 {
                        accent = .strong
                    } else if isBeatOne {
                        accent = .medium
                    } else {
                        accent = .weak
                    }
                    await audioEngine.playMetronomeClick(accent: accent)

                    if isBeatOne {
                        haptic.grooveLock()
                    }

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

    func resume(with pattern: SixteenthRhythmPattern) {
        start(with: pattern)
    }
}

// MARK: - 单组练习视图

struct SixteenthRhythmPatternPracticeView: View {
    let pattern: SixteenthRhythmPattern

    @Environment(\.dismiss) private var dismiss

    @State private var session = SixteenthPracticeSession()

    private let color = AppTheme.accent
    private let bgColor = AppTheme.background

    private var activePosition: Int {
        if case .playing(let pos) = session.state { return pos }
        return 0
    }

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
                    titleSection

                    largeTimelineGrid
                        .padding(.horizontal, 16)

                    bpmControlSection
                        .padding(.horizontal, 16)

                    playButtonSection
                        .padding(.horizontal, 16)

                    tipsSection
                        .padding(.horizontal, 16)
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
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.primaryText)
                .lineLimit(1)
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
            Text("👉 唱「哒」在位置：\(pattern.voicePositions.map { "\($0)" }.joined(separator: "、"))")
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.top, 16)
        }
    }

    // MARK: - 时间线网格（素净紧凑版，16 位置）

    private var largeTimelineGrid: some View {
        VStack(spacing: 0) {
            // 位置编号行
            timelineRow(label: "", height: 28) { pos in
                VStack(spacing: 0) {
                    if [1, 5, 9, 13].contains(pos) {
                        Text("拍\((pos + 3) / 4)")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(AppTheme.tertiaryText)
                    } else {
                        Color.clear.frame(height: 10)
                    }
                    let posNum = (pos - 1) % 4 + 1
                    Text("\(posNum)")
                        .font(.system(size: posNum == 1 ? 13 : 11, weight: .medium))
                        .foregroundStyle(AppTheme.tertiaryText)
                        .opacity(posNum == 1 ? 1.0 : 0.6)
                }
            }

            Divider().frame(height: 1).opacity(0.15)

            // 脚行
            timelineRow(label: "🦶", height: 30) { pos in
                if [1, 5, 9, 13].contains(pos) {
                    Circle()
                        .fill(AppTheme.tertiaryText)
                        .frame(width: 8, height: 8)
                }
            }

            Divider().frame(height: 1).opacity(0.15)

            // 手行
            timelineRow(label: "🎸", height: 30) { pos in
                let dir = SixteenthHandStrum.direction(at: pos)
                if dir != .rest {
                    Text(dir.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }

            Divider().frame(height: 1).opacity(0.15)

            // 唱行
            timelineRow(label: "👄", height: 32) { pos in
                if pattern.voicePositions.contains(pos) {
                    Text("哒")
                        .font(.system(size: 11, weight: .medium))
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
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.tertiaryText)
                .frame(width: 32, alignment: .trailing)
                .padding(.trailing, 4)

            ForEach(1...16, id: \.self) { pos in
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.opacity(activePosition == pos ? 0.08 : 0))
                        .padding(1)

                    cell(pos)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .leading) {
                    if pos > 1 {
                        Rectangle()
                            .fill(AppTheme.border)
                            .frame(width: 0.5)
                    }
                }
            }
        }
        .frame(height: height)
    }

    // MARK: - BPM 控制

    private var bpmControlSection: some View {
        VStack(spacing: 12) {
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
        "脚稳定踩在 1、5、9、13（每拍第 1 位）。",
        "吉他右手保持 ↓ ↓↑↓ ↓↑↓ ↓↑↓ 节奏。",
        "唱「哒」严格对齐十六分音符网格。",
        "先慢速（BPM 50~60）再逐步提速。",
        "感觉同步后可以调高速度挑战。",
    ]
}

#Preview {
    NavigationStack {
        SixteenthRhythmPatternPracticeView(pattern: SixteenthRhythmPattern.allPatterns[2])
    }
}
