import SwiftUI

/// Tab 1 — 练习首页
struct PracticeTab: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = PracticeViewModel()
    @State private var selectedModule: ExerciseModule?

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(ExerciseModule.allCases) { module in
                        NavigationLink(value: module) {
                            ModuleCard(module: module, viewModel: viewModel)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("练习")
            .navigationDestination(for: ExerciseModule.self) { module in
                ModuleDetailView(module: module, viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }
}

/// 模块卡片组件
struct ModuleCard: View {
    let module: ExerciseModule
    let viewModel: PracticeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 顶部渐变色条
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [module.gradientStart, module.gradientEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 6)

            // 图标 + 名称
            HStack {
                Image(systemName: module.iconName)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [module.gradientStart, module.gradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Spacer()

                if let bestScore = viewModel.bestScore(for: ExerciseType.allCases.first { $0.module == module } ?? .singleNoteRecognition),
                   bestScore > 0 {
                    Text("\(bestScore)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(module.gradientStart)
                        .clipShape(Capsule())
                }
            }

            Text(module.rawValue)
                .font(.headline)
                .fontWeight(.semibold)

            Text(module.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            // 练习次数
            let count = viewModel.practiceCount(for: module)
            if count > 0 {
                Text("\(count) 次练习")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    PracticeTab()
        .modelContainer(for: [PracticeRecord.self, TestHistory.self], inMemory: true)
}
