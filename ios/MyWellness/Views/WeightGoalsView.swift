import SwiftUI

struct WeightGoalsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @State private var currentWeight: String = ""
    @State private var targetWeight: String = ""
    @State private var selectedGoal: UserProfile.Goal = .loseWeight

    var body: some View {
        VStack(spacing: 0) {
            headerBar(title: Lang.s("goals_and_weight"), onBack: { dismiss() })

            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 0) {
                        goalRow(goal: .loseWeight, label: Lang.s("wg_lose_weight"), icon: "flame.fill")
                        Divider().padding(.leading, 54)
                        goalRow(goal: .maintain, label: Lang.s("wg_maintain"), icon: "scale.3d")
                        Divider().padding(.leading, 54)
                        goalRow(goal: .gainMuscle, label: Lang.s("wg_gain_muscle"), icon: "dumbbell.fill")
                    }
                    .background(Color(.systemBackground))
                    .clipShape(.rect(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)

                    VStack(spacing: 0) {
                        weightField(label: Lang.s("wg_current_weight"), value: $currentWeight, unit: "kg")
                        Divider().padding(.leading, 16)
                        weightField(label: Lang.s("wg_target_weight"), value: $targetWeight, unit: "kg")
                    }
                    .background(Color(.systemBackground))
                    .clipShape(.rect(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)

                    Button {
                        saveGoals()
                        dismiss()
                    } label: {
                        Text(Lang.s("save"))
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .clipShape(.rect(cornerRadius: 16))
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            currentWeight = "\(Int(appVM.userProfile.currentWeightKg))"
            targetWeight = "\(Int(appVM.userProfile.targetWeightKg))"
            selectedGoal = appVM.userProfile.goal
        }
    }

    private func goalRow(goal: UserProfile.Goal, label: String, icon: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { selectedGoal = goal }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                    .frame(width: 24)
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                if selectedGoal == goal {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.wellnessTeal)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func weightField(label: String, value: Binding<String>, unit: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
            TextField("", text: value)
                .keyboardType(.decimalPad)
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.trailing)
                .frame(width: 60)
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func saveGoals() {
        appVM.userProfile.goal = selectedGoal
        if let w = Double(currentWeight.replacingOccurrences(of: ",", with: ".")) {
            appVM.userProfile.currentWeightKg = w
        }
        if let t = Double(targetWeight.replacingOccurrences(of: ",", with: ".")) {
            appVM.userProfile.targetWeightKg = t
        }
        appVM.saveCurrentProfile()
    }
}
