import SwiftUI

// MARK: - 节奏型库视图

struct RhythmLibraryView: View {
    @State private var selectedPattern: RhythmPatternData = RhythmPatternLibrary.patterns[0]
    @State private var bpm: Double = 80
    @State private var isPlaying = false
    @State private var currentBeat: Int = 0
    @State private var timer: Timer?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 节奏型列表
                patternList

                // 当前节奏展示
                rhythmDisplay

                // BPM 控制
                bpmControl

                // 技巧提示
                tipCard
            }
            .padding(16)
        }
        .background(AppTheme.background)
        .navigationTitle("节奏型库")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { bpm = Double(selectedPattern.bpm) }
        .onChange(of: selectedPattern) { _, newPattern in
            stopPlaying()
            bpm = Double(newPattern.bpm)
        }
        .onDisappear { stopPlaying() }
    }

    // MARK: - 节奏型列表

    private var patternList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择节奏型")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.secondaryText)

            ForEach(RhythmPatternLibrary.patterns) { pattern in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPattern = pattern
                    }
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(pattern.name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(AppTheme.primaryText)
                            Text("\(pattern.timeSignature) · \(pattern.bpm) BPM")
                                .font(.system(size: 12))
                                .foregroundStyle(AppTheme.tertiaryText)
                        }

                        Spacer()

                        if selectedPattern.id == pattern.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppTheme.accent)
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.tertiaryText.opacity(0.5))
                    }
                    .padding(12)
                    .background(selectedPattern.id == pattern.id ? AppTheme.accent.opacity(0.05) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedPattern.id == pattern.id ? AppTheme.accent.opacity(0.3) : AppTheme.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - 节奏展示

    private var rhythmDisplay: some View {
        VStack(spacing: 16) {
            Text(selectedPattern.name)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(AppTheme.primaryText)

            Text(selectedPattern.description)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)

            // 节拍网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 8), spacing: 8) {
                ForEach(Array(selectedPattern.beats.enumerated()), id: \.element.id) { i, beat in
                    VStack(spacing: 2) {
                        Text(beat.position)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(AppTheme.tertiaryText)

                        Text(beat.symbol)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(beatColor(beat, index: i))
                            .frame(height: 32)
                            .frame(maxWidth: .infinity)
                            .background(
                                currentBeat == i && isPlaying
                                    ? AppTheme.accent.opacity(0.15)
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }

            // 播放按钮
            Button(action: togglePlay) {
                HStack(spacing: 8) {
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    Text(isPlaying ? "停止" : "播放")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isPlaying ? Color.red : AppTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - BPM 控制

    private var bpmControl: some View {
        VStack(spacing: 10) {
            HStack {
                Text("BPM")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)

                Spacer()

                Text("\(Int(bpm))")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(AppTheme.accent)
            }

            Slider(value: $bpm, in: 40...180, step: 1)
                .tint(AppTheme.accent)

            HStack {
                ForEach([60, 80, 100, 120], id: \.self) { preset in
                    Button {
                        bpm = Double(preset)
                    } label: {
                        Text("\(preset)")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(Int(bpm) == preset ? .white : AppTheme.secondaryText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Int(bpm) == preset ? AppTheme.accent : AppTheme.mutedBackground)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - 技巧提示

    private var tipCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .font(.system(size: 16))
                .padding(.top, 2)

            Text(selectedPattern.tip)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(4)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - 辅助方法

    private func beatColor(_ beat: RhythmPatternData.BeatSymbol, index: Int) -> Color {
        switch beat.type {
        case .down: return Color(hex: "C0391A")
        case .up: return Color(hex: "27774A")
        case .mute: return AppTheme.tertiaryText
        case .rest: return AppTheme.border
        case .thumb: return AppTheme.accent
        case .finger: return Color(hex: "7B50B0")
        }
    }

    private func togglePlay() {
        if isPlaying {
            stopPlaying()
        } else {
            startPlaying()
        }
    }

    private func startPlaying() {
        isPlaying = true
        currentBeat = 0
        let interval = 60.0 / bpm / 2.0 // 八分音符间隔
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.05)) {
                currentBeat = (currentBeat + 1) % selectedPattern.beats.count
            }
        }
    }

    private func stopPlaying() {
        isPlaying = false
        currentBeat = 0
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RhythmLibraryView()
    }
}
