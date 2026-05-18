---
name: SightSingingApp UI Redesign
overview: 对视唱练耳App进行全面的UI/UX重设计，采用iOS原生简洁风格（纯白背景、清晰分区、SF Symbols线条图标），支持三种谱式切换（六线谱+简谱默认、五线谱可选），六线谱精确标注品位数字，让吉他学习者更易上手。
design:
  styleKeywords:
    - iOS HIG
    - 纯白背景
    - 简洁列表
    - 线条图标
    - 大量留白
    - 分隔线分区
    - 圆角卡片
  fontSystem:
    fontFamily: system-ui
    heading:
      size: 28pt
      weight: .nan
    subheading:
      size: 20pt
      weight: .nan
    body:
      size: 17pt
      weight: .nan
  colorSystem:
    primary:
      - "#007AFF"
    background:
      - "#FFFFFF"
      - "#F2F2F7"
      - "#F9F9F9"
    text:
      - "#000000"
      - "#8E8E93"
      - "#C7C7CC"
    functional:
      - "#34C759"
      - "#FF9500"
      - "#FF3B30"
todos:
  - id: color-theme-refactor
    content: 重构 ColorTheme.swift，简化颜色系统为iOS原生色板，移除渐变预设
    status: completed
  - id: contentview-refactor
    content: 重构 ContentView.swift，更新Tab图标为SF Symbols线条风格
    status: completed
  - id: home-tab-create
    content: 新建 HomeTab.swift，包含今日推荐、快速入口、进度概览组件
    status: completed
    dependencies:
      - color-theme-refactor
  - id: notation-type-enum
    content: 新建 NotationType.swift 枚举，定义五线谱/六线谱/简谱切换逻辑
    status: completed
  - id: notation-switcher
    content: 新建 NotationSwitcher.swift，顶部谱式切换器组件
    status: completed
    dependencies:
      - notation-type-enum
  - id: guitar-tab-view
    content: 重构 GuitarTabView.swift，实现真实吉他谱精度（弦号/品号/品位数字/技法标记）
    status: completed
    dependencies:
      - notation-type-enum
  - id: staff-notation-view
    content: 新建 StaffNotationView.swift，五线谱展示组件
    status: completed
    dependencies:
      - notation-type-enum
  - id: solfege-view
    content: 新建 SolfegeView.swift，简谱展示组件
    status: completed
    dependencies:
      - notation-type-enum
  - id: piano-keyboard-view
    content: 重构 PianoKeyboardView.swift，精简为两行键盘布局
    status: completed
  - id: pitch-meter-view
    content: 新建 PitchMeterView.swift，音准指示器组件
    status: completed
  - id: practice-tab-refactor
    content: 重构 PracticeTab.swift，采用灰色分隔线列表布局
    status: completed
    dependencies:
      - color-theme-refactor
  - id: exercise-detail-view-refactor
    content: 重构 ExerciseDetailView.swift，集成谱式切换器和多谱式展示
    status: completed
    dependencies:
      - notation-switcher
      - guitar-tab-view
      - staff-notation-view
      - solfege-view
  - id: single-note-listening-view-refactor
    content: 重构 SingleNoteListeningView.swift，集成钢琴键盘和谱式切换
    status: completed
    dependencies:
      - piano-keyboard-view
      - notation-switcher
  - id: sight-singing-view-refactor
    content: 重构 SightSingingView.swift，集成谱式展示和音准指示器
    status: completed
    dependencies:
      - notation-switcher
      - guitar-tab-view
      - solfege-view
      - pitch-meter-view
  - id: module-detail-view-refactor
    content: 重构 ModuleDetailView.swift，优化模块内练习列表布局
    status: completed
    dependencies:
      - practice-tab-refactor
  - id: test-tab-optimize
    content: 优化 TestTab.swift，增加诊断测试入口卡片样式
    status: completed
    dependencies:
      - color-theme-refactor
  - id: theory-tab-optimize
    content: 优化 TheoryTab.swift，采用卡片式知识点展示
    status: completed
    dependencies:
      - color-theme-refactor
  - id: profile-tab-optimize
    content: 优化 ProfileTab.swift，增加学习统计可视化
    status: completed
    dependencies:
      - color-theme-refactor
