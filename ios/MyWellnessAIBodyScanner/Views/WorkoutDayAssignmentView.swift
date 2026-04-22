import SwiftUI

struct WorkoutDayAssignmentView: View {
    let workoutPlan: WorkoutPlan
    let onApply: (WorkoutPlan) -> Void
    let onCancel: () -> Void

    private let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    private let shortDayKeys = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    private let scanTeal = Color(red: 0.0, green: 0.75, blue: 0.7)

    @State private var assignments: [String: Int] = [:]
    @State private var trainingDays: [WorkoutDay] = []

    private var allAssigned: Bool {
        trainingDays.allSatisfy { day in
            assignments[day.id.uuidString] != nil
        }
    }

    private var usedWeekdayIndices: Set<Int> {
        Set(assignments.values)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            ScrollView {
                VStack(spacing: 20) {
                    instructionCard
                    sessionsListSection
                    applyButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .presentationContentInteraction(.scrolls)
        }
        .onAppear {
            trainingDays = workoutPlan.days.filter { !$0.isRestDay }
            for (idx, day) in trainingDays.enumerated() {
                if let weekdayIdx = weekdays.firstIndex(of: day.dayName) {
                    assignments[day.id.uuidString] = weekdayIdx
                } else if idx < weekdays.count {
                    assignments[day.id.uuidString] = idx
                }
            }
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
                    Text("\(trainingDays.count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(scanTeal)
                    Text(Lang.s("training_sessions"))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                VStack(spacing: 2) {
                    Text("\(7 - trainingDays.count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.orange)
                    Text(Lang.s("rest_days_label"))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground).opacity(0.6))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var sessionsListSection: some View {
        VStack(spacing: 12) {
            ForEach(trainingDays) { day in
                sessionAssignmentCard(day: day)
            }
        }
    }

    private func sessionAssignmentCard(day: WorkoutDay) -> some View {
        let assignedIdx = assignments[day.id.uuidString]

        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(scanTeal.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 18))
                        .foregroundStyle(scanTeal)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(day.focus)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                    HStack(spacing: 8) {
                        Label("\(day.durationMinutes) min", systemImage: "clock")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        Label("\(day.exercises.count) ex.", systemImage: "dumbbell.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if let idx = assignedIdx {
                    Text(Lang.s(shortDayKeys[idx]))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(scanTeal)
                        .clipShape(Capsule())
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<7, id: \.self) { weekdayIdx in
                        let isSelected = assignedIdx == weekdayIdx
                        let isUsedByOther = usedWeekdayIndices.contains(weekdayIdx) && !isSelected

                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                if isSelected {
                                    assignments[day.id.uuidString] = nil
                                } else {
                                    if let otherDayId = assignments.first(where: { $0.value == weekdayIdx })?.key {
                                        assignments[otherDayId] = nil
                                    }
                                    assignments[day.id.uuidString] = weekdayIdx
                                }
                            }
                        } label: {
                            Text(Lang.s(shortDayKeys[weekdayIdx]))
                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(isSelected ? .white : isUsedByOther ? .secondary.opacity(0.5) : .primary)
                                .frame(width: 44, height: 36)
                                .background(isSelected ? scanTeal : isUsedByOther ? Color(.systemGray5) : Color(.secondarySystemBackground))
                                .clipShape(.rect(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isSelected ? scanTeal : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentMargins(.horizontal, 0)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }

    private var applyButton: some View {
        Button {
            let reassigned = buildReassignedPlan()
            onApply(reassigned)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text(Lang.s("confirm_and_apply"))
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    colors: allAssigned ? [scanTeal, Color(red: 0.2, green: 0.78, blue: 0.45)] : [Color.gray, Color.gray],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 14))
        }
        .disabled(!allAssigned)
    }

    private func buildReassignedPlan() -> WorkoutPlan {
        var newDays: [WorkoutDay] = []

        for weekdayIdx in 0..<7 {
            let dayName = weekdays[weekdayIdx]

            if let trainingDay = trainingDays.first(where: { assignments[$0.id.uuidString] == weekdayIdx }) {
                var reassigned = trainingDay
                reassigned.dayName = dayName
                newDays.append(reassigned)
            } else {
                newDays.append(WorkoutDay(
                    dayName: dayName,
                    focus: Lang.s("rest_recovery"),
                    durationMinutes: 0,
                    exercises: [],
                    isRestDay: true,
                    caloriesBurned: 0
                ))
            }
        }

        return WorkoutPlan(days: newDays, createdAt: Date())
    }
}
