import SwiftUI

/// Tab 4 — 我的
struct ProfileTab: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            List {
                // 学习概览
                Section {
                    StatsOverviewSection(viewModel: viewModel)
                }

                // 模块得分趋势
                Section("各模块得分趋势") {
                    ForEach(ExerciseModule.allCases.prefix(3)) { module in
                        NavigationLink {
                            ScoreTrendView(module: module, viewModel: viewModel)
                        } label: {
                            HStack {
                                Image(systemName: module.iconName)
                                    .foregroundStyle(module.gradientStart)
                                    .frame(width: 24)
                                Text(module.rawValue)
                                Spacer()
                                Text("\(viewModel.moduleScoreTrend(module: module).last?.score ?? 0) 分")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // 设置
                Section("设置") {
                    NavigationLink {
                        SettingsView(viewModel: viewModel)
                    } label: {
                        Label("深色/浅色主题", systemImage: "circle.lefthalf.filled")
                    }
                }
            }
            .navigationTitle("我的")
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }
}

/// 学习概览卡片
struct StatsOverviewSection: View {
    let viewModel: ProfileViewModel
    @State private var overview: [ProfileViewModel.WeekOverview] = []

    var body: some View {
        VStack(spacing: 12) {
            // 统计数字
            let stats = viewModel.totalStats()
            HStack(spacing: 0) {
                StatItem(value: "\(stats.totalPracticeMinutes)", label: "练习分钟")
                Divider().frame(height: 40)
                StatItem(value: "\(stats.totalPracticeCount)", label: "练习次数")
                Divider().frame(height: 40)
                StatItem(value: "\(stats.averageScore)", label: "平均得分")
                Divider().frame(height: 40)
                StatItem(value: "\(stats.testCount)", label: "测试次数")
            }

            Divider()

            // 最近7天柱状图
            if !overview.isEmpty {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(overview, id: \.date) { day in
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AppColors.primary.opacity(day.practiceMinutes > 0 ? 0.3 + Double(day.practiceMinutes) / 30.0 * 0.7 : 0.1))
                                .frame(width: 28, height: max(4, CGFloat(day.practiceMinutes) * 2))

                            Text(day.date, format: .dateTime.weekday(.narrow))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 60)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            overview = viewModel.weekOverview()
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
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
                // 简单折线图
                Chart {
                    ForEach(trend, id: \.date) { item in
                        LineMark(
                            x: .value("日期", item.date),
                            y: .value("得分", item.score)
                        )
                        .foregroundStyle(module.gradientStart)

                        PointMark(
                            x: .value("日期", item.date),
                            y: .value("得分", item.score)
                        )
                        .foregroundStyle(module.gradientStart)
                    }
                }
                .frame(height: 200)
                .padding()
            }
        }
        .navigationTitle("\(module.rawValue) 得分趋势")
    }
}

/// 设置页面
struct SettingsView: View {
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        List {
            Section("外观") {
                ForEach(["跟随系统", "浅色模式", "深色模式"], id: \.self) { option in
                    Button {
                        switch option {
                        case "浅色模式":
                            viewModel.colorScheme = .light
                        case "深色模式":
                            viewModel.colorScheme = .dark
                        default:
                            viewModel.colorScheme = nil
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

            Section("音频") {
                Toggle("节拍器", isOn: $viewModel.metronomeEnabled)

                if viewModel.metronomeEnabled {
                    HStack {
                        Text("节拍音量")
                        Slider(value: $viewModel.metronomeVolume, in: 0...1)
                    }
                }
            }

            Section("关于") {
                HStack {
                    Text("版本")
                    Spacer()
                    Text(AppConstants.appVersion)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("设置")
    }
}

import Charts

#Preview {
    ProfileTab()
        .modelContainer(for: [PracticeRecord.self, TestHistory.self], inMemory: true)
}