---

## 产品定位

一款面向民谣吉他进阶学习者的视唱练耳App，参考 **Solfeggio（练耳大师）** 的极简 iOS 设计风格，同时差异化支持**六线谱+简谱**双谱式展示，填补市场空白。

### 参考 App: Solfeggio

| 维度 | Solfeggio | 我们的 App |
| --- | --- | --- |
| **目标用户** | 通用音乐学习者 | 民谣吉他进阶学习者 |
| **默认谱式** | 仅五线谱 | 六线谱 + 简谱（可切换五线谱） |
| **六线谱** | 无 | 真实吉他谱：弦号+品位数字+指法 |
| **Tab结构** | 自由练习/课程/乐理/我的 | 参考调整 |
| **课程结构** | 4层：Tab→分类→子课程→练习列表→练习页 | 对齐，内容适配吉他 |


### Solfeggio 核心设计亮点（参考借鉴）

1. **统一练习容器** — 所有题型共用同一页面结构，减少认知负担
2. **三种交互模式** — 选择题/键盘输入/视唱，各司其职
3. **课程体系** — 4层深度结构化学习路径
4. **极简视觉** — 纯白背景、灰色分隔线、iOS HIG规范
5. **进度圆点** — ●○○○○ 简洁直观

## 核心功能需求

### 1. 全谱式支持与切换

- **三种谱式**：五线谱、六线谱、简谱
- **默认展示**：六线谱 + 简谱（面向吉他学习者优化）
- **切换入口**：练习页面顶部切换按钮，支持随时切换
- **六线谱精度**：与传统吉他谱一致，包含弦号、品号、品位数字、演奏技法标记

### 2. 练习页面体系

- **练习首页**：六大模块（音名/音程/和弦/调式/节奏/旋律）分类卡片
- **练习详情页**：谱式展示区 + 答题选项区 + 实时反馈
- **视唱练习页**：谱式展示 + 音频播放 + 音准指示器
- **完成结果页**：得分统计 + 进度可视化

### 3. 设计风格（参考App Store五线谱App）

- **整体风格**：纯白背景、简洁列表分类、iOS HIG规范
- **视觉元素**：简约线条图标、大量留白、12-16pt圆角、淡阴影
- **色彩系统**：iOS系统色为主（#007AFF蓝）、功能色辅助
- **字体规范**：SF Pro Display（标题）+ SF Pro Text（正文）

### 4. Tab导航重构（参考 Solfeggio）

- 底部4个Tab：**练习** / **课程** / **乐理** / **我的**
- SF Symbols线条图标：music.note.list、book.closed、book、person.circle

| Tab | 图标 | 功能定位 |
| --- | --- | --- |
| 练习 | music.note.list | 自由练习入口（快速开始） |
| 课程 | book.closed | 结构化学习路径（核心新增） |
| 乐理 | book | 乐理知识卡片 |
| 我的 | person.circle | 学习统计 + 设置 |


## 页面清单（参考 Solfeggio）

| 页面 | 类型 | 核心功能 | 对应 Solfeggio |
| --- | --- | --- | --- |
| PracticeTab | 重构 | 自由练习入口（快速开始） | 自由练习 |
| **CourseTab** | **新建** | **结构化学习路径** | **课程** |
| TheoryTab | 优化 | 乐理知识卡片列表 | 乐理 |
| ProfileTab | 优化 | 学习统计 + 设置入口 | 我的 |
| ExerciseDetailView | 重构 | 统一练习容器 + 谱式切换 | 练习页 |
| **ExerciseContainerView** | **新建** | **统一练习容器（核心）** | — |
| **MusicKeyboardView** | **新建** | **音符输入键盘** | 键盘输入 |
| SightSingingView | 重构 | 视唱练习 + 音准指示器 | 视唱 |
| ModuleDetailView | 重构 | 模块内练习列表 | 练习列表 |
| **CourseDetailView** | **新建** | **课程详情（章节列表）** | 子课程 |
| **CourseLessonView** | **新建** | **单节课程（复习+测试）** | 小节回顾 |
| StaffNotationView | 新建 | 五线谱组件 | 五线谱 |
| GuitarTabView | 重构 | 六线谱组件（真实精度） | 无（六线谱差异化） |
| SolfegeView | 新建 | 简谱组件 | 无（简谱差异化） |
| NotationSwitcher | 新建 | 谱式切换器 | 无（谱式切换差异化） |


