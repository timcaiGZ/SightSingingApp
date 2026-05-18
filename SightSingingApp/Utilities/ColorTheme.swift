import SwiftUI

// MARK: - iOS 原生色板（简化版）

/// iOS 系统色
struct AppColors {
    // MARK: 功能色
    static let primary = Color(hex: "007AFF")     // iOS 蓝
    static let success = Color(hex: "34C759")     // iOS 绿
    static let warning = Color(hex: "FF9500")     // iOS 橙
    static let error = Color(hex: "FF3B30")       // iOS 红
    static let info = Color(hex: "5856D6")        // iOS 紫

    // MARK: 背景色
    static let background = Color(.systemBackground)       // 纯白 / 深色
    static let groupedBackground = Color(.systemGroupedBackground) // 系统灰背景
    static let secondaryBackground = Color(.secondarySystemGroupedBackground)

    // MARK: 文字色
    static let primaryText = Color(.label)         // 主文字
    static let secondaryText = Color(.secondaryLabel) // 次要文字
    static let tertiaryText = Color(.tertiaryLabel)   // 占位符文字

    // MARK: 分隔线
    static let separator = Color(.separator)
    static let opaqueSeparator = Color(.opaqueSeparator)

    // MARK: 吉他模块颜色（用于图表和标识）
    static let noteName = Color(hex: "007AFF")     // 蓝色
    static let interval = Color(hex: "34C759")      // 绿色
    static let chord = Color(hex: "FF3B30")        // 红色
    static let scale = Color(hex: "5856D6")        // 紫色
    static let rhythm = Color(hex: "FF9500")       // 橙色
    static let melody = Color(hex: "00C7BE")       // 青色
}

// MARK: - Color 扩展

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

// MARK: - View 扩展

extension View {
    /// 应用 iOS 原生卡片样式
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 应用分组列表背景
    func groupedBackground() -> some View {
        self.background(Color(.systemGroupedBackground))
    }
}
