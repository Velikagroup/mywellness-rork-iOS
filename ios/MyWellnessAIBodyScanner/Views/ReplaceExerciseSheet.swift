import SwiftUI

struct ReplaceExerciseSheet: View {
    let exercise: Exercise
    let onReplace: (Exercise) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var newExerciseName: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.title2)
                        .foregroundStyle(Color.wellnessTeal)
                        .frame(width: 44, height: 44)
                        .background(Color.wellnessTeal.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Lang.s("replace_exercise"))
                            .font(.title3.bold())
                        Text(Lang.s("replace_exercise_desc"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 6) {
                    Text(Lang.s("current_exercise"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(exercise.name)
                        .font(.headline)
                    Text(exercise.setDisplay)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    Text(Lang.s("new_exercise"))
                        .font(.subheadline.weight(.semibold))
                    TextField(Lang.s("exercise_placeholder"), text: $newExerciseName)
                        .textFieldStyle(.roundedBorder)
                    Text(Lang.s("exercise_helper_text"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Text(Lang.s("cancel"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.systemGray6))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        let newExercise = Exercise(
                            name: newExerciseName.isEmpty ? exercise.name : newExerciseName,
                            sets: exercise.sets,
                            reps: exercise.reps,
                            restSeconds: exercise.restSeconds,
                            muscleGroups: exercise.muscleGroups,
                            category: exercise.category,
                            difficulty: exercise.difficulty
                        )
                        onReplace(newExercise)
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.subheadline)
                            Text(Lang.s("replace"))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(newExerciseName.isEmpty ? Color(.systemGray4) : Color.wellnessTeal)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(newExerciseName.isEmpty)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
