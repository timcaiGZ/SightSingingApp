import SwiftUI

// MARK: - Tab 4 我的 (匹配 v0 原型: 用户卡+统计2x2+谱式单选+设置行+版本)
struct ProfileTab: View {
    @AppStorage("notationType") private var notationType: String = "guitar-tab"
    @AppStorage("darkMode") private var darkMode: Bool = false
    @State private var selectedSettingsRow: SettingsDestination?
    
    enum SettingsDestination: Hashable {
        case audio
        case reminder
        case studyData
        case help
        case privacy
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // === 页面标题 28px bold ===
                HStack {
                    Text("我的")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // === 用户信息卡 bg-card rounded-2xl border p-4 ===
                HStack(spacing: 12) {
                    // 头像 w-16 h-16 bg-accent/20 rounded-full
                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.15))
                            .frame(width: 56, height: 56)
                        Image(systemName: "person.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(AppTheme.accent)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("吉他学习者")
                            .font(.system(size: 17, weight: .semibold))   // text-[17px] font-semibold
                            .foregroundStyle(AppTheme.primaryText)
                        Text("已练习 128 天")
                            .font(.system(size: 13))                     // text-[13px]
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    
                    Spacer()
                }
                .padding(16)                                          // p-4
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))       // rounded-2xl
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))
                .padding(.horizontal, 16)
                
                // === 学习统计 bg-card rounded-2xl border overflow-hidden ===
                VStack(alignment: .leading, spacing: 0) {
                    // 标题 px-4 py-3 border-b
                    Text("学习统计")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    
                    Rectangle().fill(AppTheme.border).frame(height: 0.5)
                    
                    // grid-cols-2 divide-x
                    HStack(spacing: 0) {
                        StatCell(value: "256", label: "练习次数", color: AppTheme.accent)
                        
                        Rectangle().fill(AppTheme.border).frame(width: 0.5)
                        
                        StatCell(value: "78%", label: "平均准确率", color: AppTheme.success)
                    }
                    
                    Rectangle().fill(AppTheme.border).frame(height: 0.5)
                    
                    HStack(spacing: 0) {
                        StatCell(value: "42", label: "小时", color: AppTheme.warning)
                        
                        Rectangle().fill(AppTheme.border).frame(width: 0.5)
                        
                        StatCell(value: "15", label: "连续天数", color: AppTheme.Module.interval)
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))
                .padding(.horizontal, 16)
                
                // === 学习设置 bg-card rounded-2xl border overflow-hidden ===
                VStack(alignment: .leading, spacing: 0) {
                    // 标题
                    Text("学习设置")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    
                    Rectangle().fill(AppTheme.border).frame(height: 0.5)
                    
                    // 谱式选择区 px-4 py-3
                    VStack(alignment: .leading, spacing: 8) {
                        // 图标 + 标题 + 描述 (ml-8)
                        HStack(spacing: 10) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 18))
                                .foregroundStyle(AppTheme.accent)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("谱式选择")                       // text-[15px]
                                    .font(.system(size: 15))
                                    .foregroundStyle(AppTheme.primaryText)
                                Text("选择练习时显示的谱式类型")     // text-[13px]
                                    .font(.system(size: 13))
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                        }
                        .padding(.bottom, 4)
                        
                        // 单选项列表 space-y-2
                        NotationSelectOption(
                            title: "五线谱",
                            subtitle: "专业视唱练耳训练",
                            isSelected: notationType == "staff",
                            onTap: { notationType = "staff" }
                        )
                        
                        NotationSelectOption(
                            title: "六线谱 + 简谱",
                            subtitle: "吉他弹唱学习（推荐）",
                            isSelected: notationType == "guitar-tab",
                            onTap: { notationType = "guitar-tab" }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))
                .padding(.horizontal, 16)
                
                // === 通用设置 bg-card rounded-2xl border overflow-hidden ===
                VStack(alignment: .leading, spacing: 0) {
                    Text("通用设置")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    
                    Rectangle().fill(AppTheme.border).frame(height: 0.5)
                    
                    VStack(spacing: 0) {
                        SettingsRow(icon: "speaker.wave.2.fill", title: "音频设置", showChevron: true) {
                            selectedSettingsRow = .audio
                        }
                        
                        Divider().padding(.leading, 52)
                        
                        SettingsRow(icon: "bell.fill", title: "每日提醒", showChevron: true) {
                            selectedSettingsRow = .reminder
                        }
                        
                        Divider().padding(.leading, 52)
                        
                        SettingsRow(icon: "chart.bar.fill", title: "学习数据", showChevron: true) {
                            selectedSettingsRow = .studyData
                        }
                        
                        Divider().padding(.leading, 52)
                        
                        // 深色模式开关
                        HStack(spacing: 12) {
                            Image(systemName: "moon.fill")
                                .font(.system(size: 17))
                                .foregroundStyle(AppTheme.accent)
                            
                            Text("深色模式")
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.primaryText)
                            
                            Spacer()
                            
                            // iOS 风格 Toggle switch
                            Toggle("", isOn: $darkMode)
                                .labelsHidden()
                                .tint(AppTheme.accent)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))
                .padding(.horizontal, 16)
                
                // === 其他设置 bg-card rounded-2xl border ===
                VStack(spacing: 0) {
                    SettingsRow(icon: "questionmark.circle.fill", title: "帮助与反馈", iconColor: AppTheme.secondaryText, showChevron: true) {
                        selectedSettingsRow = .help
                    }
                    
                    Divider().padding(.leading, 52)
                    
                    SettingsRow(icon: "shield.fill", title: "隐私政策", iconColor: AppTheme.secondaryText, showChevron: true) {
                        selectedSettingsRow = .privacy
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))
                .padding(.horizontal, 16)
                
                // === 版本信息 text-[13px] center text-muted-foreground py-4 ===
                Text("视唱练耳 v2.0.0")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.tertiaryText)
                    .padding(.top, 8)
            }
            .padding(.bottom, 24)
        }
        .background(AppTheme.background)
        .navigationDestination(item: $selectedSettingsRow) { dest in
            SettingsDetailView(destination: dest)
        }
    }
}

