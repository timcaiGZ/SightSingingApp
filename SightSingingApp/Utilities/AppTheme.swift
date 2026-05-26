import SwiftUI

// MARK: - 应用主题色配置 (严格匹配 v0.app 原型 - Solfeggio 风格)
enum AppTheme {
    // === 主色系 (iOS蓝 #007AFF) ===
    static let accent = Color(red: 0, green: 0.478, blue: 1.0)  // #007AFF
    static let primary = Color(red: 0, green: 0.478, blue: 1.0)
    
    // === 背景色系 ===
    static let background = Color(hex: "F7F9FC")
    static let cardBackground = Color.white
    static let secondaryBg = Color(hex: "F3F5F8")
    static let mutedBackground = Color(hex: "F1F3F6")
    
    // === 文字色 ===
    static let primaryText = Color(hex: "1A1A2E")
    static let secondaryText = Color(hex: "7C8594")
    static let tertiaryText = Color(hex: "B0B8C4")
    
    // === 功能色 ===
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9F0A")
    static let error = Color(hex: "FF453A")
    
    // === 边框 ===
    static let border = Color(hex: "E5E8EC")
    
    // === Tab Bar 色 ===
    static let tabBarBg = Color.white.opacity(0.95)
    static let tabBarBorder = Color(hex: "E5E8EC")
    static let tabInactive = Color(hex: "7C8594")
    static let tabActive = Color(red: 0, green: 0.478, blue: 1.0)
    
    // === v0 五大练习分类颜色 (严格匹配原型) ===
    enum Category {
        static let pitch = AppTheme.accent              // 音准 - #007AFF iOS蓝
        static let singing = Color(hex: "10B981")       // 唱准 - 绿
        static let rhythm = Color(hex: "F59E0B")        // 节奏 - 琥珀橙
        static let chord = Color(hex: "EC4899")         // 和弦 - 粉红
        static let transcription = Color(hex: "8B5CF6") // 扒谱 - 紫
    }
    
    // === 乐理分类颜色 (匹配小爪完整课程体系) ===
    enum Theory {
        static let brainScience = Color(hex: "06B6D4")  // 大脑科学 - 青
        static let basic = AppTheme.accent               // 基础乐理 - 蓝
        static let notation = AppTheme.success           // 识谱知识 - 绿
        static let interval = Color(hex: "5856D6")       // 音程 - 紫蓝
        static let chord = Color(hex: "EC4899")          // 和弦 - 粉红
        static let mode = Color(hex: "30D158")           // 调式 - 绿
        static let rhythmTheory = Color(hex: "FF9F0A")   // 节奏 - 橙
        static let fretboard = Color(hex: "A855F7")      // 和弦指板 - 紫
        static let progressions = Color(hex: "F43F5E")   // 和弦进行 - 玫红
        static let transposition = Color(hex: "14B8A6")  // 转调实战 - 青绿
        static let accompaniment = Color(hex: "F97316")  // 伴奏思维 - 橙红
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
