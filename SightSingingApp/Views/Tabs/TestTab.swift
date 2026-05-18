import SwiftUI
import SwiftData

/// Tab 2 — 测试入口
struct TestTab: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TestViewModel()
    @Query(sort: \TestHistory.date, order: .reverse) private var history: [TestHistory]

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.state == .idle || viewModel.state == .showingResult {
                    testIdleView
                } else if viewModel.state == .inProgress {
                    DiagnosticTestView(viewModel: viewModel)
                }
            }
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

    private var testIdleView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 开始测试大按钮
                VStack(spacing: 12) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.info],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text(AppConstants.appName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(AppConstants.testDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button {
                        viewModel.showingTestIntro = true
                    } label: {
                        Text("开始诊断测试")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.info],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // 历史记录
                if !history.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("测试历史")
                            .font(.headline)
                            .padding(.horizontal, 16)

                        ForEach(history.prefix(5)) { record in
                            TestHistoryRow(record: record)
                        }
                    }
                }

                Spacer()
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
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
                .foregroundStyle(AppColors.primary)

            Text("分")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
}

#Preview {
    TestTab()
        .modelContainer(for: [PracticeRecord.self, TestHistory.self], inMemory: true)
}
