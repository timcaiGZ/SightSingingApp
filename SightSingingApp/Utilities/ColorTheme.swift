import SwiftUI

// MARK: - 颜色主题
struct AppColors {
    // 主色调
    static let primaryBlue = Color(hex: "1E3A5F")      // 深蓝
    static let accentBlue = Color(hex: "3B82F6")        // 亮蓝
    static let primary = primaryBlue                    // 兼容旧代码别名
    
    // 功能色
    static let success = Color(hex: "22C55E")
    static let warning = Color(hex: "F59E0B")
    static let error = Color(hex: "EF4444")
    
    // 背景色
    static let pageBackground = Color(hex: "F8FAFC")
    static let cardBackground = Color.white
    static let groupBackground = Color(hex: "F1F5F9")
    
    // 文字色
    static let primaryText = Color(hex: "1E293B")
    static let secondaryText = Color(hex: "64748B")
    static let tertiaryText = Color(hex: "94A3B8")
    
    // 分隔线
    static let separator = Color(hex: "E2E8F0")
    
    // 模块色
    static let noteName = Color(hex: "3B82F6")
    static let interval = Color(hex: "8B5CF6")
    static let chord = Color(hex: "EC4899")
    static let scale = Color(hex: "14B8A6")
    static let rhythm = Color(hex: "F59E0B")
    static let melody = Color(hex: "22C55E")
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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
    /// 应用深蓝主题卡片样式
    func cardStyle() -> some View {
        self
            .padding()
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    /// 应用页面背景
    func pageBackground() -> some View {
        self.background(AppColors.pageBackground)
    }
}

// MARK: - 模块徽章
struct ModuleBadge: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(Capsule())
    }
}

// MARK: - 进度指示器（圆点样式）
struct ProgressDots: View {
    let total: Int
    let completed: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < completed ? AppColors.primaryBlue : Color(hex: "E2E8F0"))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
