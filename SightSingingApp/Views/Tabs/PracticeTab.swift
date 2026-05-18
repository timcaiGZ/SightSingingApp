import SwiftUI

/// Tab 1 — 练习首页（采用灰色分隔线列表布局）
struct PracticeTab: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = PracticeViewModel()
    @State private var selectedModule: ExerciseModule?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    ForEach(ExerciseModule.allCases) { module in
                        Section {
                            moduleExercisesList(module: module)
                        } header: {
                            sectionHeader(module: module)
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("练习")
            .navigationDestination(for: ExerciseModule.self) { module in
                ModuleDetailView(module: module, viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    /// 分类标题
    private func sectionHeader(module: ExerciseModule) -> some View {
        HStack {
            Image(systemName: module.iconName)
                .font(.caption)
                .foregroundStyle(moduleColor(for: module))

            Text(module.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            // 模块进度
            if let bestScore = viewModel.bestScore(for: ExerciseType.allCases.first { $0.module == module } ?? .singleNoteRecognition),
               bestScore > 0 {
                Text("\(bestScore) 分")
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemGroupedBackground))
    }

    /// 模块内的练习列表
    private func moduleExercisesList(module: ExerciseModule) -> some View {
        VStack(spacing: 0) {
            ForEach(viewModel.exercises(for: module)) { exercise in
                NavigationLink(value: module) {
                    exerciseRow(exercise: exercise)
                }
                .buttonStyle(.plain)

                if exercise != viewModel.exercises(for: module).last {
                    Divider()
                        .padding(.leading, 56)
                }
            }
        }
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
    }

    /// 单个练习行
    private func exerciseRow(exercise: ExerciseType) -> some View {
        HStack(spacing: 12) {
            // 图标
            Image(systemName: exerciseIcon(for: exercise))
                .font(.title3)
                .foregroundStyle(moduleColor(for: exercise.module))
                .frame(width: 32)

            // 练习名称和进度
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.rawValue)
                    .font(.body)
                    .foregroundStyle(AppColors.primaryText)

                if let bestScore = viewModel.bestScore(for: exercise), bestScore > 0 {
                    Text("最高 \(bestScore) 分")
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                } else {
                    Text("未练习")
                        .font(.caption)
                        .foregroundStyle(AppColors.tertiaryText)
                }
            }

            Spacer()

            // 进度指示
            progressIndicator(for: exercise)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppColors.tertiaryText)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    /// 进度指示器
    @ViewBuilder
    private func progressIndicator(for exercise: ExerciseType) -> some View {
        if let bestScore = viewModel.bestScore(for: exercise), bestScore > 0 {
            HStack(spacing: 4) {
                Text("\(bestScore)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(scoreColor(bestScore))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(scoreColor(bestScore).opacity(0.1))
            .clipShape(Capsule())
        }
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
        case .intervalRecognition, .fretboardIntervalComparison: return "music.note"
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

#Preview {
    PracticeTab()
        .modelContainer(for: [PracticeRecord.self, TestHistory.self], inMemory: true)
}
