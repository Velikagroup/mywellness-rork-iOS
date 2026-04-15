import SwiftUI

struct WorkoutDayPickerView: View {
    let numberOfDays: Int
    let onConfirm: ([String]) -> Void
    let onCancel: () -> Void

    private let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    private let shortDayKeys = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    private let scanTeal = Color(red: 0.0, green: 0.75, blue: 0.7)

    @State private var selectedIndices: Set<Int> = []

    private var allSelected: Bool {
        selectedIndices.count == numberOfDays
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            ScrollView {
                VStack(spacing: 24) {
                    instructionCard
                    daysGrid
                    confirmButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .presentationContentInteraction(.scrolls)
        }
    }

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(Lang.s("assign_days_title"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                Text(Lang.s("assign_days_subtitle"))
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onCancel) {
                ZStack {
                    Circle()
                        .fill(Color(.secondarySystemBackground).opacity(0.8))
                        .frame(width: 32, height: 32)
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var instructionCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 32))
                .foregroundStyle(scanTeal)

            Text(Lang.s("assign_days_instruction"))
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                VStack(spacing: 2) {
                    Text("\(numberOfDays)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(scanTeal)
                    Text(Lang.s("training_sessions"))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                VStack(spacing: 2) {
                    Text("\(7 - numberOfDays)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.orange)
                    Text(Lang.s("rest_days_label"))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 4)

            Text("\(selectedIndices.count)/\(numberOfDays)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(allSelected ? scanTeal : .secondary)
                .padding(.top, 2)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground).opacity(0.6))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var daysGrid: some View {
        VStack(spacing: 10) {
            ForEach(0..<7, id: \.self) { idx in
                let isSelected = selectedIndices.contains(idx)
                let isFull = selectedIndices.count >= numberOfDays && !isSelected

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        if isSelected {
                            selectedIndices.remove(idx)
                        } else if !isFull {
                            selectedIndices.insert(idx)
                        }
                    }
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(isSelected ? scanTeal : Color(.tertiarySystemBackground))
                                .frame(width: 44, height: 44)
                            Image(systemName: isSelected ? "checkmark" : "circle")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(isSelected ? .white : .secondary)
                        }

                        Text(Lang.s(shortDayKeys[idx]))
                            .font(.system(size: 17, weight: isSelected ? .bold : .medium))
                            .foregroundStyle(isSelected ? Color.primary : isFull ? Color.secondary.opacity(0.5) : Color.primary)

                        Spacer()

                        if isSelected {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 16))
                                .foregroundStyle(scanTeal)
                        } else {
                            Text(Lang.s("rest_recovery"))
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(isSelected ? scanTeal.opacity(0.08) : Color(.systemBackground))
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? scanTeal.opacity(0.3) : Color.clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isFull)
            }
        }
    }

    private var confirmButton: some View {
        Button {
            let selected = selectedIndices.sorted().map { weekdays[$0] }
            onConfirm(selected)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                Text(Lang.s("confirm_and_apply"))
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    colors: allSelected ? [scanTeal, Color(red: 0.2, green: 0.78, blue: 0.45)] : [Color.gray, Color.gray],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 14))
        }
        .disabled(!allSelected)
    }
}