// MARK: - 设置详情页 (通用占位页)
struct SettingsDetailView: View {
    let destination: ProfileTab.SettingsDestination
    @Environment(\.dismiss) private var dismiss
    
    private var title: String {
        switch destination {
        case .audio: return "音频设置"
        case .reminder: return "每日提醒"
        case .studyData: return "学习数据"
        case .help: return "帮助与反馈"
        case .privacy: return "隐私政策"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("← 返回") { dismiss() }
                    .font(.system(size: 17))
                    .foregroundStyle(AppTheme.accent)
                Spacer()
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Color.clear.frame(width: 50)
            }
            .padding(16)
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 40)
                    Image(systemName: "gear")
                        .font(.system(size: 48))
                        .foregroundStyle(AppTheme.secondaryText.opacity(0.3))
                    Text("\(title)页面")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText)
                    Text("该功能将在后续版本中完善")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.tertiaryText)
                    Spacer()
                }
            }
        }
        .background(AppTheme.background)
        .navigationBarHidden(true)
    }
}

// MARK: - 统计单元格 (p-4 text-center)
struct StatCell: View {
    let value: String; let label: String; let color: Color
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold))      // text-[28px]
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 13))                      // text-[13px]
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)                              // p-4
    }
}

// MARK: - 谱式单选选项 (匹配 v0: flex items-between px-4 py-3 rounded-xl border)
struct NotationSelectOption: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(AppTheme.primaryText)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                
                Spacer()
                
                // 单选圆圈 w-5 h-5 rounded-full border-2
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppTheme.accent : AppTheme.secondaryText, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(AppTheme.accent)
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)                         // px-4 py-3
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))  // rounded-xl
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppTheme.accent : AppTheme.border, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(IOSPressStyle())
    }
}

// MARK: - 设置行 (匹配 v0: flex items-center gap-3 px-4 py-3 ios-press)
struct SettingsRow: View {
    let icon: String
    let title: String
    var iconColor: Color = AppTheme.accent
    var showChevron: Bool = false
    var onAction: () -> Void = {}
    
    var body: some View {
        Button(action: onAction) {
            HStack(spacing: 12) {                           // gap-3
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(iconColor)
                    .frame(width: 22)                         // w-5
                
                Text(title)
                    .font(.system(size: 15))                 // text-[15px]
                    .foregroundStyle(AppTheme.primaryText)
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText.opacity(0.5))  // text-muted-foreground/50
                }
            }
            .padding(.horizontal, 16)                        // px-4
            .padding(.vertical, 12)                          // py-3
        }
        .buttonStyle(IOSPressStyle())
    }
}

#Preview { ProfileTab() }