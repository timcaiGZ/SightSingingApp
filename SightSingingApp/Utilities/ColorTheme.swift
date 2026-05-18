import SwiftUI

// MARK: - 颜色主题系统

extension Color {
    /// 从十六进制初始化颜色
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 深色/浅色主题颜色

struct AppColors {
    // 深色模式
    static let darkBackground = Color(hex: "000000")
    static let darkCard = Color(hex: "1C1C1E")
    static let darkSecondaryCard = Color(hex: "2C2C2E")
    static let darkText = Color(hex: "FFFFFF")
    static let darkSecondaryText = Color(hex: "8E8E93")

    // 浅色模式
    static let lightBackground = Color(hex: "F2F2F7")
    static let lightCard = Color(hex: "FFFFFF")
    static let lightSecondaryCard = Color(hex: "F9F9F9")
    static let lightText = Color(hex: "000000")
    static let lightSecondaryText = Color(hex: "8E8E93")

    // 功能色
    static let primary = Color(hex: "007AFF")
    static let success = Color(hex: "34C759")
    static let error = Color(hex: "FF3B30")
    static let warning = Color(hex: "FF9500")
    static let info = Color(hex: "5856D6")

    // 渐变色预设
    static let noteNameGradient = [Color(hex: "4A90E2"), Color(hex: "357ABD")]
    static let intervalGradient = [Color(hex: "50C878"), Color(hex: "2ECC71")]
    static let chordGradient = [Color(hex: "FF6B6B"), Color(hex: "E74C3C")]
    static let scaleGradient = [Color(hex: "9B59B6"), Color(hex: "8E44AD")]
    static let rhythmGradient = [Color(hex: "F39C12"), Color(hex: "E67E22")]
    static let melodyGradient = [Color(hex: "1ABC9C"), Color(hex: "16A085")]
}

// MARK: - 环境感知颜色

/// 环境感知颜色管理器
final class ThemedColors: ObservableObject {
    /// 当前颜色方案
    @Published var colorScheme: ColorScheme = .light

    init() {}

    /// 从环境注入颜色方案
    func inject(from environment: EnvironmentValues) {
        self.colorScheme = environment.colorScheme ?? .light
    }

    var background: Color {
        colorScheme == .dark ? AppColors.darkBackground : AppColors.lightBackground
    }

    var card: Color {
        colorScheme == .dark ? AppColors.darkCard : AppColors.lightCard
    }

    var secondaryCard: Color {
        colorScheme == .dark ? AppColors.darkSecondaryCard : AppColors.lightSecondaryCard
    }

    var primaryText: Color {
        colorScheme == .dark ? AppColors.darkText : AppColors.lightText
    }

    var secondaryText: Color {
        colorScheme == .dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText
    }
}
