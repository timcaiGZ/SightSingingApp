import SwiftUI

/// Tab 2 — 课程列表首页（4层深度结构入口）
struct CourseTab: View {
    @State private var viewModel = CourseViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 学习进度概览
                    progressOverview

                    // 课程列表
                    courseList
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("课程")
            .navigationDestination(for: Course.self) { course in
                CourseDetailView(course: course, viewModel: viewModel)
            }
            .navigationDestination(for: Chapter.self) { chapter in
                CourseChapterView(chapter: chapter, viewModel: viewModel)
            }
            .navigationDestination(for: Lesson.self) { lesson in
                CourseLessonView(lesson: lesson)
            }
        }
    }

    // MARK: - 学习进度概览

    private var progressOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("学习进度")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)

            HStack(spacing: 16) {
                ForEach(viewModel.courses) { course in
                    ProgressCard(course: course, viewModel: viewModel)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - 课程列表

    private var courseList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("全部课程")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)

            VStack(spacing: 12) {
                ForEach(viewModel.courses) { course in
                    NavigationLink(value: course) {
                        CourseCard(course: course, viewModel: viewModel)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - 进度卡片

struct ProgressCard: View {
    let course: Course
    let viewModel: CourseViewModel

    var body: some View {
        VStack(spacing: 8) {
            // 圆形进度
            ZStack {
                Circle()
                    .stroke(viewModel.iconColor(for: course).opacity(0.2), lineWidth: 6)
                    .frame(width: 56, height: 56)

                Circle()
                    .trim(from: 0, to: viewModel.calculateProgress(for: course))
                    .stroke(viewModel.iconColor(for: course), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))

                Image(systemName: course.icon)
                    .font(.title3)
                    .foregroundStyle(viewModel.iconColor(for: course))
            }

            Text(course.title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 课程卡片

struct CourseCard: View {
    let course: Course
    let viewModel: CourseViewModel

    var body: some View {
        HStack(spacing: 16) {
            // 图标
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(viewModel.iconColor(for: course).opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: course.icon)
                    .font(.title2)
                    .foregroundStyle(viewModel.iconColor(for: course))
            }

            // 内容
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(course.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                // 进度条
                ProgressView(value: viewModel.calculateProgress(for: course))
                    .tint(viewModel.iconColor(for: course))
                    .padding(.top, 4)

                HStack {
                    Text("\(course.chapters.count) 章节")
                    Text("·")
                    Text("\(course.totalLessons) 课时")
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    CourseTab()
}
