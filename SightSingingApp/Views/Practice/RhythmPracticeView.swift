import SwiftUI

// MARK: - 节奏练习视图
//
// 基于《刁Sir吉他扫弦干货铺》教材中的15组四分节奏练习。
//
// 核心交互：
//   1. 左右切换15组练习
//   2. 节奏谱实时展示：脚(👣) / 手(↓↑) / 嘴(嗒)
//   3. 节拍器按十六分音符粒度tick，对齐每个动作
//
struct RhythmPracticeView: View {
    let exercise: ExerciseItem
    let moduleId: String

    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    /// 当前选中的练习组（0~14）
    @State private var currentPatternIndex: Int = 0

    /// 节拍器状态
    @State private var isPlaying = false
    @State private var isCountIn = false
    @State private var countInBeat: Int = 0
    @State private var countInTick: Int = 0
    @State private var currentTick: Int = 0   // 0~15，对应小节内16个十六分格

    /// 速度
    @State private var bpm: Double = 60

    /// 拍点记录（用户点击屏幕的反馈）
    @State private var tappedBeats: [TapRecord] = []

    struct TapRecord: Identifiable {
        let id = UUID()
        let beat: Double
        let accuracy: Int
    }

    /// 节拍器定时器
    @State private var tickTimer: Timer?

    // MARK: - Colors

    private let accent = AppTheme.accent
    private let rhythmAccent = AppTheme.Category.rhythm
    private let bg = AppTheme.background
    private let cardBg = AppTheme.cardBackground
    private let primaryText = AppTheme.primaryText
    private let secondaryText = AppTheme.secondaryText
    private let tertiaryText = AppTheme.tertiaryText
    private let border = AppTheme.border

    // MARK: - Computed

    private var currentPattern: RhythmPattern {
        RhythmPattern.allQuarters[currentPatternIndex]
    }

    private var totalPatterns: Int {
        RhythmPattern.allQuarters.count
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ScrollView {
                VStack(spacing: 16) {
                    // 练习组选择器
                    patternSelector

                    // 节奏谱卡片
                    rhythmCard

                    // 当前练习说明
                    patternDescriptionCard

                    // 节拍脉冲条
                    if isPlaying || isCountIn {
                        beatPulseBar
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    Spacer(minLength: 120)
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)
            }

            // 底部节拍器控制栏
            metronomeControlBar
        }
        .background(bg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            stopMetronome()
        }
        .animation(.easeInOut(duration: 0.25), value: isPlaying)
        .animation(.easeInOut(duration: 0.25), value: isCountIn)
        .animation(.easeInOut(duration: 0.2), value: currentPatternIndex)
    }

    // MARK: - Navigation Bar

    private var navBar: some View {
        HStack(spacing: 0) {
            Button(action: { dismiss() }) {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                    Text("返回")
                        .font(.system(size: 17))
                }
                .foregroundStyle(accent)
            }
            .buttonStyle(.plain)

            Spacer()

            Text(exercise.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(primaryText)

            Spacer()

            Color.clear.frame(width: 54, height: 44)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial)
        .overlay(Rectangle().fill(border).frame(height: 0.5), alignment: .bottom)
    }

    // MARK: - Pattern Selector