## 技术约束

- SwiftUI + SwiftUI Charts（图表）
- SF Symbols线条图标
- 浅色主题优先（自动跟随系统）
- 支持深色模式适配

## 技术架构

### 技术栈

- **框架**：SwiftUI（iOS 17+）
- **图标**：SF Symbols（线条风格）
- **图表**：SwiftUI Charts
- **数据**：SwiftData（现有）
- **音频**：AVFoundation（现有）

### 目录结构

```
SightSingingApp/
├── App/
│   └── ContentView.swift           # [重构] Tab导航容器（4个Tab）
├── Views/
│   ├── Tabs/
│   │   ├── PracticeTab.swift      # [重构] 自由练习入口
│   │   ├── CourseTab.swift        # [新建] 课程Tab（核心新增）
│   │   ├── TheoryTab.swift        # [优化] 乐理Tab
│   │   └── ProfileTab.swift       # [优化] 我的Tab
│   ├── Practice/                           # 自由练习模块
│   │   ├── ModuleDetailView.swift         # [重构] 模块详情
│   │   ├── ExerciseContainerView.swift    # [新建] 统一练习容器
│   │   ├── ExerciseDetailView.swift       # [重构] 调用容器
│   │   ├── MusicKeyboardView.swift         # [新建] 音符键盘
│   │   ├── SightSingingView.swift         # [重构] 视唱
│   │   └── Components/
│   │       ├── NotationSwitcher.swift      # [新建] 谱式切换器
│   │       ├── StaffNotationView.swift     # [新建] 五线谱
│   │       ├── GuitarTabView.swift          # [重构] 六线谱
│   │       ├── SolfegeView.swift            # [新建] 简谱
│   │       └── PitchMeterView.swift         # [重构] 音准指示器
│   ├── Course/                              # 课程模块（新增）
│   │   ├── CourseTab.swift                  # [新建] 课程Tab
│   │   ├── CourseDetailView.swift           # [新建] 课程详情
│   │   ├── CourseLessonView.swift           # [新建] 单节课程
│   │   └── CourseExerciseListView.swift     # [新建] 课程练习列表
│   └── Test/
│       └── DiagnosticTestView.swift         # [保留] 诊断测试
├── Models/
│   ├── Exercise/
│   │   ├── NotationType.swift               # [新建] 谱式枚举
│   │   └── QuestionBank.swift               # [新建] 题库
│   └── Course/
│       └── CourseModel.swift                # [新建] 课程模型
├── ViewModels/
│   ├── PracticeViewModel.swift              # [扩展] 练习逻辑
│   └── CourseViewModel.swift                 # [新建] 课程逻辑
└── Utilities/
    └── ColorTheme.swift                     # [重构] 简化颜色系统
```

### 组件架构

```
NotationType (枚举: staff/tab/solfege)
    ↓
NotationSwitcher (切换器: 五线谱|六线谱|简谱)
    ↓
NotationDisplayStrategy (策略模式)
    ├── StaffNotationView (五线谱)
    ├── GuitarTabView (六线谱 - 真实精度)
    └── SolfegeView (简谱)
```

### 统一练习容器（参考 Solfeggio 核心设计）

所有题型共用同一容器结构，减少代码重复，统一用户体验：

