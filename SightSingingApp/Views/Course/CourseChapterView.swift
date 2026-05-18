import SwiftUI

/// 章节列表页（显示课时列表）
struct CourseChapterView: View {
    let chapter: Chapter
    let viewModel: CourseViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 章节头部
                chapterHeader

                // 课时列表
                lessonsList
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(chapter.title)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Lesson.self) { lesson in
            CourseLessonView(lesson: lesson)
        }
    }

    // MARK: - 章节头部

    private var chapterHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.system(size: 40))
                .foregroundStyle(viewModel.iconColor(for: chapter))

            Text("\(chapter.lessons.count) 个课时")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
    }

    // MARK: - 课时列表

    private var lessonsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("课时内容")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            VStack(spacing: 0) {
                ForEach(Array(chapter.lessons.enumerated()), id: \.element.id) { index, lesson in
                    NavigationLink(value: lesson) {
                        LessonRow(lesson: lesson, index: index + 1, viewModel: viewModel)
                    }
                    .buttonStyle(.plain)

                    if index < chapter.lessons.count - 1 {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - 课时行

struct LessonRow: View {
    let lesson: Lesson
    let index: Int
    let viewModel: CourseViewModel

    var body: some View {
        HStack(spacing: 16) {
            // 状态图标 - 使用设计要求的圆点样式 ●○○○○
            progressDots

            // 课时信息
            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.title)
                    .font(.body)
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    Label("\(lesson.duration) 分钟", systemImage: "clock")
                    Label("\(lesson.exercises.count) 练习", systemImage: "list.bullet")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    /// 设计要求的进度圆点样式 ●○○○○
    private var progressDots: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { dotIndex in
                Circle()
                    .fill(dotIndex < lessonProgressDots ? viewModel.iconColor(for: lesson) : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }

    /// 根据课时完成状态计算圆点数（0-5）
    private var lessonProgressDots: Int {
        lesson.isCompleted ? 5 : 0
    }
}

extension CourseViewModel {
    /// 根据课时获取颜色（通过章节找到所属课程）
    func iconColor(for lesson: Lesson) -> Color {
        if let course = courses.first(where: { course in
            course.chapters.contains { chapter in
                chapter.lessons.contains { $0.id == lesson.id }
            }
        }) {
            return iconColor(for: course)
        }
        return .blue
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CourseChapterView(
            chapter: Course.musicTheoryBasics.chapters[0],
            viewModel: CourseViewModel()
        )
    }
}
