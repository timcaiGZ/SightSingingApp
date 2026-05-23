# SightSingingApp V2.2 差距清单

**对照基准**: [spec-v2.2.md](./spec-v2.2.md)  
**代码快照**: 2026-05-20  
**图例**: ✅ 基本满足 · 🟡 部分实现 · ❌ 未实现 / 与规格冲突

---

## 总览

| 验收项 | 状态 | 说明 |
|--------|------|------|
| AC1 导航 | ❌ | 仅 4 Tab，但含「课程」、缺「测试」 |
| AC2 练习流程 | 🟡 | 有容器与部分页面，交互与题库未对齐 |
| AC3 谱式切换 | 🟡 | 有切换器组件，临时/全局逻辑未接通 |
| AC4 视唱评分 | 🟡 | 有 PitchMeter / SightSinging，公式与 UI 未完全对齐 |
| AC5 键盘输入 | ❌ | 简版键盘，缺三列布局与谱面实时反馈 |
| AC6 乐理系统 | ❌ | 网格+搜索，非手风琴 6 类 25 点 |
| AC7 测试系统 | 🟡 | `TestTab` 存在但未接入 Tab；UI 为诊断测试，非规格列表 |
| AC8 持久化 | 🟡 | SwiftData 有部分模型，练习/测试最高分未完整 |
| AC9 空状态 | ❌ | 多数未实现 |
| AC10 性能 | ⬜ | 需实测 |

**架构性冲突（优先处理）**

1. `ContentView`：应为 **练习 / 乐理 / 测试 / 我的**，现为 **练习 / 课程 / 乐理 / 我的**
2. `ExerciseModule` / `ExerciseType`：规格为 **听力/视唱/节奏/音程/和弦** + R2.6 子项；代码为 **音名/音程/和弦/调式/节奏/旋律** + 吉他专项练习名
3. `QuestionBank`：有 600+ 静态题，但 **无** `random(for: exerciseId)` 与 `ExerciseQuestion` 统一模型

---

## AC1 · 导航

| 需求 | 状态 | 代码位置 / 差距 |
|------|------|----------------|
| R1.1 四 Tab 顺序：练习/乐理/测试/我的 | ❌ | `ContentView.swift` 含 `CourseTab`，无 `TestTab` |
| R1.2 SF Symbols 图标 | 🟡 | 练习/乐理/我的正确；课程用 `book.closed`（应移除） |
| R1.3 激活色 #3B82F6 / 非激活 #94A3B8 | 🟡 | `ColorTheme.swift` 有深蓝主题，Tab  tint 未按 spec 固定 |
| R1.4 默认「练习」Tab | ✅ | `TabView` 第一项为 `PracticeTab` |
| 课程模块移除 (V2.1) | ❌ | `Views/Tabs/CourseTab.swift`、`Views/Course/*` 仍存在且占 Tab 位 |

**建议改动**: 更新 `ContentView`；课程相关视图移出 Tab 或删除；挂载 `TestTab`。

---

## AC2 · 练习流程

| 需求 | 状态 | 代码位置 / 差距 |
|------|------|----------------|
| R2.1 5 大 ModuleCard + 4px 彩色条 | 🟡 | `ModuleCard.swift` 有组件；`PracticeTab` 用 Section 列表非 5 卡片 |
| R2.2 Progress Ring | ❌ | 使用 `ProgressDots` / 文字百分比，无圆环 |
| R2.3 Ring 颜色规则 | ❌ | 未实现 |
| R2.6 练习子项与模式表 | ❌ | `ExerciseType` 为 24 个吉他向练习，与 spec 表不一致 |
| R3.1 谱式胶囊 + 临时覆盖 | ❌ | `ExerciseContainerView` 使用 `.constant(.staff)`，未读 @AppStorage |
| R3.2 三态进度圆点 + 动态 Y | 🟡 | 有 `progressDots`，`totalQuestions` 硬编码 10 |
| R3.4 `Q{n}：{questionText}` | ❌ | 未统一格式 |
| R3.5 文字操作行（无背景蓝字） | 🟡 | 有 `actionBar`，样式为图标+圆形底 |
| R3.6 bottomContent 插槽 | ❌ | 未抽象插槽，模式 UI 内嵌 |
| R3.8 完成弹层 | ❌ | 无「再来一轮」/ 正确率弹层 |
| R4.1 AudioPromptCard | ❌ | 无此组件 |
| R4.1.4–1.6 选项锁定 + 下一题 | 🟡 | `ExerciseContainerView` 有 `showFeedback`，流程不完整 |
| R4.1.7 新问题 = 下一题 | ❌ | 未区分状态 |
| R11 题目来自 QuestionBank.random | ❌ | 容器内硬编码选项/样本谱面 |

