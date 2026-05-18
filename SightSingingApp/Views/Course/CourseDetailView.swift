import SwiftUI

/// 课程详情页（显示章节列表）
struct CourseDetailView: View {
    let course: Course
    let viewModel: CourseViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 课程头部
                courseHeader

                // 章节列表
                chaptersList
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(course.title)
        .navigationBarTitleDisplayMode(.large)
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

    // MARK: - 章节列表

    private var chaptersList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("课程目录")
                .font(.headline)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(Array(course.chapters.enumerated()), id: \.element.id) { index, chapter in
                    NavigationLink(value: chapter) {
                        ChapterRow(chapter: chapter, index: index + 1, viewModel: viewModel)
                    }
                    .buttonStyle(.plain)

                    if index < course.chapters.count - 1 {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
            .background(Color(.systemBackground))
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

// MARK: - 章节行

struct ChapterRow: View {
    let chapter: Chapter
    let index: Int
    let viewModel: CourseViewModel

    var completedCount: Int {
        chapter.lessons.filter { $0.isCompleted }.count
    }

    /// 获取章节所属课程的颜色
    private var chapterColor: Color {
        viewModel.iconColor(for: chapter)
    }

    var body: some View {
        HStack(spacing: 16) {
            // 章节序号
            ZStack {
                Circle()
                    .fill(chapterColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Text("\(index)")
                    .font(.headline)
                    .foregroundStyle(chapterColor)
            }

            // 章节信息
            VStack(alignment: .leading, spacing: 2) {
                Text(chapter.title)
                    .font(.body)
                    .foregroundStyle(.primary)

                Text("\(chapter.lessons.count) 课时")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 进度
            if completedCount > 0 {
                Text("\(completedCount)/\(chapter.lessons.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CourseDetailView(course: .musicTheoryBasics, viewModel: CourseViewModel())
    }
}
