import SwiftUI

/// Tab 1 — 练习首页（深蓝主题重构）
struct PracticeTab: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = PracticeViewModel()
    @State private var showingExercise: ExerciseType?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12, pinnedViews: .sectionHeaders) {
                    ForEach(ExerciseModule.allCases) { module in
                        if !viewModel.exercises(for: module).isEmpty {
                            Section {
                                moduleExercisesList(module: module)
                            } header: {
                                sectionHeader(module: module)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .pageBackground()
            .navigationTitle("自由练习")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO: Settings action
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }
            }
            .fullScreenCover(item: $showingExercise) { exercise in
                exerciseView(for: exercise)
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    @ViewBuilder
    private func exerciseView(for exercise: ExerciseType) -> some View {
        switch exercise {
        case .singleNoteRecognition:
            SingleNoteListeningView(module: exercise.module, viewModel: viewModel)
        case .rootNoteRecognition:
            RootNoteListeningView(module: exercise.module, viewModel: viewModel)
        case .intervalSinging:
            SightSingingView(exercise: exercise, module: exercise.module, viewModel: viewModel)
        default:
            ExerciseDetailView(exercise: exercise, module: exercise.module, viewModel: viewModel)
        }
    }

    /// 分类标题
    private func sectionHeader(module: ExerciseModule) -> some View {
        HStack(spacing: 8) {
            // 左侧彩色竖条
            Rectangle()
                .fill(moduleColor(for: module).opacity(0.5))
                .frame(width: 3, height: 16)
                .clipShape(RoundedRectangle(cornerRadius: 1.5))

            Text(module.rawValue)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            // 模块进度圆点
            let progress = viewModel.progress(for: module)
            ProgressDots(total: 5, completed: progress)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppColors.pageBackground)
    }

    /// 模块内的练习列表 — 点击练习直接进入答题页
    private func moduleExercisesList(module: ExerciseModule) -> some View {
        VStack(spacing: 0) {
            ForEach(viewModel.exercises(for: module)) { exercise in
                Button {
                    showingExercise = exercise
                } label: {
                    exerciseRow(exercise: exercise)
                }
                .buttonStyle(.plain)

                if exercise != viewModel.exercises(for: module).last {
                    Divider()
                        .padding(.leading, 52)
                }
            }
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 单个练习行
    private func exerciseRow(exercise: ExerciseType) -> some View {
        HStack(spacing: 12) {
            // 图标
            Image(systemName: exerciseIcon(for: exercise))
                .font(.body)
                .foregroundStyle(moduleColor(for: exercise.module))
                .frame(width: 28)

            // 练习名称
            Text(exercise.rawValue)
                .font(.body)
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            // 进度圆点
            let exerciseProgress = exerciseProgress(for: exercise)
            ProgressDots(total: 5, completed: exerciseProgress)

            // 分数
            if let bestScore = viewModel.bestScore(for: exercise), bestScore > 0 {
                Text("\(bestScore) 分")
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppColors.tertiaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    /// 单个练习的进度（基于是否完成）
    private func exerciseProgress(for exercise: ExerciseType) -> Int {
        viewModel.bestScore(for: exercise) ?? 0 > 0 ? 5 : 0
    }

    /// 模块对应颜色
    private func moduleColor(for module: ExerciseModule) -> Color {
        switch module {
        case .noteName: return AppColors.noteName
        case .interval: return AppColors.interval
        case .chord: return AppColors.chord
        case .scale: return AppColors.scale
        case .rhythm: return AppColors.rhythm
        case .melody: return AppColors.melody
        }
    }

    /// 练习类型对应图标
    private func exerciseIcon(for exercise: ExerciseType) -> String {
        switch exercise {
        case .singleNoteRecognition: return "music.note"
        case .openStringRecognition: return "guitars"
        case .rootNoteRecognition: return "music.note.list"
        case .tablatureNoteReading: return "text.alignleft"
        case .intervalRecognition: return "music.note"
        case .intervalSinging: return "mic.fill"
        case .fretboardIntervalComparison: return "square.grid.3x3"
        case .hammerPullInterval: return "hand.tap"
        case .barreChordRecognition, .chordQualityRecognition: return "rectangle.3.group"
        case .chordTransitionSpeed: return "arrow.left.arrow.right"
        case .commonChordRecognition: return "rectangle.3.group.fill"
        case .scaleRecognition: return "music.quarternote.3"
        case .cagedSystemPractice: return "square.grid.2x2"
        case .commonTuningRecognition: return "tuningfork"
        case .strummingPattern: return "waveform"
        case .arpeggioPattern: return "waveform.path"
        case .metronomeStability: return "metronome"
        case .syncopationRecognition: return "music.note.list"
        case .tablatureMelodySinging, .guitarMelodyRecognition: return "music.mic"
        case .harmonicRecognition: return "waveform.path.ecg"
        }
    }

    /// 得分对应颜色
    private func scoreColor(_ score: Int) -> Color {
        if score >= 90 { return AppColors.success }
        else if score >= 70 { return AppColors.warning }
        else { return AppColors.error }
    }
}

// MARK: - PracticeViewModel Extension
extension PracticeViewModel {
    /// 计算模块进度（0-5）
    func progress(for module: ExerciseModule) -> Int {
        let exercises = exercises(for: module)
        let completedCount = exercises.filter { bestScore(for: $0) ?? 0 > 0 }.count
        let totalCount = max(exercises.count, 1)
        return min(5, Int((Double(completedCount) / Double(totalCount)) * 5))
    }
}

#Preview {
    PracticeTab()
        .modelContainer(for: [PracticeRecord.self, TestHistory.self], inMemory: true)
}
