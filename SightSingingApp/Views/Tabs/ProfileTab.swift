import SwiftUI
import Charts

/// Tab 4 — 我的（深蓝主题重构）
struct ProfileTab: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 用户头像区域
                    userProfileCard
                    
                    // 学习概览卡片
                    statsOverviewCard

                    // 各模块得分趋势
                    moduleScoresCard

                    // 快速入口
                    quickActionsCard

                    // 设置
                    settingsSection
                }
                .padding(.bottom, 24)
            }
            .pageBackground()
            .navigationTitle("我的")
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    // MARK: - User Profile Card

    private var userProfileCard: some View {
        HStack(spacing: 16) {
            // 头像
            ZStack {
                Circle()
                    .fill(AppColors.primaryBlue.opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "person.fill")
                    .font(.title)
                    .foregroundStyle(AppColors.primaryBlue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("音乐学习者")
                    .font(.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                Text("开始你的视唱练耳之旅")
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
            
            Spacer()
            
            // 等级徽章
            ModuleBadge(title: "Lv.5", color: AppColors.primaryBlue)
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - Stats Overview Card

    private var statsOverviewCard: some View {
        VStack(spacing: 20) {
            // 标题
            HStack {
                Text("学习概览")
                    .font(.headline)
                    .foregroundStyle(AppColors.primaryText)
                Spacer()
            }

            // 统计数字
            let stats = viewModel.totalStats()
            HStack(spacing: 0) {
                CompactStatItem(value: "\(stats.totalPracticeMinutes)", label: "练习分钟", icon: "clock", color: AppColors.primaryBlue)
                Divider().frame(height: 50)
                CompactStatItem(value: "\(stats.totalPracticeCount)", label: "练习次数", icon: "play.fill", color: AppColors.accentBlue)
                Divider().frame(height: 50)
                CompactStatItem(value: "\(stats.averageScore)", label: "平均得分", icon: "star.fill", color: AppColors.warning)
            }

            Divider()

            // 最近7天柱状图
            weekOverviewChart
        }
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    private var weekOverviewChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本周练习")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)

            let overview = viewModel.weekOverview()

            if overview.isEmpty {
                Text("暂无练习数据")
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .frame(height: 80)
            } else {
                Chart {
                    ForEach(overview, id: \.date) { day in
                        BarMark(
                            x: .value("日期", day.date, unit: .day),
                            y: .value("分钟", day.practiceMinutes)
                        )
                        .foregroundStyle(AppColors.primaryBlue.gradient)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 80)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.weekday(.narrow))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis(.hidden)
            }
        }
        .onAppear {
            _ = viewModel.weekOverview()
        }
    }

    // MARK: - Module Scores Card

    private var moduleScoresCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("模块得分趋势")
                    .font(.headline)
                    .foregroundStyle(AppColors.primaryText)
                Spacer()
            }

            ForEach(ExerciseModule.allCases.prefix(3)) { module in
                NavigationLink {
                    ScoreTrendView(module: module, viewModel: viewModel)
                } label: {
                    ModuleScoreRow(module: module, viewModel: viewModel)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - Quick Actions Card

    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("快捷操作")
                    .font(.headline)
                    .foregroundStyle(AppColors.primaryText)
                Spacer()
            }

            HStack(spacing: 12) {
                QuickActionButton(icon: "star.fill", title: "测试", color: AppColors.warning) {
                    // 导航到测试
                }

                QuickActionButton(icon: "book.fill", title: "乐理", color: AppColors.accentBlue) {
                    // 导航到乐理
                }

                QuickActionButton(icon: "gear", title: "设置", color: AppColors.secondaryText) {
                    // 导航到设置
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: 0) {
            // 谱式设置 (V2.1 新增)
            NavigationLink {
                NotationSettingsView()
            } label: {
                SettingsRow(icon: "music.note.list", title: "谱式选择", value: NotationPreferences.shared.preferredNotation.rawValue)
            }

            Divider()
                .padding(.leading, 56)

            // 主题设置
            NavigationLink {
                ThemeSettingsView(viewModel: viewModel)
            } label: {
                SettingsRow(icon: "circle.lefthalf.filled", title: "外观", value: themeName(viewModel.colorScheme))
            }

            Divider()
                .padding(.leading, 56)

            // 关于
            NavigationLink {
                AboutView()
            } label: {
                SettingsRow(icon: "info.circle", title: "关于", value: nil)
            }

            Divider()
                .padding(.leading, 56)
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    private func themeName(_ scheme: ColorScheme?) -> String {
        switch scheme {
        case .light: return "浅色"
        case .dark: return "深色"
        default: return "跟随系统"
        }
    }
}

/// 紧凑统计项
struct CompactStatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

/// 模块得分行
struct ModuleScoreRow: View {
    let module: ExerciseModule
    let viewModel: ProfileViewModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: module.iconName)
                .font(.title3)
                .foregroundStyle(moduleColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(module.rawValue)
                    .font(.body)
                    .foregroundStyle(AppColors.primaryText)

                if let lastScore = viewModel.moduleScoreTrend(module: module).last?.score, lastScore > 0 {
                    Text("最近得分: \(lastScore)")
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }

            Spacer()

            // 得分进度圆点
            let trend = viewModel.moduleScoreTrend(module: module)
            let progressCount = min(5, trend.count)
            ProgressDots(total: 5, completed: progressCount)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppColors.tertiaryText)
        }
        .padding(.vertical, 4)
    }

    private var moduleColor: Color {
        switch module {
        case .noteName: return AppColors.noteName
        case .interval: return AppColors.interval
        case .chord: return AppColors.chord
        case .scale: return AppColors.scale
        case .rhythm: return AppColors.rhythm
        case .melody: return AppColors.melody
        }
    }
}

/// 快捷操作按钮
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(AppColors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

/// 设置行
struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(AppColors.primaryBlue)
                .frame(width: 24)

            Text(title)
                .font(.body)
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            if let value = value {
                Text(value)
                    .font(.body)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppColors.tertiaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

/// 分数趋势页面
struct ScoreTrendView: View {
    let module: ExerciseModule
    let viewModel: ProfileViewModel

    var body: some View {
        let trend = viewModel.moduleScoreTrend(module: module)

        VStack(spacing: 24) {
            if trend.isEmpty {
                ContentUnavailableView(
                    "暂无数据",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("完成练习后即可查看趋势")
                )
            } else {
                Chart {
                    ForEach(trend, id: \.date) { item in
                        LineMark(
                            x: .value("日期", item.date),
                            y: .value("得分", item.score)
                        )
                        .foregroundStyle(moduleColor)

                        PointMark(
                            x: .value("日期", item.date),
                            y: .value("得分", item.score)
                        )
                        .foregroundStyle(moduleColor)
                    }
                }
                .frame(height: 200)
                .padding()
            }
        }
        .navigationTitle("\(module.rawValue) 得分趋势")
    }

    private var moduleColor: Color {
        switch module {
        case .noteName: return AppColors.noteName
        case .interval: return AppColors.interval
        case .chord: return AppColors.chord
        case .scale: return AppColors.scale
        case .rhythm: return AppColors.rhythm
        case .melody: return AppColors.melody
        }
    }
}

/// 主题设置页面
struct ThemeSettingsView: View {
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        List {
            Section {
                ForEach(["跟随系统", "浅色模式", "深色模式"], id: \.self) { option in
                    Button {
                        switch option {
                        case "浅色模式": viewModel.colorScheme = .light
                        case "深色模式": viewModel.colorScheme = .dark
                        default: viewModel.colorScheme = nil
                        }
                    } label: {
                        HStack {
                            Text(option)
                            Spacer()
                            if viewModel.colorScheme == (option == "浅色模式" ? .light : (option == "深色模式" ? .dark : nil)) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppColors.primaryBlue)
                            }
                        }
                    }
                    .foregroundStyle(AppColors.primaryText)
                }
            }
        }
        .navigationTitle("外观")
    }
}

/// 关于页面
struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
        .navigationTitle("关于")
    }
}

// MARK: - 谱式设置页面 (V2.1 新增)

/// 谱式选择设置页面
struct NotationSettingsView: View {
    @ObservedObject private var notationPrefs = NotationPreferences.shared

    var body: some View {
        List {
            Section {
                ForEach(NotationType.allCases) { notationType in
                    Button {
                        notationPrefs.preferredNotation = notationType
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: notationType.iconName)
                                .font(.title2)
                                .foregroundStyle(AppColors.primaryBlue)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(notationType.rawValue)
                                    .font(.body)
                                    .foregroundStyle(AppColors.primaryText)

                                Text(notationType.longDescription)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.secondaryText)
                            }

                            Spacer()

                            if notationPrefs.preferredNotation == notationType {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColors.primaryBlue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(AppColors.tertiaryText)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("选择练习时显示的谱式类型")
            } footer: {
                Text("五线谱适合专业视唱练耳训练，六线谱+简谱适合吉他弹唱学习")
            }
        }
        .navigationTitle("谱式选择")
    }
}

#Preview {
    NavigationStack {
        NotationSettingsView()
    }
}
