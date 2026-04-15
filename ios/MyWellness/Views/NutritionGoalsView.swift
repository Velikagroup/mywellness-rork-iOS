import SwiftUI

struct NutritionGoalsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @State private var calorieTarget: String = ""
    @State private var proteinTarget: String = ""
    @State private var carbsTarget: String = ""
    @State private var fatTarget: String = ""

    var body: some View {
        VStack(spacing: 0) {
            headerBar(title: Lang.s("nutrition_goals_title"), onBack: { dismiss() })

            ScrollView {
                VStack(spacing: 16) {
                    goalCard(title: Lang.s("daily_calories_label"), value: $calorieTarget, unit: "kcal", current: Int(appVM.userProfile.dailyCalorieTarget))
                    goalCard(title: Lang.s("protein"), value: $proteinTarget, unit: "g", current: Int(appVM.userProfile.proteinTarget))
                    goalCard(title: Lang.s("carbs"), value: $carbsTarget, unit: "g", current: Int(appVM.userProfile.carbsTarget))
                    goalCard(title: Lang.s("fat"), value: $fatTarget, unit: "g", current: Int(appVM.userProfile.fatTarget))

                    Button {
                        saveGoals()
                        dismiss()
                    } label: {
                        Text(Lang.s("save_changes"))
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
            calorieTarget = "\(Int(appVM.userProfile.dailyCalorieTarget))"
            proteinTarget = "\(Int(appVM.userProfile.proteinTarget))"
            carbsTarget = "\(Int(appVM.userProfile.carbsTarget))"
            fatTarget = "\(Int(appVM.userProfile.fatTarget))"
        }
    }

    private func goalCard(title: String, value: Binding<String>, unit: String, current: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            HStack {
                TextField("\(current)", text: value)
                    .keyboardType(.numberPad)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.primary)
                Text(unit)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(.rect(cornerRadius: 12))
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private func saveGoals() {
        if let cal = Double(calorieTarget) {
            appVM.userProfile.customCalorieTarget = cal
        }
        appVM.saveCurrentProfile()
    }
}