```
┌────────────────────────────────────────┐
│  ←  返回   题型名称              ⚙️   │  ← 导航栏
├────────────────────────────────────────┤
│  ┌────────────────────────────────┐   │
│  │  ● ● ● ○ ○ ○ ○ ○ ○ ○          │   │  ← 进度圆点
│  │         3 / 10                 │   │
│  └────────────────────────────────┘   │
├────────────────────────────────────────┤
│  Q1: 问题描述...                       │  ← 问题区
├────────────────────────────────────────┤
│                                        │
│           [谱式展示区]                   │  ← 五线谱/六线谱/简谱
│                                        │
├────────────────────────────────────────┤
│  新问题       分解          重听       │  ← 操作栏（三等分）
├────────────────────────────────────────┤
│  请选择                               │  ← 交互区
│  ┌────────────────────────────────┐   │
│  │ 选项A                            │   │
│  ├────────────────────────────────┤   │
│  │ 选项B                            │   │
│  └────────────────────────────────┘   │
└────────────────────────────────────────┘
```

### 三种交互模式（参考 Solfeggio）

| 模式 | 适用题型 | 特征 |
| --- | --- | --- |
| **选择题** | 单音辨认、音程比较/辨认、和弦辨认、调式辨认 | 灰色"请选择" + 白色选项列表 |
| **键盘输入** | 单音/音程/和弦/旋律听写 | 升降号列 + CDEFGAB键 + 功能键 |
| **视唱** | 单音/旋律视唱 | 竖直刻度尺 + 实时游标 + "按着唱"按钮 |


### 六线谱组件设计要点

- 弦号标签（1-6，对应细到粗）
- 品丝竖线（等宽）
- 品位数字标注（0=空弦，数字居中显示）
- 演奏技法标记（圆点/叉号/击勾弦符号）
- 横向滚动支持长乐句

### 谱式切换设计

- ExerciseDetailView/SightSingingView 顶部增加切换器
- 切换时保持题目/旋律数据不变，仅切换展示
- 用户偏好持久化到UserDefaults（默认六线谱+简谱）

## 设计风格

**iOS HIG原生风格**：纯白背景、简洁分区线、列表式布局、底部Tab导航。大量留白，呼吸感强。参考App Store五线谱视唱练耳App的极简专业设计。

## 整体页面结构（参考 Solfeggio）

### 底部Tab设计

```
┌────────────────────────────────────────┐
│                                        │
│            主内容区域                    │
│                                        │
├────────────────────────────────────────┤
│     练习      课程      乐理      我的   │
│      ○        ○        ○        ○     │
└────────────────────────────────────────┘
```

图标：music.note.list / book.closed / book / person.circle（线条风格）

### 练习Tab页面结构

```
┌────────────────────────────────────────┐
│  自由练习                      [设置⚙️]  │
├────────────────────────────────────────┤
│                                        │
│  ═══ 听力训练 ══════════════════════  │
│  ┌──────────────────────────────────┐  │
│  │  单音辨认            ▶ 75%    85分│  │
│  ├──────────────────────────────────┤  │
│  │  空弦音辨认          ▶ —       — │  │
│  ├──────────────────────────────────┤  │
│  │  单音听写            ▶ —       — │  │
│  └──────────────────────────────────┘  │
│                                        │
│  ═══ 音程训练 ══════════════════════  │
│  ...                                   │
└────────────────────────────────────────┘
```

设计要点（参考 Solfeggio）：

- 灰色分隔线替代卡片边框（iOS原生风格）
- **进度圆点** ●○○○○ 简洁直观
- 简洁列表，每项右侧显示进度/分数
- 分类标题用灰色分隔线包裹

### 课程Tab页面结构（新增）

```
┌────────────────────────────────────────┐
│  课程                          [设置⚙️]  │
├────────────────────────────────────────┤
│                                        │
│  ═══ 基础课程 ══════════════════════  │
│  ┌──────────────────────────────────┐  │
│  │  单音 · 小字组到小字二组           │  │
│  │  完成度 ●●○○○  2/5               │  │
│  └──────────────────────────────────┘  │
│                                        │
│  ═══ 音程课程 ══════════════════════  │
│  ┌──────────────────────────────────┐  │
│  │  单音程比较 · 纯一度到大二度        │  │
│  │  进行中 ●○○○○  0/5               │  │
│  ├──────────────────────────────────┤  │
│  │  音程辨认 · 大三度到纯四度         │  │
│  │  待开始 ○○○○○  0/5               │  │
│  └──────────────────────────────────┘  │
│                                        │
│  ═══ 和弦课程 ══════════════════════  │
│  ...                                   │
└────────────────────────────────────────┘
```

