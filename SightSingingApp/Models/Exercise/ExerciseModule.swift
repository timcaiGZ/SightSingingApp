import SwiftUI

/// 6 大练习模块枚举，完全面向民谣吉他学习者
enum ExerciseModule: String, CaseIterable, Identifiable, Codable {
    case noteName = "音名"      // 简谱音高、六线谱音符
    case interval = "音程"      // 吉他把位音程关系
    case chord = "和弦"         // 吉他常用和弦按法
    case scale = "调式"         // 各调式音阶把位、CAGED系统
    case rhythm = "节奏"       // 扫弦节奏型、分解和弦节奏型
    case melody = "旋律"        // 吉他旋律线、简谱旋律视唱

    var id: String { rawValue }

    /// SF Symbol 图标
    var iconName: String {
        switch self {
        case .noteName: return "music.note"
        case .interval: return "arrow.left.and.right"
        case .chord: return "hand.raised"
        case .scale: return "pianokeys"
        case .rhythm: return "metronome"
        case .melody: return "waveform"
        }
    }

    /// 卡片渐变色起点
    var gradientStart: Color {
        switch self {
        case .noteName: return Color(hex: "4A90E2")
        case .interval: return Color(hex: "50C878")
        case .chord: return Color(hex: "FF6B6B")
        case .scale: return Color(hex: "9B59B6")
        case .rhythm: return Color(hex: "F39C12")
        case .melody: return Color(hex: "1ABC9C")
        }
    }

    /// 卡片渐变色终点
    var gradientEnd: Color {
        switch self {
        case .noteName: return Color(hex: "357ABD")
        case .interval: return Color(hex: "2ECC71")
        case .chord: return Color(hex: "E74C3C")
        case .scale: return Color(hex: "8E44AD")
        case .rhythm: return Color(hex: "E67E22")
        case .melody: return Color(hex: "16A085")
        }
    }

    /// 描述（吉他场景）
    var description: String {
        switch self {
        case .noteName: return "简谱音高 · 空弦音 · 根音"
        case .interval: return "把位音程 · 推弦揉弦"
        case .chord: return "大横按 · 和弦转换"
        case .scale: return "各调把位 · CAGED系统"
        case .rhythm: return "扫弦节奏 · 分解和弦"
        case .melody: return "简谱视唱 · 旋律辨认"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(ExerciseModule.allCases) { module in
            HStack {
                Image(systemName: module.iconName)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [module.gradientStart, module.gradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text(module.rawValue)
                Spacer()
                Text(module.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    .padding()
}
