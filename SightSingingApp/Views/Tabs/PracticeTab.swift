import SwiftUI

// MARK: - Tab 1 练习首页 (严格匹配 v0.app 原型: 五大分类卡片)
struct PracticeTab: View {
    @State private var selectedCategory: PracticeCategoryData?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // === 页面标题 28px bold ===
                    VStack(alignment: .leading, spacing: 4) {
                        Text("练习")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppTheme.primaryText)
                        Text("轻松视唱练耳，自由畅快弹唱")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
                    // === 五大练习分类 space-y-3 ===
                    VStack(spacing: 12) {
                        ForEach(PracticeCategoryData.allCategories) { category in
                            PracticeCategoryCard(category: category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // === 底部提示 ===
                    VStack(alignment: .leading, spacing: 4) {
                        Text("训练建议")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.primaryText)
                        Text("建议按照「音准 → 唱准 → 节奏 → 和弦 → 扒谱」的顺序循序渐进，每个分类从第一组开始练习。")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.secondaryText)
                            .lineSpacing(2)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.secondaryBg.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
                .padding(.bottom, 24)
            }
            .background(AppTheme.background)
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedCategory) { category in
                PracticeCategoryPage(category: category)
            }
        }
    }
}

// MARK: - 五大分类卡片 (匹配 v0: bg-card rounded-2xl p-4 border ios-press)
struct PracticeCategoryCard: View {
    let category: PracticeCategoryData
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // === 左侧彩色图标 w-14 h-14 rounded-xl ===
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(category.color)
                        .frame(width: 56, height: 56)
                    Image(systemName: category.systemImage)
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }
                
                // === 中间内容 flex-1 min-w-0 ===
                VStack(alignment: .leading, spacing: 2) {
                    // 标题 + 副标题徽章
                    HStack(spacing: 6) {
                        Text(category.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryText)
                        Text(category.subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.secondaryText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppTheme.secondaryBg)
                            .clipShape(Capsule())
                    }
                    
                    // 描述
                    Text(category.description)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(1)
                    
                    // 进度条
                    HStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(AppTheme.secondaryBg)
                                    .frame(height: 6)
                                Capsule()
                                    .fill(category.color)
                                    .frame(width: geo.size.width * CGFloat(category.progress) / 100, height: 6)
                            }
                        }
                        .frame(height: 6)
                        
                        Text("\(category.progress)%")
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.secondaryText)
                            .frame(width: 30, alignment: .trailing)
                    }
                }
                
                // === 右箭头 ===
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))  // rounded-2xl
            .overlay(
                RoundedRectangle(cornerRadius: 20)  // rounded-2xl
                    .stroke(AppTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(IOSPressStyle())
    }
}

// MARK: - iOS 风格按压按钮样式
struct IOSPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    PracticeTab()
}