### 练习详情页（答题页）结构

```
┌────────────────────────────────────────┐
│  ←  返回   单音辨认              ⚙️    │
├────────────────────────────────────────┤
│  ┌──────────────────────────────────┐  │
│  │  ● ● ● ○ ○ ○ ○ ○ ○ ○           │  │
│  │         3 / 10                   │  │
│  └──────────────────────────────────┘  │
│                                        │
│  请选择你听到的音：                      │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │         [谱式展示区域]             │  │
│  │                                  │  │
│  │   [五线谱/六线谱/简谱 切换显示]     │  │
│  │                                  │  │
│  └──────────────────────────────────┘  │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │  新问题       分解        重听    │  │
│  └──────────────────────────────────┘  │
│                                        │
│  请选择                                 │
│  ┌──────────────────────────────────┐  │
│  │  C                                 │  │
│  ├──────────────────────────────────┤  │
│  │  D                                 │  │
│  ├──────────────────────────────────┤  │
│  │  E                                 │  │
│  ├──────────────────────────────────┤  │
│  │  F                                 │  │
│  └──────────────────────────────────┘  │
│                                        │
└────────────────────────────────────────┘
```

设计要点（参考 Solfeggio）：

- 顶部谱式切换器（pill样式，可点击切换）
- 进度圆点 ●●●○○ 替代进度条
- 操作栏三等分布局（新问题 | 分解 | 重听）
- 选项列表式布局，灰色分隔线

### 视唱练习页结构（参考 Solfeggio）

```
┌────────────────────────────────────────┐
│  ←  返回   单音视唱              ⚙️    │
├────────────────────────────────────────┤
│  ┌──────────────────────────────────┐  │
│  │  ● ● ● ○ ○ ○ ○ ○ ○ ○           │  │
│  │         3 / 10                   │  │
│  └──────────────────────────────────┘  │
│                                        │
│  请演唱你听到的音高：                    │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │  [竖直刻度尺 + 实时游标]          │  │
│  │      │  ← 绿色=准确              │  │
│  │    ════════════════              │  │
│  │   -12      0      +12 (音分)     │  │
│  └──────────────────────────────────┘  │
│                                        │
│       目标音: C  低 12 音分            │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │      [  按着演唱  ]               │  │
│  └──────────────────────────────────┘  │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │  新问题       重听                │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘
```

设计要点（参考 Solfeggio）：

- 竖直刻度尺 + 实时游标显示音准
- 绿色=准确，红色=偏高/低
- "按着演唱"按钮替代播放控制
- 操作栏简化（新问题 | 重听）

### 六线谱组件（真实精度版）

```
┌─────────────────────────────────────────┐
│                                         │
│   6 ┃ e ┃─────────────────────○────────│
│   5 ┃ B ┃─────────────────────●─3─────│
│   4 ┃ G ┃─────○────────────────────────│
│   3 ┃ D ┃─────●─2──────────────────────│
│   2 ┃ A ┃─────●─0──────────────────────│
│   1 ┃ E ┃─●─3──────────────────────────│
│      ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
│        0   1   2   3   4   5   6   7   │
│                                         │
│  品格标记：●=按弦  ○=空弦  数字=品位      │
│  技法标记：h=击弦  p=勾弦  s=滑音        │
└─────────────────────────────────────────┘
```

### 音符输入键盘（新增，参考 Solfeggio）

用于音高听写题型的输入：

