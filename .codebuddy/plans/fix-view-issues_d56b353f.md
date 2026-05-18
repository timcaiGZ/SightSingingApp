---
name: fix-view-issues
overview: 修复之前 Review 中发现的 7 个视图文件中的代码问题，包括硬编码文本、类型安全和线程安全等问题。
todos:
  - id: fix-testtab-naming
    content: 修复 TestTab 硬编码标题，统一应用命名
    status: completed
  - id: fix-profile-colorScheme
    content: 修复 ProfileTab colorScheme 类型，使用 ColorScheme? 枚举
    status: completed
  - id: fix-exercise-questionbank
    content: 修复 ExerciseDetailView 题库加载，接入 QuestionBank 真实数据
    status: completed
  - id: fix-sightSinging-melody
    content: 修复 SightSingingView melody 动态生成和音索引切换逻辑
    status: completed
  - id: fix-pitch-detector-thread
    content: 修复 SightSingingView pitchDetector 线程安全问题
    status: completed
    dependencies:
      - fix-sightSinging-melody
  - id: fix-audio-playback
    content: 修复 DiagnosticTestView 音频播放，根据题目类型播放不同音频
    status: completed
  - id: fix-regex
    content: 修复 TheoryDetailView 正则表达式转义问题
    status: completed
---

## 用户需求

修复之前 Code Review 中发现的每个页面问题，共涉及 6 个文件、8 个具体问题。

## 待修复问题清单

### 1. TestTab.swift

- 第 46 行："吉他弹唱诊断" 硬编码 → 应改为统一应用名称
- 第 115 行："吉他弹唱诊断测试" 硬编码 → 统一命名

### 2. ProfileTab.swift

- 第 164-168 行：Picker 使用 Int 值 0/1/2 → 应使用 ColorScheme? 枚举类型

### 3. ExerciseDetailView.swift

- 第 28-32 行：questions 硬编码模拟数据 → 应从 QuestionBank 加载真实题库

### 4. SightSingingView.swift（重要）

- 第 25-30 行：melody 硬编码 → 应根据 exercise 类型动态生成
- 第 334 行：setTarget 每次设置同一音 → 需添加音索引自动切换逻辑
- 第 241 行：pitchDetector 线程安全问题 → 需添加 @MainActor 或线程同步

### 5. DiagnosticTestView.swift

- 第 113 行：所有题目播放相同音符 → 应根据题目类型播放对应音频

### 6. TheoryDetailView.swift

- 第 174 行：正则表达式 `\\d+\\.` 转义问题 → 修复正则表达式

## 技术方案

### 1. TestTab.swift 修复

- 提取硬编码的标题文本为常量 `AppConstants.appName`
- 统一测试页面的命名规范

### 2. ProfileTab.swift 修复

- 将 `colorScheme: Int` 改为 `colorScheme: ColorScheme?`
- 更新 Picker 的 tag 值
- 修改 ProfileViewModel 中对应的存储逻辑

### 3. ExerciseDetailView.swift 修复

- 根据 `exercise` 类型从 QuestionBank 加载对应题目
- 为不同 ExerciseType 添加题库映射方法

### 4. SightSingingView.swift 修复（核心）

- 添加 `generateMelody(for:)` 方法，根据 exercise 类型生成旋律
- 添加 Timer 逻辑：每个音符的时值到期后自动切换到下一个音
- 使用 `@MainActor` 标记 PitchDetector 的属性访问，或使用线程安全的方式

### 5. DiagnosticTestView.swift 修复

- 根据 `TestQuestion.questionTypeValue` 播放不同音频
- 扩展 AudioEngineManager 支持多种音频类型

### 6. TheoryDetailView.swift 修复

- 修复正则表达式：使用 `line.prefix(while:)` 或正确的转义

## 依赖分析

- ExerciseDetailView → QuestionBank
- SightSingingView → ExerciseType (melody生成)
- DiagnosticTestView → AudioEngineManager (音频播放)
- ProfileTab → ProfileViewModel (colorScheme)