import SwiftUI

/// 练习模块详情页（优化模块内练习列表布局）
struct ModuleDetailView: View {
    let module: ExerciseModule
    let viewModel: PracticeViewModel

    @State private var selectedExercise: ExerciseType?
    @State private var showingExercise: ExerciseType?

    var exercises: [ExerciseType] {
        viewModel.exercises(for: module)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 模块介绍卡片
                moduleHeader

                // 练习列表
                exercisesList
            }
        }
        .background(AppTheme.background)
        .navigationTitle(module.rawValue)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(item: $showingExercise) { exercise in
            exerciseView(for: exercise)
        }
    }

    // MARK: - Module Header

    private var moduleHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: module.iconName)
                    .font(.title)
                    .foregroundStyle(moduleColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(module.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(module.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            // 统计信息
            HStack(spacing: 24) {
                StatBadge(value: "\(viewModel.practiceCount(for: module))", label: "练习次数", icon: "clock")
                if let bestScore = viewModel.bestScore(for: exercises.first ?? .singleNoteRecognition) {
                    StatBadge(value: "\(bestScore)", label: "最高分", icon: "star")
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .padding(.bottom, 16)
    }

    private var moduleColor: Color {
        switch module {
        case .noteName: return Color(hex: "3B82F6")
        case .interval: return Color(hex: "8B5CF6")
        case .chord: return AppTheme.Category.chord
        case .scale: return Color(hex: "14B8A6")
        case .rhythm: return AppTheme.Category.rhythm
        case .melody: return Color(hex: "22C55E")
        }
    }

    // MARK: - Exercises List

    private var exercisesList: some View {
        VStack(spacing: 0) {
            ForEach(exercises) { exercise in
                exerciseRow(exercise: exercise)

                if exercise != exercises.last {
                    Divider()
                        .padding(.leading, 60)
                }
            }
        }
        .background(AppTheme.cardBackground)
    }

    private func exerciseRow(exercise: ExerciseType) -> some View {
        Button {
            showingExercise = exercise
        } label: {
            HStack(spacing: 12) {
                // 图标
                Image(systemName: exerciseIcon(for: exercise))
                    .font(.title3)
                    .foregroundStyle(moduleColor)
                    .frame(width: 32)

                // 内容
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.primaryText)

                    HStack(spacing: 8) {
                        // 难度标签
                        difficultyBadge(exercise.difficulty)

                        // 练习次数
                        if viewModel.practiceCount(for: exercise) > 0 {
                            Label("\(viewModel.practiceCount(for: exercise)) 次", systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                // 得分
                if let score = viewModel.bestScore(for: exercise), score > 0 {
                    Text("\(score)")
                        .font(.headline)
                        .foregroundStyle(scoreColor(score))
                }

                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(moduleColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func difficultyBadge(_ difficulty: Difficulty) -> some View {
        Text(difficulty.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(difficultyColor(difficulty))
            .clipShape(Capsule())
    }

    private func difficultyColor(_ difficulty: Difficulty) -> Color {
        switch difficulty {
        case .easy: return AppTheme.success
        case .medium: return AppTheme.warning
        case .hard: return AppTheme.error
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 90 { return AppTheme.success }
        else if score >= 70 { return AppTheme.warning }
        else { return AppTheme.error }
    }

    private func exerciseIcon(for exercise: ExerciseType) -> String {
        switch exercise {
        case .singleNoteRecognition: return "music.note"
        case .openStringRecognition: return "guitars"
        case .rootNoteRecognition: return "music.note.list"
        case .tablatureNoteReading: return "text.alignleft"
        case .intervalRecognition: return "music.note"
        case .fretboardIntervalComparison: return "square.grid.3x3"
        case .intervalSinging: return "mic.fill"
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

    @ViewBuilder
    private func exerciseView(for exercise: ExerciseType) -> some View {
        switch exercise {
        case .singleNoteRecognition:
            SingleNoteListeningView()
        case .rootNoteRecognition:
            RootNoteListeningView(module: module, viewModel: viewModel)
        case .intervalSinging:
            SightSingingView(exercise: exercise, module: module, viewModel: viewModel)
        default:
            ExerciseDetailView(exercise: exercise, module: module, viewModel: viewModel)
        }
    }
}

/// 统计徽章
struct StatBadge: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        ModuleDetailView(
            module: .noteName,
            viewModel: PracticeViewModel()
        )
    }
}