    private var patternSelector: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                // 上一组
                Button(action: previousPattern) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(currentPatternIndex > 0 ? accent : tertiaryText.opacity(0.3))
                }
                .buttonStyle(.plain)
                .disabled(currentPatternIndex == 0 || isPlaying || isCountIn)

                Spacer()

                // 当前组信息
                VStack(spacing: 4) {
                    Text("第 \(currentPattern.id) / \(totalPatterns) 组")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(secondaryText)

                    Text(currentPattern.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(primaryText)
                }

                Spacer()

                // 下一组
                Button(action: nextPattern) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(currentPatternIndex < totalPatterns - 1 ? accent : tertiaryText.opacity(0.3))
                }
                .buttonStyle(.plain)
                .disabled(currentPatternIndex == totalPatterns - 1 || isPlaying || isCountIn)
            }

            // 进度指示器
            HStack(spacing: 4) {
                ForEach(0..<totalPatterns, id: \.self) { idx in
                    Circle()
                        .fill(idx == currentPatternIndex ? accent : tertiaryText.opacity(0.15))
                        .frame(width: idx == currentPatternIndex ? 8 : 5, height: idx == currentPatternIndex ? 8 : 5)
                        .animation(.spring(response: 0.3), value: currentPatternIndex)
                }
            }
        }
        .padding(16)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
    }

    private func previousPattern() {
        guard currentPatternIndex > 0 else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            currentPatternIndex -= 1
            bpm = Double(currentPattern.recommendedBPM)
            resetPractice()
        }
    }

    private func nextPattern() {
        guard currentPatternIndex < totalPatterns - 1 else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            currentPatternIndex += 1
            bpm = Double(currentPattern.recommendedBPM)
            resetPractice()
        }
    }

    // MARK: - Rhythm Card

    private var rhythmCard: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "music.note.list")
                    .font(.system(size: 14))
                    .foregroundStyle(rhythmAccent)
                Text("节奏谱")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(primaryText)
                Spacer()
                Text("4/4 拍")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(tertiaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.mutedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            Divider().overlay(border)

            // 4拍节奏谱
            HStack(spacing: 0) {
                ForEach(0..<4) { beat in
                    beatColumn(beat: beat)
                    if beat < 3 {
                        Divider()
                            .overlay(border.opacity(0.3))
                            .padding(.vertical, 8)
                    }
                }
            }
            .frame(minHeight: 140)

            // 小节线装饰
            HStack(spacing: 0) {
                Rectangle().fill(border.opacity(0.2)).frame(height: 1)
                Text("𝄞")
                    .font(.system(size: 14))
                    .foregroundStyle(tertiaryText.opacity(0.4))
                    .padding(.horizontal, 8)
                Rectangle().fill(border.opacity(0.2)).frame(height: 1)
            }
        }
        .padding(16)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
    }

    private func beatColumn(beat: Int) -> some View {
        let start = beat * 4
        let end = start + 4
        let beatSlots = Array(currentPattern.slots[start..<end])

        let isBeatActive = (isPlaying || isCountIn) && (currentTick >= start && currentTick < end)

        // 提取该拍事件
        let strumEvents = beatSlots.enumerated().compactMap { idx, slot -> (offset: Int, dir: StrumDirection)? in
            slot.strum != .rest ? (idx, slot.strum) : nil
        }
        let vocalOffsets = beatSlots.enumerated().compactMap { idx, slot -> Int? in
            slot.vocal ? idx : nil
        }
        let hasFoot = beatSlots.first?.foot ?? false
        let hasAnyEvent = hasFoot || !strumEvents.isEmpty || !vocalOffsets.isEmpty

        return VStack(spacing: 10) {
            // 拍号
            Text("\(beat + 1)")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(isBeatActive ? accent : tertiaryText)
                .frame(height: 22)

            // 脚
            if hasFoot {
                let footActive = isPlaying && currentTick == start && beatSlots[0].foot
                Image(systemName: "shoeprints.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(footActive ? accent : tertiaryText.opacity(0.4))
                    .frame(height: 18)
            } else {
                Color.clear.frame(height: 18)
            }

            // 扫弦方向
            HStack(spacing: 3) {
                if strumEvents.isEmpty {
                    Text("−")
                        .font(.system(size: 16))
                        .foregroundStyle(tertiaryText.opacity(0.2))
                } else {
                    ForEach(Array(strumEvents.enumerated()), id: \.offset) { _, event in
                        let globalTick = start + event.offset
                        let isActive = isPlaying && currentTick == globalTick
                        Text(event.dir.rawValue)
                            .font(.system(size: isActive ? 24 : 20, weight: isActive ? .bold : .regular))
                            .foregroundStyle(isActive ? accent : primaryText.opacity(0.75))
                            .scaleEffect(isActive ? 1.15 : 1.0)
                            .animation(.spring(response: 0.15, dampingFraction: 0.5), value: currentTick)
                    }
                }
            }
            .frame(minHeight: 28)

            // 唱谱「嗒」
            HStack(spacing: 1) {
                if vocalOffsets.isEmpty {
                    Text("·")
                        .font(.system(size: 12))
                        .foregroundStyle(tertiaryText.opacity(0.15))
                } else {
                    ForEach(Array(vocalOffsets.enumerated()), id: \.offset) { _, offset in
                        let globalTick = start + offset
                        let isActive = isPlaying && currentTick == globalTick
                        Text("嗒")
                            .font(.system(size: isActive ? 13 : 11, weight: isActive ? .bold : .medium))
                            .foregroundStyle(isActive ? rhythmAccent : secondaryText.opacity(0.55))
                            .scaleEffect(isActive ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: currentTick)
                    }
                }
            }
            .frame(minHeight: 20)

            // 休止提示
            if !hasAnyEvent {
                Text("休止")
                    .font(.system(size: 10))
                    .foregroundStyle(tertiaryText.opacity(0.25))
                    .frame(height: 14)
            } else {
                Color.clear.frame(height: 14)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(isBeatActive ? accent.opacity(0.06) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .animation(.easeInOut(duration: 0.15), value: currentTick)
    }

    // MARK: - Pattern Description

    private var patternDescriptionCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("练习要点")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(rhythmAccent)
                Text(currentPattern.description)
                    .font(.system(size: 13))
                    .foregroundStyle(secondaryText)
                    .lineLimit(2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("推荐速度")
                    .font(.system(size: 11))
                    .foregroundStyle(tertiaryText)
                Text("\(currentPattern.recommendedBPM) BPM")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(primaryText)
            }
        }
        .padding(14)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
    }

    // MARK: - Beat Pulse Bar

    private var beatPulseBar: some View {
        let beat = currentTick / 4
        return HStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { b in
                Rectangle()
                    .fill(b == beat ? accent : accent.opacity(0.1))
                    .frame(height: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .animation(.easeInOut(duration: 0.15), value: currentTick)

                if b < 3 {
                    Spacer().frame(width: 4)
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Metronome Control Bar

    private var metronomeControlBar: some View {
        VStack(spacing: 0) {
            Rectangle().fill(border).frame(height: 0.5)

            HStack(spacing: 16) {
                // BPM −
                Button(action: { adjustBPM(-5) }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(secondaryText)
                }
                .buttonStyle(.plain)
                .disabled(isPlaying || isCountIn)

                // BPM Display
                VStack(spacing: 0) {
                    Text("\(Int(bpm))")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryText)
                    Text("BPM")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(tertiaryText)
                }
                .frame(width: 64)

                // BPM +
                Button(action: { adjustBPM(5) }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(secondaryText)
                }
                .buttonStyle(.plain)
                .disabled(isPlaying || isCountIn)

                Spacer()

                // 练习组缩略提示
                HStack(spacing: 4) {
                    Text("\(currentPattern.id)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(rhythmAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text(currentPattern.name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(secondaryText)
                        .lineLimit(1)
                }

                Spacer()

                // Play / Stop
                Button(action: {
                    if isPlaying || isCountIn {
                        stopMetronome()
                    } else {
                        startMetronome()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(isPlaying ? AppTheme.error : accent)
                            .frame(width: 56, height: 56)
                            .shadow(color: (isPlaying ? AppTheme.error : accent).opacity(0.3), radius: 10)

                        if isCountIn {
                            Text("\(countInBeat)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        } else {
                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.white)
                                .offset(x: isPlaying ? 0 : 1)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial)
        }
    }

    // MARK: - Metronome Logic

    private func startMetronome() {
        resetPractice()
        isCountIn = true
        countInBeat = 0
        countInTick = 0

        let interval = 60.0 / bpm / 4.0  // 十六分音符间隔

        tickTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            if isCountIn {
                // Count-in：每4个tick（每拍）数一下
                if countInTick % 4 == 0 {
                    countInBeat += 1
                    HapticEngine.shared.grooveLock()
                    Task {
                        await AudioEngineManager.shared.playMIDI(76, duration: 0.1, stopPrevious: false)
                    }
                }
                countInTick += 1

                if countInBeat >= 4 {
                    // Count-in 结束，开始正式演奏
                    isCountIn = false
                    isPlaying = true
                    currentTick = 0
                }
            } else if isPlaying {
                let slot = currentPattern.slots[currentTick]

                // Foot：强拍触觉 + 强音
                if slot.foot {
                    HapticEngine.shared.grooveLock()
                    Task {
                        await AudioEngineManager.shared.playMIDI(72, duration: 0.08, stopPrevious: false)
                    }
                }
                // Strum / Vocal：弱拍触觉 + 弱音
                else if slot.strum != .rest || slot.vocal {
                    HapticEngine.shared.rhythmAccent()
                    Task {
                        await AudioEngineManager.shared.playMIDI(60, duration: 0.05, stopPrevious: false)
                    }
                }

                currentTick = (currentTick + 1) % 16
            }
        }

        RunLoop.main.add(tickTimer!, forMode: .common)
    }

    private func stopMetronome() {
        tickTimer?.invalidate()
        tickTimer = nil
        isPlaying = false
        isCountIn = false
        countInBeat = 0
        countInTick = 0
        currentTick = 0

        Task { await AudioEngineManager.shared.stop() }
    }

    private func adjustBPM(_ delta: Double) {
        bpm = max(40, min(200, bpm + delta))
    }

    private func resetPractice() {
        stopMetronome()
        tappedBeats.removeAll()
    }
}

// MARK: - Preview

#Preview {
    RhythmPracticeView(
        exercise: ExerciseItem(
            id: "preview",
            title: "节奏练习",
            mode: .multipleChoice,
            percentage: 0
        ),
        moduleId: "preview"
    )
}
