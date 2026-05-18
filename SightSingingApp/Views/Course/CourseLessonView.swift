import SwiftUI

/// 课时详情页（包含练习入口）
struct CourseLessonView: View {
    let lesson: Lesson
    @State private var showingExercise = false
    @State private var selectedExercise: CourseExercise?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 课时头部
                lessonHeader

                // 课时内容
                contentSection

                // 练习列表
                exercisesSection
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if lesson.isCompleted {
                    Label("已完成", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
        .sheet(isPresented: $showingExercise) {
            if let exercise = selectedExercise {
                ExercisePracticeView(exercise: exercise)
            }
        }
    }

    // MARK: - 课时头部

    private var lessonHeader: some View {
        VStack(spacing: 16) {
            // 状态图标
            ZStack {
                Circle()
                    .fill(lesson.isCompleted ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                    .frame(width: 72, height: 72)

                if lesson.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.blue)
                }
            }

            // 课时信息
            HStack(spacing: 24) {
                Label("\(lesson.duration) 分钟", systemImage: "clock")
                Label("\(lesson.exercises.count) 练习", systemImage: "list.bullet")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            // 完成状态
            Text(lesson.isCompleted ? "已完成" : "未开始")
                .font(.caption)
                .foregroundStyle(lesson.isCompleted ? .green : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background((lesson.isCompleted ? Color.green : Color.gray).opacity(0.1))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
    }

    // MARK: - 课时内容

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("课程内容")
                .font(.headline)
                .padding(.horizontal, 16)

            Text(lesson.content)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
        }
    }

    // MARK: - 练习列表

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("练习")
                .font(.headline)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(Array(lesson.exercises.enumerated()), id: \.element.id) { index, exercise in
                    ExerciseRow(exercise: exercise, index: index + 1)
                        .onTapGesture {
                            selectedExercise = exercise
                            showingExercise = true
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
}

// MARK: - 练习行

struct ExerciseRow: View {
    let exercise: CourseExercise
    let index: Int

    var typeIcon: String {
        switch exercise.type {
        case .theory: return "book.fill"
        case .singing: return "mic.fill"
        case .earTraining: return "ear.fill"
        }
    }

    var typeColor: Color {
        switch exercise.type {
        case .theory: return .blue
        case .singing: return .green
        case .earTraining: return .orange
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // 序号
            Text("\(index)")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            // 类型图标
            ZStack {
                Circle()
                    .fill(typeColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: typeIcon)
                    .font(.body)
                    .foregroundStyle(typeColor)
            }

            // 练习信息
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.title)
                    .font(.body)
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    Text(exercise.type.rawValue)
                    Text("·")
                    DifficultyStars(difficulty: exercise.difficulty)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - 难度星级

struct DifficultyStars: View {
    let difficulty: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= difficulty ? "star.fill" : "star")
                    .font(.system(size: 8))
                    .foregroundStyle(star <= difficulty ? .yellow : .gray.opacity(0.3))
            }
        }
    }
}

// MARK: - 练习实践视图

struct ExercisePracticeView: View {
    let exercise: CourseExercise
    @Environment(\.dismiss) private var dismiss
    @State private var userAnswer: String = ""
    @State private var showHint = false
    @State private var isCompleted = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 练习头部
                    exerciseHeader

                    // 练习内容
                    contentSection

                    // 答题区域
                    answerSection

                    // 完成按钮
                    if !isCompleted {
                        completeButton
                    } else {
                        completionBadge
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(exercise.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var exerciseHeader: some View {
        HStack(spacing: 16) {
            // 类型图标
            ZStack {
                Circle()
                    .fill(exerciseTypeColor.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: exerciseTypeIcon)
                    .font(.title2)
                    .foregroundStyle(exerciseTypeColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.type.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(exercise.title)
                    .font(.title2)
                    .fontWeight(.semibold)

                DifficultyStars(difficulty: exercise.difficulty)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var exerciseTypeIcon: String {
        switch exercise.type {
        case .theory: return "book.fill"
        case .singing: return "mic.fill"
        case .earTraining: return "ear.fill"
        }
    }

    private var exerciseTypeColor: Color {
        switch exercise.type {
        case .theory: return .blue
        case .singing: return .green
        case .earTraining: return .orange
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("练习内容")
                .font(.headline)

            Text(exercise.content)
                .font(.body)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var answerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("你的答案")
                    .font(.headline)

                Spacer()

                Button(showHint ? "隐藏提示" : "显示提示") {
                    showHint.toggle()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            TextEditor(text: $userAnswer)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )

            if showHint {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text(exercise.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var completeButton: some View {
        Button {
            withAnimation {
                isCompleted = true
            }
        } label: {
            Text("完成练习")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(userAnswer.isEmpty)
        .opacity(userAnswer.isEmpty ? 0.5 : 1)
    }

    private var completionBadge: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("练习完成！")
                .font(.headline)
                .foregroundStyle(.green)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CourseLessonView(lesson: .sample)
    }
}
