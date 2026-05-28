import SwiftUI

// MARK: - Tab 2 课程学习 (匹配 v0 原型: 标题28px + CourseCard列表)
struct CourseTab: View {
    @State private var selectedCourse: CourseItemData?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // === 固定头部 ===
                HStack {
                    Text("课程学习")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .background(AppTheme.background)
                
                // === 滚动内容：课程卡片列表 ===
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(CourseItemData.allCourses) { course in
                            CourseCardView(course: course) {
                                selectedCourse = course
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .background(AppTheme.background)
            .navigationDestination(item: $selectedCourse) { course in
                CourseDetailView(course: course)
            }
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

// MARK: - 课程详情页 (扁平化: 课程头部 + 章节分段 + 课时列表 → fullScreenCover 练习)
struct CourseDetailView: View {
    let course: CourseItemData
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLesson: CourseLesson?
    
    private var percentage: Int {
        course.total > 0 ? Int((Double(course.progress) / Double(course.total)) * 100) : 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // NavBar
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
                VStack(spacing: 20) {
                    // === 课程头部卡片: 图标 + 标题 + 章节数/课时数 + 完成度 ===
                    VStack(spacing: 12) {
                        Image(systemName: course.icon)
                            .font(.system(size: 40))
                            .foregroundStyle(course.color)
                        
                        Text(course.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(AppTheme.primaryText)
                        
                        HStack(spacing: 16) {
                            Label("\(course.chapters.count) 章节", systemImage: "rectangle.grid.1x2")
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.secondaryText)
                            Label("\(course.lessonCount) 课时", systemImage: "list.bullet")
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.secondaryText)
                            Label("\(percentage)%", systemImage: "chart.bar")
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.accent)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // === 章节分段 + 课时列表 ===
                    ForEach(course.chapters) { chapter in
                        VStack(spacing: 0) {
                            // Section Header: 左侧彩色竖条 + 章节名 + 课时数 + 进度圆点
                            ChapterSectionHeaderView(
                                chapter: chapter,
                                color: course.color,
                                progress: chapter.completedCount,
                                total: chapter.lessons.count
                            )
                            
                            // 课时行列表
                            VStack(spacing: 0) {
                                ForEach(Array(chapter.lessons.enumerated()), id: \.element.id) { idx, lesson in
                                    LessonRowView(
                                        lesson: lesson,
                                        index: idx + 1,
                                        color: course.color,
                                        onTap: { selectedLesson = lesson }
                                    )
                                    
                                    if idx < chapter.lessons.count - 1 {
                                        Divider().padding(.leading, 16)
                                    }
                                }
                            }
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer().frame(height: 24)
                }
            }
        }
        .background(AppTheme.background)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $selectedLesson) { lesson in
            ExerciseContainerView(
                exercise: ExerciseItem(
                    id: lesson.id,
                    title: lesson.title,
                    mode: .multipleChoice,
                    percentage: lesson.isCompleted ? 100 : 0
                ),
                moduleId: course.id
            )
        }
    }
}

// MARK: - 章节 Section Header (左侧彩色竖条 + 章节名 + 进度)
struct ChapterSectionHeaderView: View {
    let chapter: CourseChapter
    let color: Color
    let progress: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 10) {
            // 左侧彩色竖条
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 4, height: 20)
            
            Text(chapter.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.primaryText)
            
            Spacer()
            
            Text("\(progress)/\(total)")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.secondaryText)
            
            ProgressDotsRow(total: total, current: progress, color: color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - 课时行 (图标 + 编号 + 名称 + 难度 + 时长 + 进度 + 箭头)
struct LessonRowView: View {
    let lesson: CourseLesson
    let index: Int
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 课时编号图标
                ZStack {
                    Circle()
                        .fill(lesson.isCompleted ? color : color.opacity(0.12))
                        .frame(width: 28, height: 28)
                    
                    if lesson.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(index)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(color)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(lesson.title)
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.primaryText)
                    
                    HStack(spacing: 6) {
                        Text(lesson.difficulty)
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.secondaryText)
                        Text("·")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.tertiaryText)
                        Text(lesson.duration)
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
                
                Spacer()
                
                // 进度指示
                if lesson.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.success)
                } else {
                    ProgressDotsRow(
                        total: 5,
                        current: Int.random(in: 0...4),
                        color: color
                    )
                    .scaleEffect(0.7)
                }
                