**相关文件**: `PracticeTab.swift`, `ExerciseContainerView.swift`, `ExerciseDetailView.swift`, `SingleNoteListeningView.swift`, `Models/Exercise/*`

---

## AC3 · 谱式切换

| 需求 | 状态 | 代码位置 / 差距 |
|------|------|----------------|
| R5.1 我的 → 谱式单选 + @AppStorage | 🟡 | `NotationType.swift`、`ProfileTab` 需确认是否有完整单选 UI |
| R5.2 练习页临时 State | ❌ | 切换器绑定 `.constant`，会写死 |
| R5.3–5.5 六线谱+简谱 / 五线谱 | 🟡 | `GuitarTabView`, `StaffNotationView`, `SolfegeView`, `NotationDisplayView` 已有基础 |
| R5.4 技法标记 h/p//b/~ /x | 🟡 | `GuitarTabNote.technique` 存在，展示待核对 |
| R5.6 键盘输入谱面实时渲染 | ❌ | `MusicKeyboardView` 用文本预览，非谱面 |

---

## AC4 · 视唱评分

| 需求 | 状态 | 代码位置 / 差距 |
|------|------|----------------|
| R4.3.1 96pt 圆形目标音 | 🟡 | `SightSingingView` / `PitchMeterView` 样式需对照 |
| R4.3.2 ±50 音分 | 🟡 | `PitchMeterView` 注释为 ±50；需核对 `thumbPosition(scale:)` |
| R4.3.3 三态游标色 | 🟡 | 有部分颜色逻辑，阈值需对齐 ≤10 / ≤20 |
| R4.3.6 SingButton 80pt + ping | 🟡 | `PitchMeterView` 含 `SingButton`，需对照尺寸/动画 |
| R4.3.7 pitchScore 公式 | ❌ | `SightSingingViewModel` 需核对是否 `max(0, 50 - avg|cents|)` |
| R4.3.7 rhythmScore 随机占位 | ⬜ | V2.x 允许随机，需确认实现 |
| R4.3.10 评分页结构 | 🟡 | `SightSingingResultView`, `ScoreResultView` 存在，按钮文案需对齐 |
| R10.2 YIN 算法 | ❌ | `PitchDetector` 注释为自相关法，非 YIN |
| R10.5 麦克风被拒 UI | ❌ | 需核对 `SightSingingView` 权限分支 |

---

## AC5 · 键盘输入

| 需求 | 状态 | 代码位置 / 差距 |
|------|------|----------------|
| R4.2.2 三列键盘（6 升降号 + 3×4 网格 + 退格/完成） | ❌ | `MusicKeyboardView` 仅 ♯♭ + 7 音 + 清空/确认 |
| R4.2.3 升降号附加后重置 | ❌ | |
| R4.2.4 退格删最后一个 | ❌ | 仅有「清空」 |
| R4.2.5 颜色 #D1D5DB / #ADB5BD | ❌ | 使用 systemGray6 |
| R4.2.6–8 谱面反馈 + 完成校验 | ❌ | |

---

## AC6 · 乐理系统

| 需求 | 状态 | 代码位置 / 差距 |
|------|------|----------------|
| R6.1 手风琴 6 分类 | ❌ | `TheoryTab` 为 searchable 卡片网格 |
| R6.2 初始仅「基础乐理」展开 | ❌ | |
| R6.7 25 个知识点清单 | ❌ | `TheoryViewModel` / `TheoryTopic` 数据需重构 |
| R6.5 SeventhChordsDetailView | ❌ | 无 12 调 + 顺阶七和弦表 |
| R6.6 CircleOfFifthsView | ❌ | 无五度圈组件 |
| R12 ChordDiagramView Canvas | 🟡 | `GuitarChordDiagram` 在 `GuitarTabView.swift`，非独立 Canvas 组件 |

