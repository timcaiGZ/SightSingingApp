import SwiftUI

// MARK: - 十六分音符手脚口协调节奏训练主列表
//
// 5 组训练，每组展示时间线网格（16 个位置）

struct SixteenthRhythmPracticeView: View {
    let exercise: ExerciseItem
    let moduleId: String

    @Environment(\.dismiss) private var dismiss
    @State private var selectedPattern: SixteenthRhythmPattern?

    private let patterns: [SixteenthRhythmPattern] = SixteenthRhythmPattern.allPatterns

    private let sectionColor = AppTheme.accent

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            navBar
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    legendSection
                    ForEach(Array(patterns.enumerated()), id: \.element.id) { idx, pattern in
                        patternCardView(idx: idx, pattern: pattern)
                    }
                    tipsSection
                    footerSection
                }
                .padding(.bottom, 40)
            }
        }
        .background(AppTheme.background)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $selectedPattern) { pattern in
            SixteenthRhythmPatternPracticeView(pattern: pattern)
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
            Text("十六分音符节奏训练")
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

    // MARK: - 头部

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("十六分音符手脚口协调节奏训练")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppTheme.primaryText)
                .padding(.horizontal, 16)

            Text("4/4 拍 | 每拍 4 个位置 | 共 16 位置")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.horizontal, 16)
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - 图例

    private var legendSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 10) {
            legendCard(icon: "🦶", title: "脚", desc: "踩在 1、5、9、13（每拍第 1 位）")
            legendCard(icon: "🎸", title: "吉他", desc: "固定扫弦 ↓ ↓↑↓ ↓↑↓ ↓↑↓")
            legendCard(icon: "👄", title: "唱", desc: "「哒」按每组指定位置")
            legendCard(icon: "🎵", title: "BPM", desc: "20 ~ 180，建议从 40 开始慢练")
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
    }

    private func legendCard(icon: String, title: String, desc: String) -> some View {
        HStack(spacing: 10) {
            Text(icon)
                .font(.system(size: 22))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Text(desc)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(3)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    // MARK: - 训练卡片

    private func patternCardView(idx: Int, pattern: SixteenthRhythmPattern) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // 卡片头部：序号 + 标题
            if idx == 0 {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(sectionColor)
                            .frame(width: 44, height: 44)
                        Text("1")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("5 种唱「哒」训练")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryText)
                        Text("脚不动 + 手正确节奏")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 14)
            }

            // 训练卡片
            Button(action: { selectedPattern = pattern }) {
                VStack(spacing: 0) {
                    Text(pattern.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryText)
                        .padding(.bottom, 12)

                    timelineGrid(pattern: pattern)
                }
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 14)
        }
        .padding(.bottom, 10)
        .padding(.top, idx == 0 ? 0 : 10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .padding(.horizontal, 14)
        .padding(.bottom, 12)
    }

    // MARK: - 时间线网格（16 位置）

    private func timelineGrid(pattern: SixteenthRhythmPattern) -> some View {
        VStack(spacing: 0) {
            // 顶部：位置编号 + 拍号标记
            HStack(spacing: 0) {
                Rectangle().fill(.clear).frame(width: 38, height: 28)
                    .padding(.trailing, 6)
                ForEach(1...16, id: \.self) { pos in
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
                            .font(.system(size: posNum == 1 ? 12 : 10, weight: .medium))
                            .foregroundStyle(AppTheme.tertiaryText)
                            .opacity(posNum == 1 ? 1.0 : 0.55)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
                }
            }

            Divider().frame(height: 1).opacity(0.15)

            // 脚行
            timelineRow(label: "🦶 脚", height: 28) { pos in
                if [1, 5, 9, 13].contains(pos) {
                    Circle()
                        .fill(AppTheme.tertiaryText)
                        .frame(width: 7, height: 7)
                }
            }

            Divider().frame(height: 1).opacity(0.15)

            // 手行
            timelineRow(label: "🎸 手", height: 28) { pos in
                let dir = SixteenthHandStrum.direction(at: pos)
                if dir != .rest {
                    Text(dir.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }

            Divider().frame(height: 1).opacity(0.15)

            // 唱行
            timelineRow(label: "👄 唱", height: 28) { pos in
                if pattern.voicePositions.contains(pos) {
                    Text("哒")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(AppTheme.primaryText)
                }
            }
        }
    }

    private func timelineRow(
        label: String,
        height: CGFloat,
        @ViewBuilder cellContent: @escaping (Int) -> some View
    ) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.tertiaryText)
                .frame(width: 38, alignment: .trailing)
                .padding(.trailing, 6)

            ForEach(1...16, id: \.self) { pos in
                ZStack(alignment: .center) {
                    cellContent(pos)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .leading) {
                    if pos > 1 {
                        Rectangle()
                            .fill(AppTheme.tertiaryText.opacity(0.2))
                            .frame(width: 1)
                    }
                }
            }
        }
        .frame(height: height)
    }

    // MARK: - 训练要点

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("训练要点")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.primaryText)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                        Text(tip)
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                            .lineSpacing(3)
                    }
                }
            }
        }
        .padding(16)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 12)
    }

    private let tips: [String] = [
        "脚：稳定踩在 1、5、9、13（每拍第 1 位），不要漂移。",
        "手：保持 ↓ ↓↑↓ ↓↑↓ ↓↑↓ 节奏，均匀连续摆动。",
        "嘴：唱「哒」的位置严格对齐十六分音符网格。",
        "先慢速（BPM 40~60），逐步对齐后再提速。",
        "最终目标：脚、手、嘴共享同一个内部拍点。",
    ]

    // MARK: - 页脚

    private var footerSection: some View {
        Text("4/4 拍十六分音符手脚口协调训练，每组包含 16 个位置（每拍 4 个十六分音符 × 4 拍）。建议搭配节拍器练习，先建立稳定拍点，再逐步提高速度与协调能力。")
            .font(.system(size: 13))
            .foregroundStyle(AppTheme.secondaryText)
            .lineSpacing(4)
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .padding(.horizontal, 14)
    }
}

#Preview {
    NavigationStack {
        SixteenthRhythmPracticeView(
            exercise: ExerciseItem(
                id: "sixteenth",
                title: "十六分音符节奏",
                mode: .keyboardInput,
                percentage: 60
            ),
            moduleId: "rhythm"
        )
    }
}
