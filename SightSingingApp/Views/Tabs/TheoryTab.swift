import SwiftUI

/// Tab 3 — 乐理知识库（采用卡片式知识点展示）
struct TheoryTab: View {
    @State private var viewModel = TheoryViewModel()
    @State private var selectedTopic: TheoryTopic?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.filteredTopics.isEmpty {
                    emptyState
                } else {
                    topicsGrid
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("乐理")
            .searchable(text: $viewModel.searchText, prompt: "搜索知识点（如\"横按\"\"节奏型\"）")
            .navigationDestination(for: TheoryTopic.self) { topic in
                TheoryDetailView(topic: topic)
            }
        }
    }

    // MARK: - Empty State

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
    }

    // MARK: - Topics Grid

    private var topicsGrid: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 分类过滤器
                categoryFilter

                // 知识点卡片网格
                ForEach(viewModel.groupedTopics, id: \.category) { group in
                    VStack(alignment: .leading, spacing: 12) {
                        // 分类标题
                        Text(group.category.displayName)
                            .font(.headline)
                            .foregroundStyle(AppColors.primaryText)
                            .padding(.horizontal, 16)

                        // 卡片网格
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(group.topics) { topic in
                                NavigationLink(value: topic) {
                                    TopicCard(topic: topic)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 16)
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
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
            .padding(.horizontal, 16)
        }
    }
}

/// 知识点卡片
struct TopicCard: View {
    let topic: TheoryTopic

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 图标
            Image(systemName: topicIcon)
                .font(.title2)
                .foregroundStyle(categoryColor)

            // 标题
            Text(topic.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // 摘要
            Text(topic.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private var topicIcon: String {
        switch topic.category {
        case .notationBasics: return "doc.text"
        case .intervalsAndScales: return "arrow.left.and.right"
        case .chords: return "hand.raised"
        case .rhythm: return "metronome"
        case .modes: return "pianokeys"
        }
    }

    private var categoryColor: Color {
        switch topic.category {
        case .notationBasics: return AppColors.noteName
        case .intervalsAndScales: return AppColors.interval
        case .chords: return AppColors.chord
        case .rhythm: return AppColors.rhythm
        case .modes: return AppColors.scale
        }
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

#Preview {
    TheoryTab()
}
