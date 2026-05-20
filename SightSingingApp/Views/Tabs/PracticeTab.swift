import SwiftUI

// MARK: - Tab 1 练习首页 (匹配 v0 原型)
struct PracticeTab: View {
    @State private var selectedExercise: ExerciseItem?
    @State private var selectedModuleId: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 页面标题 (28px bold)
                HStack {
                    Text("自由练习")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // 练习模块列表
                VStack(spacing: 16) {
                    ForEach(PracticeModuleData.allModules) { module in
                        ModuleCardView(module: module) { exercise in
                            selectedExercise = exercise
                            selectedModuleId = module.id
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 24)
        }
        .background(AppTheme.background)
        .navigationDestination(item: $selectedExercise) { exercise in
            ExerciseContainerView(
                exercise: exercise,
                moduleId: selectedModuleId ?? ""
            )
        }
    }
}

// MARK: - 模块卡片 (匹配 v0 ModuleCard: 彩色顶条 + 标题栏 + 分割线 + 列表)
struct ModuleCardView: View {
    let module: PracticeModuleData
    let onExerciseSelect: (ExerciseItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // === 顶部彩色条 h-1 (4pt) ===
            Rectangle()
                .fill(module.color)
                .frame(height: 4)
            
            // === 标题栏: icon + title, border-b ===
            HStack(spacing: 8) {
                Image(systemName: module.icon)
                    .font(.system(size: 15))
                    .foregroundStyle(module.color)
                
                Text(module.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .overlay(alignment: .bottom) {
                Rectangle().fill(AppTheme.border).frame(height: 0.5)
            }
            
            // === 内容区: divide-y ===
            VStack(spacing: 0) {
                ForEach(Array(module.exercises.enumerated()), id: \.element.id) { index, exercise in
                    ModuleItemView(exercise: exercise, onTap: { onExerciseSelect(exercise) })
                    
                    if index < module.exercises.count - 1 {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))   // rounded-2xl
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)  // shadow-sm
    }
}

// MARK: - 模块项行 (匹配 v0 ModuleItem: title + ProgressRing + % + chevron)
struct ModuleItemView: View {
    let exercise: ExerciseItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 标题 text-[15px]
                Text(exercise.title)
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.primaryText)
                
                Spacer()
                
                // 进度环 size=sm(20pt)
                if exercise.percentage >= 0 {
                    ProgressRingView(
                        percentage: exercise.percentage,
                        size: 20,
                        lineWidth: 2.5
                    )
                }
                
                // 百分比 text-[13px] min-w-[32px] text-right
                Text(progressText)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(width: 32, alignment: .trailing)
                
                // 右箭头 text-muted-foreground/50
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(IOSPressStyle())
    }
    
    private var progressText: String {
        if exercise.percentage > 0 { return "\(exercise.percentage)%" }
        return "—"
    }
}

// MARK: - 进度环组件 (匹配 v0 ProgressRing: SVG circle + 颜色逻辑)
struct ProgressRingView: View {
    let percentage: Int
    var size: CGFloat = 20
    var lineWidth: CGFloat = 2.5
    private var ringColor: Color { ProgressColor.ringColor(percentage: percentage) }
    private var radius: CGFloat { (size - lineWidth) / 2 }
    private var circumference: CGFloat { 2 * .pi * radius }
    
    var body: some View {
        ZStack {
            // 背景圆环 text-muted-foreground/20
            Circle()
                .stroke(AppTheme.secondaryText.opacity(0.15), lineWidth: lineWidth)
            
            // 进度圆环 strokeLinecap=round
            Circle()
                .trim(from: 0, to: CGFloat(max(percentage, 0)) / 100)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: percentage)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - iOS 风格按压按钮样式 (匹配 v0 ios-press)
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
