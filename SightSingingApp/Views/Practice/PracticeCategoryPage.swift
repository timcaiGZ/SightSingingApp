import SwiftUI

// MARK: - 练习分类详情页 (匹配 v0 PracticeCategoryPage)
struct PracticeCategoryPage: View {
    let category: PracticeCategoryData
    @Environment(\.dismiss) private var dismiss
    @State private var selectedExercise: PracticeExerciseData?
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                        Text("返回")
                            .font(.system(size: 15))
                    }
                    .foregroundStyle(AppTheme.accent)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(AppTheme.background.opacity(0.95))
            .overlay(alignment: .bottom) {
                Rectangle().fill(AppTheme.border).frame(height: 0.5)
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    // 分类头部图标 + 标题
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(category.color)
                                .frame(width: 48, height: 48)
                            Image(systemName: category.systemImage)
                                .font(.system(size: 22))
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(category.title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(AppTheme.primaryText)
                                Text(category.subtitle)
                                    .font(.system(size: 12))
                                    .foregroundStyle(AppTheme.secondaryText)
                                    .padding(.horizontal, 8).padding(.vertical, 2)
                                    .background(AppTheme.secondaryBg)
                                    .clipShape(Capsule())
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 8)
                    
                    Text(category.description)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16).padding(.bottom, 24)
                    
                    // 练习项列表
                    VStack(spacing: 8) {
                        ForEach(Array(category.exercises.enumerated()), id: \.element.id) { idx, exercise in
                            ExerciseRowView(
                                index: idx + 1,
                                exercise: exercise,
                                color: category.color,
                                onTap: { selectedExercise = exercise }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 32)
            }
        }
        .background(AppTheme.background)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $selectedExercise) { exercise in
            if exercise.id == "single-note" {
                // 单音辨认使用专用页面（匹配 v0 SingleNoteExercise）
                SingleNoteListeningView()
            } else if exercise.id == "quarter-eighth" {
                // 四分音符节奏直接跳转到 15 组练习页面
                RhythmPracticeView(
                    exercise: ExerciseItem(
                        id: exercise.id,
                        title: exercise.title,
                        mode: .keyboardInput,
                        percentage: exercise.progress
                    ),
                    moduleId: category.id
                )
            } else if exercise.hasLevels {
                ExerciseLevelsPage(exercise: exercise, categoryId: category.id, color: category.color)
            } else {
                ExerciseContainerView(
                    exercise: ExerciseItem(
                        id: exercise.id,
                        title: exercise.title,
                        mode: .keyboardInput,
                        percentage: exercise.progress
                    ),
                    moduleId: category.id
                )
            }
        }
    }
}

// MARK: - 练习项行
struct ExerciseRowView: View {
    let index: Int
    let exercise: PracticeExerciseData
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 序号
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.secondaryBg)
                        .frame(width: 32, height: 32)
                    Text("\(index)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryText)
                }
                
                // 内容
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(exercise.title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AppTheme.primaryText)
                        if exercise.hasLevels, let count = exercise.levelCount {
                            Text("\(count)组")
                                .font(.system(size: 11))
                                .foregroundStyle(AppTheme.secondaryText)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(AppTheme.secondaryBg)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    Text(exercise.description)
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(1)
                    
                    // 进度条
                    HStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppTheme.secondaryBg).frame(height: 4)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(color)
                                    .frame(width: geo.size.width * CGFloat(exercise.progress) / 100, height: 4)
                            }
                        }
                        .frame(height: 4)
                        Text("\(exercise.progress)%")
                            .font(.system(size: 10))
                            .foregroundStyle(AppTheme.secondaryText)
                            .frame(width: 28, alignment: .trailing)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText.opacity(0.5))
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(IOSPressStyle())
    }
}

#Preview {
    NavigationStack {
        PracticeCategoryPage(category: PracticeCategoryData.allCategories[0])
    }
}
