import SwiftUI

// MARK: - Tab 2 课程学习 (匹配 v0 原型: 标题28px + CourseCard列表)
struct CourseTab: View {
    @State private var selectedCourse: CourseItemData?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // === 页面标题 28px bold ===
                HStack {
                    Text("课程学习")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // === 课程卡片列表 space-y-3 ===
                VStack(spacing: 12) {
                    ForEach(CourseItemData.allCourses) { course in
                        CourseCardView(course: course) {
                            selectedCourse = course
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 24)
        }
        .background(AppTheme.background)
        .navigationDestination(item: $selectedCourse) { course in
            CourseDetailView(course: course)
        }
    }
}

// MARK: - 课程卡片 (匹配 v0 CourseCard: 彩色顶条 + icon+title+info + ProgressRing lg + ProgressBar)
struct CourseCardView: View {
    let course: CourseItemData
    let onTap: () -> Void
    
    private var percentage: Int {
        course.total > 0 ? Int((Double(course.progress) / Double(course.total)) * 100) : 0
    }
    
    private var statusText: String {
        switch course.status {
        case .notStarted: return "未开始"
        case .inProgress: return "进行中"
        case .completed: return "已完成"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // === 顶部彩色条 h-1 ===
                Rectangle()
                    .fill(course.color)
                    .frame(height: 4)
                
                // === 内容 p-4 ===
                VStack(spacing: 12) {
                    // icon + title(17px semibold) + 课时数/状态(13px)
                    HStack(spacing: 10) {
                        Image(systemName: course.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(course.color)
                        
                        Text(course.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryText)
                        
                        Spacer()
                        
                        // ProgressRing(lg) showPercentage — 右上角
                        ProgressRingView(
                            percentage: percentage,
                            size: 40,
                            lineWidth: 3
                        )
                    }
                    
                    // 课时数 · 状态 text-[13px] muted-foreground mb-3
                    HStack(spacing: 6) {
                        Text("\(course.lessonCount) 课时")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                        
                        Text("·")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                        
                        Text(statusText)
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // ProgressBar(md = h-1.5)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AppTheme.secondaryText.opacity(0.15))
                                .frame(height: 5)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(progressBarColor)
                                .frame(width: geo.size.width * CGFloat(max(percentage, 0)) / 100, height: 5)
                        }
                    }
                    .frame(height: 5)
                    
                    // 进度文本 text-[12px] right muted-foreground
                    HStack {
                        Spacer()
                        Text("\(course.progress)/\(course.total) 课时")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
                .padding(16)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))   // rounded-2xl
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)  // shadow-sm
        }
        .buttonStyle(IOSPressStyle())
    }
    
    private var progressBarColor: Color {
        if percentage >= 80 { return AppTheme.success }
        else if percentage >= 50 { return AppTheme.accent }
        else if percentage > 0 { return AppTheme.warning }
        return AppTheme.secondaryText.opacity(0.3)
    }
}

// MARK: - 课程详情页 (匹配 v0 CourseDetail 占位)
struct CourseDetailView: View {
    let course: CourseItemData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // NavBar 风格导航栏
            HStack {
                Button("← 返回") { dismiss() }
                    .font(.system(size: 17))
                    .foregroundStyle(AppTheme.accent)
                Spacer()
                Text(course.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Color.clear.frame(width: 50)
            }
            .padding(16)
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)
                    
                    // 课程信息卡片
                    VStack(spacing: 12) {
                        Image(systemName: course.icon)
                            .font(.system(size: 40))
                            .foregroundStyle(course.color)
                        
                        Text(course.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(AppTheme.primaryText)
                        
                        Text("\(course.lessonCount) 课时")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    
                    // 章节占位
                    ForEach(0..<min(course.total, 9), id: \.self) { index in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .stroke(index < course.progress ? AppTheme.accent : AppTheme.border, lineWidth: 1.5)
                                    .frame(width: 28, height: 28)
                                
                                if index < course.progress {
                                    Circle()
                                        .fill(AppTheme.accent)
                                        .frame(width: 18, height: 18)
                                } else {
                                    Text("\(index + 1)")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(AppTheme.secondaryText)
                                }
                            }
                            
                            Text("第\(index + 1)课: \(course.title)基础内容")
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.primaryText)
                            
                            Spacer()
                            
                            Image(systemName: index < course.progress ? "checkmark.circle.fill" : "play.circle")
                                .font(.system(size: 20))
                                .foregroundStyle(index < course.progress ? AppTheme.success : AppTheme.secondaryText)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Spacer()
                }
            }
        }
        .background(AppTheme.background)
        .navigationBarHidden(true)
    }
}

// MARK: - 课程数据模型 (匹配 v0 原型数据)
struct CourseItemData: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let lessonCount: Int
    let status: CourseStatus
    let progress: Int
    let total: Int
    
    enum CourseStatus: String {
        case notStarted = "not-started"
        case inProgress = "in-progress"
        case completed = "completed"
    }
    
    static let allCourses: [CourseItemData] = [
        CourseItemData(
            id: "music-theory",
            title: "乐理基础",
            icon: "book",
            color: AppTheme.accent,                   // bg-primary
            lessonCount: 9,
            status: .inProgress,
            progress: 4,
            total: 9
        ),
        CourseItemData(
            id: "sight-singing",
            title: "视唱入门",
            icon: "mic.fill",
            color: AppTheme.Module.melody,            // bg-module-melody
            lessonCount: 5,
            status: .notStarted,
            progress: 0,
            total: 5
        ),
        CourseItemData(
            id: "rhythm-course",
            title: "节奏训练",
            icon: "music.note",
            color: AppTheme.Module.rhythm,            // bg-module-rhythm
            lessonCount: 6,
            status: .notStarted,
            progress: 0,
            total: 6
        ),
        CourseItemData(
            id: "ear-training",
            title: "听力训练",
            icon: "headphones",
            color: AppTheme.Module.pitch,             // bg-module-pitch
            lessonCount: 5,
            status: .notStarted,
            progress: 0,
            total: 5
        )
    ]
}

#Preview { CourseTab() }
