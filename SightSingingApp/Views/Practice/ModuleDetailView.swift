import SwiftUI

/// 练习模块详情页
struct ModuleDetailView: View {
    let module: ExerciseModule
    let viewModel: PracticeViewModel

    @State private var selectedExercise: ExerciseType?
    @State private var showingExercise: ExerciseType?

    var exercises: [ExerciseType] {
        viewModel.exercises(for: module)
    }

    var body: some View {
        List {
            // 模块介绍
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: module.iconName)
                            .font(.title)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [module.gradientStart, module.gradientEnd],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text(module.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    Text(module.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            // 练习列表（按难度分组）
            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                let difficultyExercises = exercises.filter { $0.difficulty == difficulty }
                if !difficultyExercises.isEmpty {
                    Section(difficulty.rawValue) {
                        ForEach(difficultyExercises) { exercise in
                            ExerciseCard(
                                exercise: exercise,
                                bestScore: viewModel.bestScore(for: exercise),
                                practiceCount: viewModel.practiceCount(for: exercise)
                            ) {
                                showingExercise = exercise
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(module.rawValue)
        .navigationDestination(for: ExerciseType.self) { exercise in
            ExerciseDetailView(exercise: exercise, module: module, viewModel: viewModel)
        }
        .fullScreenCover(item: $showingExercise) { exercise in
            switch exercise {
            case .singleNoteRecognition:
                SingleNoteListeningView(module: module, viewModel: viewModel)
            case .rootNoteRecognition:
                RootNoteListeningView(module: module, viewModel: viewModel)
            default:
                ExerciseDetailView(exercise: exercise, module: module, viewModel: viewModel)
            }
        }
    }
}

/// 单个练习入口卡片
struct ExerciseCard: View {
    let exercise: ExerciseType
    let bestScore: Int?
    let practiceCount: Int
    let onStart: () -> Void

    var body: some View {
        Button(action: onStart) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    HStack(spacing: 12) {
                        if let score = bestScore, score > 0 {
                            Label("\(score) 分", systemImage: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }

                        if practiceCount > 0 {
                            Label("\(practiceCount) 次", systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // 难度标签
                        Text(exercise.difficulty.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(difficultyColor)
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [module.gradientStart, module.gradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var difficultyColor: Color {
        switch exercise.difficulty {
        case .easy: return AppColors.success
        case .medium: return AppColors.warning
        case .hard: return AppColors.error
        }
    }

    private var module: ExerciseModule {
        exercise.module
    }
}

#Preview {
    NavigationStack {
        ModuleDetailView(
            module: .chord,
            viewModel: PracticeViewModel()
        )
    }
}
