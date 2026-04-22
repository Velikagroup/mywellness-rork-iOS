import SwiftUI

struct ExerciseDetailSheet: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.title2)
                                .foregroundStyle(Color.wellnessTeal)
                            Text(exercise.name)
                                .font(.title2.bold())
                        }
                        HStack(spacing: 8) {
                            Text("\(exercise.setDisplay) \u{2022} \(exercise.restSeconds) \(Lang.s("seconds"))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if !exercise.rpeDisplay.isEmpty {
                                Text(exercise.rpeDisplay)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange)
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    if !exercise.muscleGroups.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Text("\u{1F3AF}")
                                Text(Lang.s("target_muscles"))
                                    .font(.headline)
                            }
                            FlowLayout(spacing: 8) {
                                ForEach(exercise.muscleGroups, id: \.self) { muscle in
                                    Text(muscle)
                                        .font(.subheadline.weight(.medium))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .foregroundStyle(Color.wellnessTeal)
                                        .background(Color.wellnessTeal.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color.wellnessTeal.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }

                    if !exercise.exerciseDescription.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(.blue)
                                Text(Lang.s("detailed_description"))
                                    .font(.headline)
                            }
                            Text(exercise.exerciseDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.blue.opacity(0.15), lineWidth: 1)
                        )
                    }

                    if !exercise.formTips.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "bolt.fill")
                                    .foregroundStyle(.green)
                                Text(Lang.s("form_tips"))
                                    .font(.headline)
                            }
                            ForEach(exercise.formTips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\u{2022}")
                                        .font(.subheadline)
                                    Text(tip)
                                        .font(.subheadline)
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.green.opacity(0.15), lineWidth: 1)
                        )
                    }

                    if !exercise.loadTips.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .foregroundStyle(.orange)
                                Text(Lang.s("load_and_intensity"))
                                    .font(.headline)
                            }
                            ForEach(exercise.loadTips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\u{2022}")
                                        .font(.subheadline)
                                    Text(tip)
                                        .font(.subheadline)
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.orange.opacity(0.15), lineWidth: 1)
                        )
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text(Lang.s("close"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.wellnessTeal)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
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

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
