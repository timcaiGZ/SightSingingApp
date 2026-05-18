import Foundation

// MARK: - 谱式类型枚举 (V2.1 简化)

///
/// 两种谱式选项：
/// - 五线谱：单独使用（专业视唱练耳训练）
/// - 六线谱+简谱：组合使用（吉他弹唱学习），默认选项
enum NotationType: String, CaseIterable, Identifiable {
    case staff = "五线谱"
    case tabWithSolfege = "六线谱+简谱"

    var id: String { rawValue }

    /// 图标名称
    var iconName: String {
        switch self {
        case .staff: return "music.quarternote.3"
        case .tabWithSolfege: return "guitars"
        }
    }

    /// 简短描述
    var shortDescription: String {
        switch self {
        case .staff: return "专业视唱练耳训练"
        case .tabWithSolfege: return "吉他弹唱学习"
        }
    }

    /// 详细描述
    var longDescription: String {
        switch self {
        case .staff: return "传统五线谱，适合专业视唱练耳训练"
        case .tabWithSolfege: return "六线谱与简谱同步显示，方便吉他弹唱学习"
        }
    }
}

// MARK: - 谱式切换管理器

/// 用户谱式偏好管理器
final class NotationPreferences: ObservableObject {
    static let shared = NotationPreferences()

    @Published var preferredNotation: NotationType {
        didSet {
            UserDefaults.standard.set(preferredNotation.rawValue, forKey: "preferredNotation")
        }
    }

    /// 是否在练习中显示谱式切换器
    @Published var showNotationSwitcher: Bool {
        didSet {
            UserDefaults.standard.set(showNotationSwitcher, forKey: "showNotationSwitcher")
        }
    }

    private init() {
        // 默认使用六线谱+简谱组合
        let savedNotation = UserDefaults.standard.string(forKey: "preferredNotation") ?? NotationType.tabWithSolfege.rawValue
        self.preferredNotation = NotationType(rawValue: savedNotation) ?? .tabWithSolfege

        self.showNotationSwitcher = UserDefaults.standard.object(forKey: "showNotationSwitcher") as? Bool ?? true
    }

    /// 重置为默认设置（六线谱+简谱）
    func resetToDefaults() {
        preferredNotation = .tabWithSolfege
        showNotationSwitcher = true
    }
}
