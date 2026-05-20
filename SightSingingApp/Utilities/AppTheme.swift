import SwiftUI

// MARK: - 应用主题色配置 (匹配 v0 原型 - Solfeggio 风格 iOS 蓝 #007AFF)
enum AppTheme {
    // === 主色系 (iOS蓝) ===
    /// 主色调 / 强调色 - iOS Blue #007AFF
    static let accent = Color(red: 0, green: 0.478, blue: 1.0)
    static let primary = Color(red: 0, green: 0.478, blue: 1.0)
    
    // === 背景色系 (接近白色，略带蓝调) ===
    static let background = Color(hex: "F7F9FC")       // oklch(0.97 0.002 250)
    static let cardBackground = Color.white
    static let secondaryBg = Color(hex: "F3F5F8")      // oklch(0.96 0.005 250)
    static let mutedBackground = Color(hex: "F1F3F6")   // oklch(0.95 0.005 250)
    
    // === 文字色 ===
    static let primaryText = Color(hex: "1A1A2E")      // oklch(0.15 0.02 250)
    static let secondaryText = Color(hex: "7C8594")     // oklch(0.5 0.02 250)
    static let tertiaryText = Color(hex: "B0B8C4")      // 淡化文字
    
    // === 功能色 ===
    static let success = Color(hex: "34C759")           // oklch(0.68 0.2 145)
    static let warning = Color(hex: "FF9F0A")           // oklch(0.78 0.16 75)
    static let error = Color(hex: "FF453A")
    
    // === 边框 ===
    static let border = Color(hex: "E5E8EC")            // oklch(0.9 0.005 250)
    
    // === Tab Bar 色 ===
    static let tabBarBg = Color.white.opacity(0.95)
    static let tabBarBorder = Color(hex: "E5E8EC")
    static let tabInactive = Color(hex: "7C8594")
    static let tabActive = Color(red: 0, green: 0.478, blue: 1.0)
    
    // === 模块颜色标识 (Solfeggio风格) ===
    enum Module {
        static let pitch = Color(hex: "007AFF")        // 听力/音高 - iOS蓝
        static let interval = Color(hex: "5856D6")      // 音程 - 紫蓝 oklch(0.6 0.2 290)
        static let chord = Color(hex: "FF2D55")         // 和弦 - 红粉 oklch(0.65 0.2 0)
        static let scale = Color(hex: "30D158")         // 调式 - 绿 oklch(0.68 0.15 170)
        static let rhythm = Color(hex: "FF9F0A")        // 节奏 - 橙 oklch(0.78 0.16 75)
        static let melody = Color(hex: "34C759")        // 旋律 - 绿 oklch(0.68 0.2 145)
    }
}

// MARK: - 进度环颜色
enum ProgressColor {
    static func ringColor(percentage: Int) -> Color {
        if percentage >= 80 { return AppTheme.success }
        else if percentage >= 50 { return AppTheme.accent }
        else if percentage > 0 { return AppTheme.warning }
        else { return AppTheme.tertiaryText.opacity(0.3) }
    }
}
