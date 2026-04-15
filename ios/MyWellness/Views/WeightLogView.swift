import SwiftUI

struct WeightLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @State private var weightText: String = ""
    @AppStorage("useMetricUnits") private var useKg: Bool = true
    @State private var saved: Bool = false

    private var weightValue: Double? {
        Double(weightText.replacingOccurrences(of: ",", with: "."))
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 28) {
                iconHeader
                titleSection
                unitToggle
                weightInput
                saveButton
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .preferredColorScheme(.light)
    }

    private var iconHeader: some View {
        ZStack {
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 72, height: 72)
            Image(systemName: "scalemass")
                .font(.system(size: 32))
                .foregroundStyle(Color(.label))
        }
    }

    private var titleSection: some View {
        VStack(spacing: 6) {
            Text(Lang.s("log_weight"))
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.primary)
            Text(Lang.s("enter_current_weight"))
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
    }

    private var unitToggle: some View {
        HStack(spacing: 0) {
            unitButton(label: "kg", isSelected: useKg) {
                withAnimation(.spring(response: 0.3)) { useKg = true }
            }
            unitButton(label: "lbs", isSelected: !useKg) {
                withAnimation(.spring(response: 0.3)) { useKg = false }
            }
        }
        .background(Color(.systemGray5))
        .clipShape(Capsule())
        .frame(maxWidth: .infinity)
    }

    private func unitButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isSelected ? .white : Color(.secondaryLabel))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isSelected ? Color(.label) : Color.clear)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var weightInput: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Lang.s("weight").capitalized)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)

            HStack {
                TextField(useKg ? "70.5" : "155", text: $weightText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                Text(useKg ? "kg" : "lbs")
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .background(Color(.systemGray6))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var saveButton: some View {
        Button {
            guard let value = weightValue, value > 0 else { return }
            let kg = useKg ? value : value * 0.453592
            appVM.addWeightEntry(kg)
            saved = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                dismiss()
            }
        } label: {
            HStack(spacing: 8) {
                if saved {
                    Image(systemName: "checkmark")
                        .font(.system(size: 17, weight: .semibold))
                } else {
                    Text(Lang.s("save_weight"))
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(saved ? Color.green : Color(.systemGray2))
            .clipShape(.rect(cornerRadius: 16))
            .animation(.spring(response: 0.3), value: saved)
        }
        .disabled(weightValue == nil || (weightValue ?? 0) <= 0)
    }
}
