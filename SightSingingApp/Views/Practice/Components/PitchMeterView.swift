import SwiftUI

// MARK: - 音准指示器视图

/// 音准指示器组件（竖直刻度尺 + 实时游标）
struct PitchMeterView: View {
    let centsDeviation: Double      // 音分偏差 (-50 到 +50)
    let isActive: Bool              // 是否正在检测
    let targetNote: String          // 目标音符
    let octave: Int                 // 目标八度

    init(
        centsDeviation: Double = 0,
        isActive: Bool = false,
        targetNote: String = "C",
        octave: Int = 4
    ) {
        self.centsDeviation = centsDeviation
        self.isActive = isActive
        self.targetNote = targetNote
        self.octave = octave
    }

    private let gaugeWidth: CGFloat = 280
    private let gaugeHeight: CGFloat = 60

    var body: some View {
        VStack(spacing: 12) {
            // 目标音显示
            targetNoteDisplay

            // 刻度尺 + 游标
            gaugeView

            // 音分偏差文字
            deviationText
        }
    }

    /// 目标音显示
    private var targetNoteDisplay: some View {
        HStack(spacing: 8) {
            Text("目标音:")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)

            Text("\(targetNote)\(octave)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.primary)
        }
    }

    /// 刻度尺视图
    private var gaugeView: some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: gaugeWidth, height: gaugeHeight)

            // 刻度标记
            VStack(spacing: 0) {
                // 上半部分（偏高）
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: gaugeWidth, height: gaugeHeight / 2)

                // 下半部分（偏低）
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: gaugeWidth, height: gaugeHeight / 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // 准确区域（中心绿色区）
            RoundedRectangle(cornerRadius: 4)
                .fill(AppTheme.success.opacity(0.2))
                .frame(width: 50, height: gaugeHeight)

            // 中心线
            Rectangle()
                .fill(AppTheme.success)
                .frame(width: 2, height: gaugeHeight + 10)

            // 刻度线
            ForEach(-5..<6, id: \.self) { tick in
                Rectangle()
                    .fill(Color(.systemGray3))
                    .frame(width: 1, height: tick == 0 ? gaugeHeight : gaugeHeight / 2)
                    .offset(x: CGFloat(tick) * (gaugeWidth / 10))
            }

            // 实时游标
            if isActive {
                Circle()
                    .fill(colorForDeviation(centsDeviation))
                    .frame(width: 20, height: 20)
                    .shadow(color: colorForDeviation(centsDeviation).opacity(0.5), radius: 4)
                    .offset(x: offsetForCents(centsDeviation))
                    .animation(.spring(response: 0.15, dampingFraction: 0.7), value: centsDeviation)
            }
        }
    }

    /// 偏差文字显示
    private var deviationText: some View {
        HStack {
            Text("偏低")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)

            Spacer()

            if isActive && abs(centsDeviation) > 0 {
                HStack(spacing: 4) {
                    Image(systemName: iconForDeviation(centsDeviation))
                        .font(.caption)
                    Text("\(Int(abs(centsDeviation))) 音分")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(colorForDeviation(centsDeviation))
            } else {
                Text("— 音分")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()

            Text("偏高")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(width: gaugeWidth)
    }

    /// 根据音分偏差计算偏移量
    private func offsetForCents(_ cents: Double) -> CGFloat {
        let clamped = max(-50, min(50, cents))
        return CGFloat(clamped / 50) * (gaugeWidth / 2 - 15)
    }

    /// 根据偏差返回颜色
    private func colorForDeviation(_ cents: Double) -> Color {
        let absCents = abs(cents)
        if absCents <= 10 {
            return AppTheme.success      // 绿色 - 准确
        } else if absCents <= 25 {
            return Color(hex: "A8D948")   // 浅绿 - 较准
        } else if absCents <= 35 {
            return AppTheme.warning      // 橙色 - 稍偏
        } else {
            return AppTheme.error        // 红色 - 偏差大
        }
    }

    /// 根据偏差返回图标
    private func iconForDeviation(_ cents: Double) -> String {
        if abs(cents) <= 10 {
            return "checkmark.circle.fill"
        } else if cents > 0 {
            return "arrow.up.circle.fill"
        } else {
            return "arrow.down.circle.fill"
        }
    }
}

// MARK: - 水平音准指示器

/// 水平方向的音准指示器（用于视唱练习）
struct HorizontalPitchMeter: View {
    let centsDeviation: Double
    let isActive: Bool

    private let meterWidth: CGFloat = 300
    private let meterHeight: CGFloat = 40

    var body: some View {
        VStack(spacing: 8) {
            // 刻度尺
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray5))
                    .frame(width: meterWidth, height: meterHeight)

                // 准确区域
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.success.opacity(0.2))
                    .frame(width: 40, height: meterHeight)

                // 中心线
                Rectangle()
                    .fill(AppTheme.success)
                    .frame(width: 2, height: meterHeight + 6)

                // 刻度
                ForEach(-3..<4, id: \.self) { tick in
                    Rectangle()
                        .fill(Color(.systemGray3))
                        .frame(width: 1, height: tick == 0 ? meterHeight : meterHeight / 2)
                        .offset(x: CGFloat(tick) * (meterWidth / 6))
                }

                // 游标
                if isActive {
                    Circle()
                        .fill(colorForDeviation(centsDeviation))
                        .frame(width: 20, height: 20)
                        .shadow(color: colorForDeviation(centsDeviation).opacity(0.5), radius: 4)
                        .offset(x: offsetForCents(centsDeviation))
                        .animation(.spring(response: 0.15), value: centsDeviation)
                }
            }

            // 标签
            HStack {
                Text("-25")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                Text("0")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                Text("+25")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .frame(width: meterWidth)
        }
    }

    private func offsetForCents(_ cents: Double) -> CGFloat {
        let clamped = max(-50, min(50, cents))
        return CGFloat(clamped / 50) * (meterWidth / 2 - 12)
    }

    private func colorForDeviation(_ cents: Double) -> Color {
        let absCents = abs(cents)
        if absCents <= 10 { return AppTheme.success }
        else if absCents <= 25 { return Color(hex: "A8D948") }
        else if absCents <= 35 { return AppTheme.warning }
        else { return AppTheme.error }
    }
}

// MARK: - 预览

#Preview {
    VStack(spacing: 30) {
        // 标准音准指示器
        VStack(spacing: 20) {
            Text("音准指示器")
                .font(.headline)

            PitchMeterView(
                centsDeviation: -15,
                isActive: true,
                targetNote: "C",
                octave: 4
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))

        // 水平音准指示器
        VStack(spacing: 20) {
            Text("水平音准指示器")
                .font(.headline)

            HorizontalPitchMeter(centsDeviation: 8, isActive: true)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))

        // 不同偏差状态
        VStack(spacing: 16) {
            ForEach([0, 15, 30, 45], id: \.self) { cents in
                HStack {
                    Text("\(cents) 音分")
                        .font(.caption)
                        .frame(width: 60)
                    PitchMeterView(centsDeviation: Double(cents), isActive: true)
                }
            }
        }
        .padding()
    }
    .padding()
}
