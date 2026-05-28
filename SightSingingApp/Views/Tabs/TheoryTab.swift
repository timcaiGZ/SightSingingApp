import SwiftUI

// MARK: - Tab 2 乐理 (匹配 v0 原型: 标题34px + 副标题15px + 搜索框 + 手风琴)
struct TheoryTab: View {
    @State private var expandedCategories: Set<String> = []  // 默认全部收拢
    @State private var selectedTopic: TheoryTopicData?
    @State private var navigateToSpecial: String?
    @State private var searchQuery = ""
    @State private var progressService = TheoryProgressService()
    
    // 搜索过滤
    var filteredCategories: [TheoryCategoryData] {
        if searchQuery.isEmpty { return TheoryCategoryData.allCategories }
        return TheoryCategoryData.allCategories.compactMap { cat in
            let filteredTopics = cat.topics.filter {
                $0.title.localizedCaseInsensitiveContains(searchQuery) ||
                $0.description.localizedCaseInsensitiveContains(searchQuery)
            }
            if filteredTopics.isEmpty { return nil }
            return TheoryCategoryData(
                id: cat.id, title: cat.title, description: cat.description,
                icon: cat.icon, color: cat.color, topics: filteredTopics
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // === 固定头部：标题 + 搜索框 ===
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("乐理")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(AppTheme.primaryText)
                        Text("轻松视唱练耳，自由畅快弹唱")
                            .font(.system(size: 15))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 搜索框
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(AppTheme.secondaryText)
                        
                        TextField("搜索乐理知识...", text: $searchQuery)
                            .font(.system(size: 15))
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(AppTheme.secondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(searchQuery.isEmpty ? Color.clear : AppTheme.accent.opacity(0.2), lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .background(AppTheme.background)
                
                // === 滚动内容：分类手风琴列表 ===
                ScrollView {
                    VStack(spacing: 16) {
                    ForEach(filteredCategories) { category in
                        TheoryCategoryAccordionView(
                            category: category,
                            isExpanded: expandedCategories.contains(category.id) || !searchQuery.isEmpty,
                            progressService: progressService,
                            onToggle: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if expandedCategories.contains(category.id) {
                                        expandedCategories.remove(category.id)
                                    } else {
                                        expandedCategories.insert(category.id)
                                    }
                                }
                            },
                            onTopicSelect: { topic in
                                if topic.isSpecial {
                                    navigateToSpecial = topic.id
                                } else {
                                    selectedTopic = topic
                                }
                            }
                        )
                    }
                    
                    // === 搜索无结果 ===
                    if !searchQuery.isEmpty && filteredCategories.isEmpty {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.mutedBackground)
                                    .frame(width: 64, height: 64)
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                            
                            Text("未找到结果")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(AppTheme.primaryText)
                            
                            Text("没有找到与\"\(searchQuery)\"相关的乐理知识")
                                .font(.system(size: 14))
                                .foregroundStyle(AppTheme.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 48)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .background(AppTheme.background)
            }
            .navigationDestination(item: $selectedTopic) { topic in
            TheoryDetailView(topic: topic, progressService: progressService)
        }
        .navigationDestination(item: $navigateToSpecial) { specialId in
            switch specialId {
            case "seventh-chords":
                SeventhChordsView()
            case "mode-relation", "circle-of-fifths-intro":
                CircleOfFifthsView()
            case "chord-library-full":
                ChordBrowserView()
            case "mode-explorer":
                ModeExplorerView()
            case "rhythm-library":
                RhythmLibraryView()
            default:
                Text("未知页面")
            }
        }
        }  // NavigationStack
    }
}

// MARK: - 手风琴分类卡片 (匹配 v0: 彩色图标圆角方框 + title + count + chevron-down)
struct TheoryCategoryAccordionView: View {
    let category: TheoryCategoryData
    let isExpanded: Bool
    var progressService: TheoryProgressService? = nil
    let onToggle: () -> Void
    let onTopicSelect: (TheoryTopicData) -> Void

    private var catProgress: TheoryProgressService.CategoryProgress {
        let ids = category.topics.map(\.id)
        return progressService?.categoryProgress(topicIds: ids)
            ?? TheoryProgressService.CategoryProgress(completed: 0, total: ids.count)
    }

    var body: some View {
        VStack(spacing: 0) {
            // === 分类标题行 (v0: gap-4 + description) ===
            Button(action: onToggle) {
                HStack(spacing: 16) {
                    // 彩色图标背景 w-14 h-14 rounded-xl
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(category.color)
                            .frame(width: 56, height: 56)
                        Image(systemName: category.icon)
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                    }

                    // 标题+描述 flex-1
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryText)
                        Text(category.description)
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                            .lineLimit(1)
                    }

                    Spacer()

                    // 数量 text-[13px] + padding
                    Text("\(category.topics.count)")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)

                    // 展开箭头 rotate-180
                    Image(systemName: "chevron.down")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.secondaryText)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            // === 知识点卡片列表 mt-2 bg-card rounded-xl shadow-sm ===
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(category.topics.enumerated()), id: \.element.id) { index, topic in
                        TopicCardRow(
                            topic: topic,
                            isRead: progressService?.isRead(topic.id) ?? false,
                            onTap: { onTopicSelect(topic) }
                        )

                        if index < category.topics.count - 1 {
                            Divider().padding(.leading, 16)
                        }
                    }

                    // 分类进度条
                    if catProgress.total > 0 {
                        HStack(spacing: 8) {
                            // 进度条
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(AppTheme.border)
                                        .frame(height: 6)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(catProgress.isComplete ? AppTheme.success : category.color)
                                        .frame(width: geo.size.width * CGFloat(catProgress.completed) / CGFloat(catProgress.total), height: 6)
                                }
                            }
                            .frame(height: 6)

                            Text("\(catProgress.completed)/\(catProgress.total)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(catProgress.isComplete ? AppTheme.success : AppTheme.secondaryText)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(AppTheme.mutedBackground.opacity(0.5))
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))  // rounded-xl
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)  // shadow-sm
                .padding(.top, 8)   // mt-2
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - 知识点卡片行 (匹配 v0 TopicCard: title+desc + chevron-right)
struct TopicCardRow: View {
    let topic: TheoryTopicData
    var isRead: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // ✓ 已读标记
                if isRead {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.success)
                        .padding(.trailing, 10)
                }

                // 左侧内容 flex-1
                VStack(alignment: .leading, spacing: 4) {
                    Text(topic.title)
                        .font(.system(size: 17, weight: .semibold))   // text-[17px] font-semibold
                        .foregroundStyle(AppTheme.primaryText)

                    Text(topic.description)
                        .font(.system(size: 13))                   // text-[13px]
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(1)
                }

                Spacer()

                // 右箭头 text-muted-foreground/40 flex-shrink-0 ml-3
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.tertiaryText.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)  // py-3.5
        }
        .buttonStyle(IOSPressStyle())
        .contentShape(Rectangle())
    }
}

#Preview {
    TheoryTab()
}
