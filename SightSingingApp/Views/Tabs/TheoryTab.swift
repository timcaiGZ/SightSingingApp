import SwiftUI

/// Tab 3 — 乐理知识库
struct TheoryTab: View {
    @State private var viewModel = TheoryViewModel()
    @State private var selectedTopic: TheoryTopic?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.filteredTopics.isEmpty {
                    emptyState
                } else {
                    topicsList
                }
            }
            .navigationTitle("乐理")
            .searchable(text: $viewModel.searchText, prompt: "搜索知识点（如\"横按\"\"节奏型\"）")
            .navigationDestination(for: TheoryTopic.self) { topic in
                TheoryDetailView(topic: topic)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("未找到相关知识点")
                .font(.headline)
                .foregroundStyle(.secondary)
            Button("清除搜索") {
                viewModel.clearSearch()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var topicsList: some View {
        List {
            // 分类过滤器
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(
                            title: "全部",
                            isSelected: viewModel.selectedCategory == nil
                        ) {
                            viewModel.selectCategory(nil)
                        }

                        ForEach(TheoryCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.displayName,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                viewModel.selectCategory(category)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowBackground(Color.clear)
            }

            // 知识点列表（按分组）
            ForEach(viewModel.groupedTopics, id: \.category) { group in
                Section(group.category.displayName) {
                    ForEach(group.topics) { topic in
                        NavigationLink(value: topic) {
                            TheoryTopicRow(topic: topic)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

/// 分类选择标签
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.primary : Color(.systemGray5))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

/// 乐理知识行
struct TheoryTopicRow: View {
    let topic: TheoryTopic

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(topic.title)
                .font(.body)
                .fontWeight(.medium)

            Text(topic.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TheoryTab()
}