                // 右箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(IOSPressStyle())
    }
}


// MARK: - 课程数据模型 (匹配 v0 原型 + v2.2 章节/课时结构)
struct CourseItemData: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let lessonCount: Int
    let status: CourseStatus
    let progress: Int
    let total: Int
    let chapters: [CourseChapter]
    
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
            color: AppTheme.accent,
            lessonCount: 9,
            status: .inProgress,
            progress: 4,
            total: 9,
            chapters: [
                CourseChapter(id: "mt-ch1", title: "音符与音名", lessons: [
                    CourseLesson(id: "mt-l1", title: "认识音符", difficulty: "入门", duration: "5min", isCompleted: true),
                    CourseLesson(id: "mt-l2", title: "音名与唱名", difficulty: "入门", duration: "5min", isCompleted: true),
                    CourseLesson(id: "mt-l3", title: "全音与半音", difficulty: "基础", duration: "8min", isCompleted: true),
                ]),
                CourseChapter(id: "mt-ch2", title: "节奏与节拍", lessons: [
                    CourseLesson(id: "mt-l4", title: "音符时值入门", difficulty: "基础", duration: "8min", isCompleted: true),
                    CourseLesson(id: "mt-l5", title: "节拍与拍号", difficulty: "基础", duration: "7min", isCompleted: false),
                    CourseLesson(id: "mt-l6", title: "常用节奏型", difficulty: "基础", duration: "10min", isCompleted: false),
                ]),
                CourseChapter(id: "mt-ch3", title: "进阶概念", lessons: [
                    CourseLesson(id: "mt-l7", title: "休止符与延长", difficulty: "进阶", duration: "8min", isCompleted: false),
                    CourseLesson(id: "mt-l8", title: "附点与连线", difficulty: "进阶", duration: "7min", isCompleted: false),
                    CourseLesson(id: "mt-l9", title: "复杂节奏综合", difficulty: "进阶", duration: "10min", isCompleted: false),
                ])
            ]
        ),
        CourseItemData(
            id: "sight-singing",
            title: "视唱入门",
            icon: "mic.fill",
            color: AppTheme.Category.singing,
            lessonCount: 5,
            status: .notStarted,
            progress: 0,
            total: 5,
            chapters: [
                CourseChapter(id: "ss-ch1", title: "单音视唱", lessons: [
                    CourseLesson(id: "ss-l1", title: "自然音阶练习", difficulty: "入门", duration: "5min"),
                    CourseLesson(id: "ss-l2", title: "C大调单音训练", difficulty: "入门", duration: "6min"),
                    CourseLesson(id: "ss-l3", title: "级进音程视唱", difficulty: "基础", duration: "8min"),
                ]),
                CourseChapter(id: "ss-ch2", title: "旋律入门", lessons: [
                    CourseLesson(id: "ss-l4", title: "简单旋律视唱", difficulty: "基础", duration: "10min"),
                    CourseLesson(id: "ss-l5", title: "跨音程旋律", difficulty: "进阶", duration: "12min"),
                ])
            ]
        ),
        CourseItemData(
            id: "rhythm-course",
            title: "节奏训练",
            icon: "music.note",
            color: AppTheme.Category.rhythm,
            lessonCount: 6,
            status: .notStarted,
            progress: 0,
            total: 6,
            chapters: [
                CourseChapter(id: "rc-ch1", title: "基础节奏", lessons: [
                    CourseLesson(id: "rc-l1", title: "四分音符节奏", difficulty: "入门", duration: "5min"),
                    CourseLesson(id: "rc-l2", title: "八分音符节奏", difficulty: "入门", duration: "6min"),
                    CourseLesson(id: "rc-l3", title: "混合节奏基础", difficulty: "基础", duration: "8min"),
                ]),
                CourseChapter(id: "rc-ch2", title: "进阶节奏型", lessons: [
                    CourseLesson(id: "rc-l4", title: "十六分音符", difficulty: "进阶", duration: "8min"),
                    CourseLesson(id: "rc-l5", title: "切分节奏", difficulty: "进阶", duration: "10min"),
                    CourseLesson(id: "rc-l6", title: "三连音入门", difficulty: "进阶", duration: "10min"),
                ])
            ]
        ),
        CourseItemData(
            id: "ear-training",
            title: "听力训练",
            icon: "headphones",
            color: AppTheme.Category.pitch,
            lessonCount: 5,
            status: .notStarted,
            progress: 0,
            total: 5,
            chapters: [
                CourseChapter(id: "et-ch1", title: "单音听力", lessons: [
                    CourseLesson(id: "et-l1", title: "音高辨别基础", difficulty: "入门", duration: "5min"),
                    CourseLesson(id: "et-l2", title: "同音高色彩辨认", difficulty: "入门", duration: "6min"),
                ]),
                CourseChapter(id: "et-ch2", title: "音程与和弦", lessons: [
                    CourseLesson(id: "et-l3", title: "音程听辨入门", difficulty: "基础", duration: "10min"),
                    CourseLesson(id: "et-l4", title: "和弦色彩辨认", difficulty: "基础", duration: "10min"),
                    CourseLesson(id: "et-l5", title: "和声进行听辨", difficulty: "进阶", duration: "12min"),
                ])
            ]
        ),
        CourseItemData(
            id: "harmony-analysis",
            title: "和声分析实战",
            icon: "arrow.triangle.branch",
            color: Color(hex: "0EA5E9"),
            lessonCount: 10,
            status: .notStarted,
            progress: 0,
            total: 10,
            chapters: [
                CourseChapter(id: "ha-ch1", title: "TSD功能组认知", lessons: [
                    CourseLesson(id: "ha-l1", title: "T主功能：音乐的家", difficulty: "入门", duration: "8min"),
                    CourseLesson(id: "ha-l2", title: "S下属功能：出发的起点", difficulty: "入门", duration: "8min"),
                    CourseLesson(id: "ha-l3", title: "D属功能：回家的欲望", difficulty: "基础", duration: "10min"),
                ]),
                CourseChapter(id: "ha-ch2", title: "TSD运动方向", lessons: [
                    CourseLesson(id: "ha-l4", title: "正格终止 D→T 最强解决", difficulty: "基础", duration: "10min"),
                    CourseLesson(id: "ha-l5", title: "变格终止 S→T 阿门终止", difficulty: "基础", duration: "10min"),
                    CourseLesson(id: "ha-l6", title: "趋向进行 S→D 最常见走向", difficulty: "进阶", duration: "12min"),
                    CourseLesson(id: "ha-l7", title: "欺骗终止 D→S 意外之美", difficulty: "进阶", duration: "12min"),
                ]),
                CourseChapter(id: "ha-ch3", title: "和弦进行规律与实战", lessons: [
                    CourseLesson(id: "ha-l8", title: "大调每级和弦的常见下一步", difficulty: "进阶", duration: "15min"),
                    CourseLesson(id: "ha-l9", title: "小调和声进行的情绪设计", difficulty: "进阶", duration: "15min"),
                    CourseLesson(id: "ha-l10", title: "名曲和声分析：卡农/Let It Be", difficulty: "综合", duration: "20min"),
                ])
            ]
        )
    ]
}

#Preview { CourseTab() }
