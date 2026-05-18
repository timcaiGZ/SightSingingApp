import Foundation
import SwiftUI
import SwiftData

/// 课程视图模型
@Observable
final class CourseViewModel {
    var courses: [Course] = Course.allCourses
    var selectedCourse: Course?
    var selectedChapter: Chapter?
    var selectedLesson: Lesson?

    /// 根据课程颜色名称获取颜色
    func courseColor(_ colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        default: return .blue
        }
    }

    /// 计算课程进度
    func calculateProgress(for course: Course) -> Double {
        let total = course.totalLessons
        guard total > 0 else { return 0 }
        return Double(course.completedLessons) / Double(total)
    }

    /// 获取课程图标颜色
    func iconColor(for course: Course) -> Color {
        courseColor(course.colorName)
    }

    /// 获取难度星级的颜色
    func difficultyColor(_ difficulty: Int) -> Color {
        switch difficulty {
        case 1: return .green
        case 2: return .mint
        case 3: return .yellow
        case 4: return .orange
        case 5: return .red
        default: return .gray
        }
    }
}
