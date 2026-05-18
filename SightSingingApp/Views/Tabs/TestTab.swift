import SwiftUI
import SwiftData

/// Tab 2 — 测试入口（增加诊断测试入口卡片样式）
struct TestTab: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TestViewModel()
    @Query(sort: \TestHistory.date, order: .reverse) private var history: [TestHistory]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 测试入口卡片
                    testEntryCard

                    // 历史记录
                    if !history.isEmpty {
                        historySection
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("测试")
        }
        .sheet(isPresented: $viewModel.showingTestIntro) {
            TestIntroSheet {
                viewModel.startTest()
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    // MARK: - Test Entry Card

    private var testEntryCard: some View {
        VStack(spacing: 20) {
            // 图标
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 36))
                    .foregroundStyle(AppColors.primary)
            }

            // 标题
            VStack(spacing: 8) {
                Text(AppConstants.appName)
                    .font(.title2)
                    .fontWeight(.bold)

                Text("全面评估你的视唱练耳能力")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // 特点列表
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "list.number", text: "30 道精选题目")
                FeatureRow(icon: "clock", text: "约 5-10 分钟")
                FeatureRow(icon: "chart.bar", text: "6 大维度分析")
                FeatureRow(icon: "star", text: "个性化推荐")
            }
            .padding(.horizontal, 16)

            // 开始按钮
            Button {
                viewModel.showingTestIntro = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("开始诊断测试")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - History Section

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("测试历史")
                .font(.headline)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(history.prefix(5)) { record in
                    TestHistoryRow(record: record)

                    if record != history.prefix(5).last {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
    }
}

/// 特点行
struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(AppColors.primary)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()
        }
    }
}

/// 测试说明弹窗
struct TestIntroSheet: View {
    let onStart: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 60))
                    .foregroundStyle(AppColors.primary)
                    .padding(.top, 32)

                Text("\(AppConstants.appName) - \(AppConstants.testName)")
                    .font(.title)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(icon: "list.number", title: "30 道题目")
                    InfoRow(icon: "clock", title: "约 5-10 分钟")
                    InfoRow(icon: "chart.bar", title: "6 大维度分析")
                    InfoRow(icon: "star", title: "个性化推荐")
                }
                .padding(.horizontal, 24)

                Text("题目涵盖音名、音程、和弦、调式、节奏、旋律六大模块。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer()

                Button {
                    dismiss()
                    onStart()
                } label: {
                    Text("开始测试")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("测试说明")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct InfoRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.primary)
                .frame(width: 24)
            Text(title)
                .font(.body)
        }
    }
}

/// 测试历史记录行
struct TestHistoryRow: View {
    let record: TestHistory

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.date, style: .date)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(record.dimensionScores.count) 维度分析")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(record.totalScore)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(scoreColor(record.totalScore))

            Text("分")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 90 { return AppColors.success }
        else if score >= 70 { return AppColors.warning }
        else { return AppColors.error }
    }
}

#Preview {
    TestTab()
        .modelContainer(for: [PracticeRecord.self, TestHistory.self], inMemory: true)
}