```
┌─────────────────────────────────────────┐
│  ┌──┐                                   │
│  │♯ │  ← 升号                           │
│  ├──┤                                   │
│  │♭ │  ← 降号                           │
│  └──┘                                   │
│                                         │
│  ┌────┬────┬────┬────┬────┬────┬────┐  │
│  │ C  │ D  │ E  │ F  │ G  │ A  │ B  │  │
│  └────┴────┴────┴────┴────┴────┴────┘  │
│                                         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  │
│  │   清空   │  │   确认   │  │   重听   │  │
│  └─────────┘  └─────────┘  └─────────┘  │
└─────────────────────────────────────────┘
```

## 实施计划

### 现有代码 vs Solfeggio 差异分析

| 方面 | 现有实现 | Solfeggio | 差异 |
| --- | --- | --- | --- |
| **Tab结构** | 练习/测试/乐理/我的 | 练习/课程/乐理/我的 | ❌ "测试"应为"课程" |
| **练习容器** | 各题型独立实现 | 统一容器 | ❌ 重复代码 |
| **交互模式** | 自定义多种 | 三种统一模式 | ❌ 不统一 |
| **课程模块** | 无 | 4层结构化学习路径 | ❌ 需新增 |
| **六线谱** | 基础版 | 无 | ✅ 已有优势 |
| **视唱功能** | 完整实现 | 完整实现 | ✅ 已完成 |


### 重构优先级

```
Phase 1: Tab结构重构（低风险）
├── ContentView.swift - 调整Tab顺序/名称
├── 删除 TestTab.swift（诊断测试移至练习Tab）
└── 新建 CourseTab.swift

Phase 2: 统一练习容器（核心重构）
├── 新建 ExerciseContainerView.swift
├── 新建 MusicKeyboardView.swift
├── 新建 QuestionBank.swift（题库）
└── 简化 ExerciseDetailView.swift

Phase 3: 谱式组件完善
├── GuitarTabView 完善（品位数字、指法）
├── 新建 StaffNotationView.swift (五线谱)
└── 新建 SolfegeView.swift (简谱)

Phase 4: 课程模块（新增）
├── 新建 CourseTab.swift
├── 新建 CourseDetailView.swift
├── 新建 CourseLessonView.swift
└── 新建 CourseExerciseListView.swift
```

### 需重构/新建文件清单

| 文件 | 操作 | 优先级 |
| --- | --- | --- |
| `ContentView.swift` | 重构 | P1 |
| `TestTab.swift` | 删除 | P1 |
| `PracticeTab.swift` | 重构 | P1 |
| `CourseTab.swift` | 新建 | P1 |
| `ExerciseContainerView.swift` | 新建 | P2 |
| `MusicKeyboardView.swift` | 新建 | P2 |
| `QuestionBank.swift` | 新建 | P2 |
| `ExerciseDetailView.swift` | 重构 | P2 |
| `GuitarTabView.swift` | 重构 | P3 |
| `StaffNotationView.swift` | 新建 | P3 |
| `SolfegeView.swift` | 新建 | P3 |
| `NotationSwitcher.swift` | 新建 | P3 |
| `CourseDetailView.swift` | 新建 | P4 |
| `CourseLessonView.swift` | 新建 | P4 |
| `CourseExerciseListView.swift` | 新建 | P4 |


## 配色方案

### 主色（iOS原生）

- Primary: #007AFF (iOS蓝)
- Success: #34C759 (iOS绿)
- Warning: #FF9500 (iOS橙)
- Error: #FF3B30 (iOS红)

### 背景色

- 页面背景: #FFFFFF (纯白)
- 分组背景: #F2F2F7 (iOS系统灰)
- 卡片背景: #FFFFFF
- 分隔线: #C6C6C8 (iOS标准灰)

### 文字色

- 主要文字: #000000
- 次要文字: #8E8E93
- 占位符: #C7C7CC

## 字体规范

- 大标题: 34pt Bold (SF Pro Display)
- 标题1: 28pt Bold
- 标题2: 22pt Bold
- 标题3: 20pt Semibold
- 正文: 17pt Regular
- 副标题: 15pt Regular
- 注释: 13pt Regular
- 标签: 12pt Medium