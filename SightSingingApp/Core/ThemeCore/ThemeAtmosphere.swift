import SwiftUI

// MARK: - Atmosphere Extension for AppTheme

extension AppTheme {

    // MARK: - Atmosphere System

    enum Atmosphere {

        // MARK: - Glow

        /// 根据准确度计算发光强度 (0.0 ~ 1.0)
        static func glowIntensity(for accuracy: Double) -> Double {
            // 使用非线性映射：低准确度时几乎无发光，高准确度时发光明显
            let clamped = max(0, min(1, accuracy))
            return pow(clamped, 2.5)
        }

        /// 根据准确度返回发光颜色
        static func glowColor(for accuracy: Double) -> Color {
            let intensity = glowIntensity(for: accuracy)
            if accuracy >= 0.9 {
                return .green.opacity(intensity)
            } else if accuracy >= 0.7 {
                return .yellow.opacity(intensity)
            } else if accuracy >= 0.5 {
                return .orange.opacity(intensity * 0.6)
            } else {
                return .red.opacity(intensity * 0.3)
            }
        }

        // MARK: - Shadow

        static let cardShadow = Shadow(
            color: .black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 2
        )

        static let elevatedShadow = Shadow(
            color: .black.opacity(0.12),
            radius: 16,
            x: 0,
            y: 4
        )

        static let floatingShadow = Shadow(
            color: .black.opacity(0.16),
            radius: 24,
            x: 0,
            y: 8
        )

        // MARK: - Ambient Blur

        /// 根据层级返回模糊值
        /// level 0 = 无模糊, 1 = 轻微, 2 = 中度, 3 = 强模糊
        static func ambientBlur(level: Int) -> CGFloat {
            switch level {
            case 0: return 0
            case 1: return 4
            case 2: return 10
            case 3: return 20
            default: return max(0, CGFloat(level) * 5)
            }
        }
    }

    // MARK: - Shadow

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - View Extensions

extension View {

    /// 应用氛围阴影
    func atmosphereShadow(_ shadow: AppTheme.Shadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }

    /// 应用氛围模糊
    func atmosphereBlur(level: Int) -> some View {
        self.blur(radius: AppTheme.Atmosphere.ambientBlur(level: level))
    }

    /// 准确度发光效果
    func accuracyGlow(accuracy: Double) -> some View {
        self.shadow(
            color: AppTheme.Atmosphere.glowColor(for: accuracy),
            radius: AppTheme.Atmosphere.glowIntensity(for: accuracy) * 30
        )
    }
}
