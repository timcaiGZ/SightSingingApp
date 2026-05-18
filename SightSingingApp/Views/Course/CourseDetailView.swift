import SwiftUI

/// 课程详情页（直接显示课时列表，点击进入练习）
struct CourseDetailView: View {
    let course: Course
    let viewModel: CourseViewModel
    
    @State private var showingExercise = false
    @State private var selectedLesson: Lesson?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 课程头部
                courseHeader

                // 课时列表
                lessonsList
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(course.title)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingExercise) {
            if let lesson = selectedLesson {
                ExerciseContainerView(
                    exercise: lesson.exercises.first ?? CourseExercise(
                        id: lesson.id,
                        title: lesson.title,
                        type: .theory,
                        difficulty: 1,
                        description: lesson.content,
                        content: lesson.content
                    )
                )
            }
        }

    // MARK: - 课程头部

    private var courseHeader: some View {
        VStack(spacing: 16) {
            // 图标
            ZStack {
                Circle()
                    .fill(viewModel.iconColor(for: course).opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: course.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(viewModel.iconColor(for: course))
            }

            // 描述
            Text(course.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            // 统计
            HStack(spacing: 32) {
                StatItem(value: "\(course.chapters.count)", label: "章节")
                StatItem(value: "\(course.totalLessons)", label: "课时")
                StatItem(value: "\(Int(viewModel.calculateProgress(for: course) * 100))%", label: "完成")
            }

            // 进度条
            VStack(spacing: 4) {
                ProgressView(value: viewModel.calculateProgress(for: course))
                    .tint(viewModel.iconColor(for: course))

                Text("\(course.completedLessons)/\(course.totalLessons) 课时完成")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }

    // MARK: - 课时列表

    private var lessonsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("课程目录")
                .font(.headline)
                .padding(.horizontal, 16)

            VStack(spacing: 16) {
                ForEach(Array(course.chapters.enumerated()), id: \.element.id) { chapterIndex, chapter in
                    VStack(alignment: .leading, spacing: 0) {
                        // 章节标题
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(viewModel.iconColor(for: course).opacity(0.15))
                                    .frame(width: 32, height: 32)
                                
                                Text("\(chapterIndex + 1)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(viewModel.iconColor(for: course))
                            }
                            
                            Text(chapter.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(AppColors.primaryText)
                            
                            Spacer()
                            
                            Text("\(chapter.lessons.count) 课时")
                                .font(.caption)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        
                        // 课时列表
                        ForEach(Array(chapter.lessons.enumerated()), id: \.element.id) { lessonIndex, lesson in
                            LessonRow(lesson: lesson, index: lessonIndex + 1)
                                .onTapGesture {
                                    selectedLesson = lesson
                                    showingExercise = true
                                }
                            
                            if lessonIndex < chapter.lessons.count - 1 {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - 统计项

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 课时行

struct LessonRow: View {
    let lesson: Lesson
    let index: Int

    var body: some View {
        HStack(spacing: 12) {
            // 序号
            Text("\(index)")
                .font(.caption)
                .foregroundStyle(AppColors.tertiaryText)
                .frame(width: 20)
            
            // 课时状态图标
            ZStack {
                Circle()
                    .fill(lesson.isCompleted ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "play.circle.fill")
                    .font(.body)
                    .foregroundStyle(lesson.isCompleted ? .green : .blue)
            }
            
            // 课时信息
            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.title)
                    .font(.body)
                    .foregroundStyle(AppColors.primaryText)
                
                HStack(spacing: 8) {
                    Label("\(lesson.duration)分钟", systemImage: "clock")
                    Label("\(lesson.exercises.count)练习", systemImage: "list.bullet")
                }
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
            }
            
            Spacer()
            
            // 进入练习
            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundStyle(AppColors.accentBlue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CourseDetailView(course: .musicTheoryBasics, viewModel: CourseViewModel())
    }
}
