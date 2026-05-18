import SwiftUI

/// 课程练习列表视图（用于展示单个课时内的练习列表）
struct CourseExerciseListView: View {
    let lesson: Lesson
    @Environment(\.dismiss) private var dismiss
    @State private var selectedExercise: CourseExercise?
    @State private var showingPractice = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 课时信息头部
                    lessonHeader
                    
                    // 练习类型筛选
                    categoryFilter
                    
                    // 练习列表
                    exerciseList
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("练习列表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
            .fullScreenCover(isPresented: $showingPractice) {
                if let exercise = selectedExercise {
                    ExerciseContainerView(exercise: exercise)
                }
            }
        }
    }
    
    // MARK: - 课时头部
    
    private var lessonHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 12) {
                        Label("\(lesson.duration) 分钟", systemImage: "clock")
                        Label("\(lesson.exercises.count) 练习", systemImage: "list.bullet")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 完成状态
                if lesson.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
    
    // MARK: - 分类筛选
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(CourseExerciseCategory.allCases, id: \.self) { category in
                    ExerciseCategoryChip(
                        title: category.rawValue,
                        icon: categoryIcon(for: category),
                        isSelected: false
                    ) {
                        // 筛选逻辑
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    private func categoryIcon(for category: CourseExerciseCategory) -> String {
        switch category {
        case .theory: return "book.fill"
        case .singing: return "mic.fill"
        case .earTraining: return "ear.fill"
        }
    }
    
    // MARK: - 练习列表
    
    private var exerciseList: some View {
        VStack(spacing: 0) {
            ForEach(Array(lesson.exercises.enumerated()), id: \.element.id) { index, exercise in
                ExerciseListRow(exercise: exercise, index: index + 1)
                    .onTapGesture {
                        selectedExercise = exercise
                        showingPractice = true
                    }
                
                if index < lesson.exercises.count - 1 {
                    Divider()
                        .padding(.leading, 60)
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - 练习列表行

struct ExerciseListRow: View {
    let exercise: CourseExercise
    let index: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // 序号
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Text("\(index)")
                    .font(.headline)
                    .foregroundStyle(categoryColor)
            }
            
            // 练习信息
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.title)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Label(exercise.type.rawValue, systemImage: categoryIcon)
                    Text("·")
                    DifficultyIndicator(level: exercise.difficulty)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundStyle(AppColors.accentBlue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
    
    private var categoryColor: Color {
        switch exercise.type {
        case .theory: return .blue
        case .singing: return .green
        case .earTraining: return .orange
        }
    }
    
    private var categoryIcon: String {
        switch exercise.type {
        case .theory: return "book.fill"
        case .singing: return "mic.fill"
        case .earTraining: return "ear.fill"
        }
    }
}

// MARK: - 分类标签

struct ExerciseCategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? .white : AppColors.accentBlue)
            .background(isSelected ? AppColors.accentBlue : AppColors.accentBlue.opacity(0.1))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 难度指示器

struct DifficultyIndicator: View {
    let level: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= level ? "star.fill" : "star")
                    .font(.system(size: 8))
                    .foregroundStyle(star <= level ? .yellow : .gray.opacity(0.3))
            }
        }
    }
}

#Preview {
    CourseExerciseListView(lesson: .sample)
}