---

## AC7 · 测试系统

| 需求 | 状态 | 代码位置 / 差距 |
|------|------|----------------|
| R7.1 顶部 3 格统计 | ❌ | `TestTab` 为单张诊断入口卡 |
| R7.2 测试列表 + 时限/最高分 | ❌ | |
| R7.3 复用 ExerciseContainerView | ❌ | 使用 `DiagnosticTestView` |
| R7.4 测试成绩页 | 🟡 | `TestEngine` / `TestResult` 有部分逻辑 |
| R7.5 最高分 SwiftData | 🟡 | `TestHistory` 模型存在，更新逻辑待接 |
| R7.6 中途退出确认 | ❌ | |
| Tab 可见性 | ❌ | `TestTab.swift` 存在但未加入 `ContentView` |

---

## AC8 · 持久化

| 需求 | 状态 | 代码位置 / 差距 |
|------|------|----------------|
| R9.1 SwiftData 四类数据 | 🟡 | `PracticeRecord`, `TestHistory`；练习进度/设置/最高分字段不全 |
| 练习进度按 exerciseId | 🟡 | `PracticeViewModel` 按 `ExerciseModule`，非 spec exerciseId |
| 谱式 @AppStorage | 🟡 | 需确认 `NotationType` 持久化键 |

---

## AC9 · 空状态与错误状态

| 需求 | 状态 | 差距 |
|------|------|------|
| R13.1 题库加载失败 + 重试 | ❌ | |
| R13.2 麦克风权限卡片 | ❌ | |
| R13.3 新用户统计「—」 | ❌ | `ProfileTab` 显示数字 0 或占位文案不同 |
| R13.4 测试列表为空 | ❌ | |

---

## 建议实施顺序

### Phase A — 结构对齐（阻塞其他 AC）
1. `ContentView`：4 Tab = 练习 / 乐理 / 测试 / 我的  
2. 移除或下线 `CourseTab` 及课程导航  
3. 重构 `ExerciseModule` + `ExerciseType` → spec R2.6 的 5 模块 + exerciseId  
4. 定义 `ExerciseQuestion` + `QuestionBank.random(for:)`

### Phase B — 统一练习容器（AC2–AC5）
5. 重写 `ExerciseContainerView`：R3 布局 + bottomContent  
6. 实现 `AudioPromptCard`、`ReferenceNoteCard`、完成弹层  
7. 重做 `MusicKeyboardView` + 谱面实时反馈  
8. 接通谱式临时/全局逻辑（R5）

### Phase C — 视唱与测试（AC4、AC7）
9. 对齐 `PitchDetector`、评分公式、`SightSingingResultView`  
10. 重做 `TestTab` + 测试流复用容器  

### Phase D — 乐理与打磨（AC6、AC8、AC9）
11. 乐理手风琴 + 25 知识点 + 七和弦页 + 五度圈  
12. 空状态、权限 UI、新用户「—」  
13. 性能与 VoiceOver 抽测  

---

## 可保留复用资产

| 资产 | 文件 | 说明 |
|------|------|------|
| 谱面组件 | `StaffNotationView`, `GuitarTabView`, `SolfegeView`, `NotationDisplayView` | 扩展而非重写 |
| 音准 UI | `PitchMeterView`, `SightSingingView` | 调样式与公式 |
| 音频服务 | `AudioEngine`, `PitchDetector` | 算法可升级为 YIN |
| 题库数据 | `QuestionBank.swift` | 需加映射层到 exerciseId |
| 卡片组件 | `ModuleCard`, `ProgressDots` | Ring 需新增 |
| SwiftData | `PracticeRecord`, `TestHistory` | 扩展字段 |

---

## 文档索引

| 文档 | 用途 |
|------|------|
| [spec-v2.2.md](./spec-v2.2.md) | **当前权威需求** |
| [SRS.md](./SRS.md) | 历史长文档（含已废弃课程 Tab，勿作实现依据） |
