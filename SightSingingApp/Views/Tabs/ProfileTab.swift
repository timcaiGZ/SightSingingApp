import SwiftUI
import Charts

/// Tab 4 — 我的（增加学习统计可视化）
struct ProfileTab: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
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
            .background(Color(.systemGroupedBackground))
            .navigationTitle("我的")
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    // MARK: - Stats Overview Card

    private var statsOverviewCard: some View {
        VStack(spacing: 20) {
            // 标题
            HStack {
                Text("学习概览")
                    .font(.headline)
                Spacer()
            }

            // 统计数字
            let stats = viewModel.totalStats()
            HStack(spacing: 0) {
                CompactStatItem(value: "\(stats.totalPracticeMinutes)", label: "练习分钟", icon: "clock")
                Divider().frame(height: 50)
                CompactStatItem(value: "\(stats.totalPracticeCount)", label: "练习次数", icon: "play")
                Divider().frame(height: 50)
                CompactStatItem(value: "\(stats.averageScore)", label: "平均得分", icon: "star")
            }

            Divider()

            // 最近7天柱状图
            weekOverviewChart
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var weekOverviewChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本周练习")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            let overview = viewModel.weekOverview()

            if overview.isEmpty {
                Text("暂无练习数据")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 80)
            } else {
                Chart {
                    ForEach(overview, id: \.date) { day in
                        BarMark(
                            x: .value("日期", day.date, unit: .day),
                            y: .value("分钟", day.practiceMinutes)
                        )
                        .foregroundStyle(AppColors.primary.gradient)
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
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    // MARK: - Quick Actions Card

    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("快捷操作")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 12) {
                QuickActionButton(icon: "star.fill", title: "测试", color: AppColors.warning) {
                    // 导航到测试
                }

                QuickActionButton(icon: "book.fill", title: "乐理", color: AppColors.info) {
                    // 导航到乐理
                }

                QuickActionButton(icon: "gear", title: "设置", color: AppColors.secondaryText) {
                    // 导航到设置
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: 0) {
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
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(AppColors.primary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primary)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
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
                    .foregroundStyle(.primary)

                if let lastScore = viewModel.moduleScoreTrend(module: module).last?.score, lastScore > 0 {
                    Text("最近得分: \(lastScore)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
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
                    .foregroundStyle(.primary)
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
                .foregroundStyle(AppColors.primary)
                .frame(width: 24)

            Text(title)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()

            if let value = value {
                Text(value)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
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
                                    .foregroundStyle(AppColors.primary)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
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
                    Text(AppConstants.appVersion)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("关于")
    }
}

#Preview {
    ProfileTab()
        .modelContainer(for: [PracticeRecord.self, TestHistory.self], inMemory: true)
}
