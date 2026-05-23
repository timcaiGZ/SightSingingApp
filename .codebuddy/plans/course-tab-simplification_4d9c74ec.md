---
name: course-tab-simplification
overview: 简化课程 tab 页面层级：移除 CourseChapterView，让 CourseDetailView 直接显示课时列表，与 PracticeTab 保持一致的导航深度。
todos:
  - id: modify-course-tab
    content: 修改 CourseTab.swift，移除 Chapter.navigationDestination
    status: completed
  - id: refactor-course-detail
    content: 重构 CourseDetailView.swift，合并章节头部和课时列表
    status: completed
    dependencies:
      - modify-course-tab
  - id: update-lesson-navigation
    content: 更新课时导航为 fullScreenCover + ExerciseContainerView
    status: completed
    dependencies:
      - refactor-course-detail
  - id: delete-unused-files
    content: 删除 CourseChapterView.swift 和 CourseExerciseListView.swift
    status: completed
    dependencies:
      - modify-course-tab
  - id: update-pbxproj
    content: 更新 project.pbxproj 移除已删除文件引用
    status: completed
    dependencies:
      - delete-unused-files
---

## 用户需求

针对课程 tab，全面简化交互，减少页面层级。参考 PracticeTab 的简化方式，移除中间页面，让用户更快到达练习页。

## 核心功能

- 课程列表展示（保持不变）
- 课程详情页新增课时列表（合并原 CourseChapterView 和 CourseLessonView 功能）
- 课时点击直接进入练习（fullScreenCover + ExerciseContainerView）
- 删除未使用的 CourseExerciseListView

## 页面层级变化

```
之前: CourseTab → CourseDetailView → CourseChapterView → CourseLessonView → 练习页
现在: CourseTab → CourseDetailView → 练习页
```

## 技术方案

### 目录结构

```
SightSingingApp/Views/Tabs/
├── CourseTab.swift          # [MODIFY] 移除 Chapter.navigationDestination
└── CourseDetailView.swift   # [MODIFY] 合并章节头部 + 课时列表

SightSingingApp/Views/Course/
├── CourseChapterView.swift      # [DELETE] 不再需要
└── CourseExerciseListView.swift # [DELETE] 未使用

SightSingingApp.xcodeproj/project.pbxproj # [MODIFY] 移除已删除文件引用
```

### 实施步骤

#### 1. 修改 CourseTab.swift

- 移除 `.navigationDestination(for: Chapter.self)` 导航目标（第 24-26 行）
- 保留 `navigationDestination(for: Lesson.self)` 让课时直接导航到练习页

#### 2. 重构 CourseDetailView.swift

- 合并原 CourseChapterView 的章节头部样式到课程头部区域
- 将课程头部设计改为扁平化 Section Header 样式（参考 PracticeTab）
- 新增课时列表区域，直接显示所有章节下的课时（不再有章节层级）
- 课时行点击直接触发练习（使用 fullScreenCover 展示 ExerciseContainerView）
- 删除 ExercisePracticeView 相关代码，统一使用 ExerciseContainerView

#### 3. 删除废弃文件

- 删除 `CourseChapterView.swift`
- 删除 `CourseExerciseListView.swift`

#### 4. 更新 Xcode 项目引用

- 从 project.pbxproj 移除已删除文件的 PBXFileReference 和 PBXBuildFile 条目

### 设计一致性

- 课程头部：保留图标 + 标题 + 描述 + 统计信息（章节数/课时数/完成度）
- Section Header：使用左侧彩色竖条 + 模块名 + ProgressDots 样式
- 课时行：显示课时图标 + 课时名 + 难度 + 时长 + ProgressDots + 箭头
- 练习启动：使用 fullScreenCover 展示 ExerciseContainerView