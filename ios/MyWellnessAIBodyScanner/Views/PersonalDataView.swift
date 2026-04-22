import SwiftUI

struct PersonalDataView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @State private var editingField: EditField?
    @State private var editValue: String = ""
    @State private var showDatePicker = false
    @State private var showGenderPicker = false
    @State private var selectedDate: Date = Date()
    @State private var selectedGender: UserProfile.Gender = .male

    private enum EditField: Identifiable {
        case targetWeight, currentWeight, height
        var id: Self { self }
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar(title: Lang.s("personal_data_title"), onBack: { dismiss() })

            ScrollView {
                VStack(spacing: 16) {
                    goalWeightCard
                    personalInfoCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .alert(Lang.s("edit"), isPresented: Binding(
            get: { editingField != nil },
            set: { if !$0 { editingField = nil } }
        )) {
            TextField(Lang.s("value_label"), text: $editValue)
                .keyboardType(.decimalPad)
            Button(Lang.s("save")) { saveEdit() }
            Button(Lang.s("cancel"), role: .cancel) { editingField = nil }
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationStack {
                DatePicker(Lang.s("dob_label"), selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                    .navigationTitle(Lang.s("dob_label"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(Lang.s("save")) {
                                appVM.userProfile.dateOfBirth = selectedDate
                                appVM.saveCurrentProfile()
                                showDatePicker = false
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button(Lang.s("cancel")) { showDatePicker = false }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showGenderPicker) {
            NavigationStack {
                List {
                    ForEach(UserProfile.Gender.allCases, id: \.self) { g in
                        Button {
                            selectedGender = g
                        } label: {
                            HStack {
                                Text(genderDisplayName(g))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedGender == g {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(Lang.s("gender_label"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(Lang.s("save")) {
                            appVM.userProfile.gender = selectedGender
                            appVM.saveCurrentProfile()
                            showGenderPicker = false
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button(Lang.s("cancel")) { showGenderPicker = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var goalWeightCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Lang.s("target_weight_label"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(Int(appVM.userProfile.targetWeightKg)) kg")
                    .font(.title3.bold())
            }
            Spacer()
            Button(Lang.s("change_goal")) {
                editingField = .targetWeight
                editValue = "\(Int(appVM.userProfile.targetWeightKg))"
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black)
            .clipShape(.capsule)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private var personalInfoCard: some View {
        VStack(spacing: 0) {
            dataRow(label: Lang.s("current_weight_label"), value: "\(Int(appVM.userProfile.currentWeightKg)) kg") {
                editingField = .currentWeight
                editValue = "\(Int(appVM.userProfile.currentWeightKg))"
            }
            Divider().padding(.leading, 16)
            dataRow(label: Lang.s("height_label"), value: "\(Int(appVM.userProfile.heightCm)) cm") {
                editingField = .height
                editValue = "\(Int(appVM.userProfile.heightCm))"
            }
            Divider().padding(.leading, 16)
            dataRow(label: Lang.s("dob_label"), value: dateFormatter.string(from: appVM.userProfile.dateOfBirth)) {
                selectedDate = appVM.userProfile.dateOfBirth
                showDatePicker = true
            }
            Divider().padding(.leading, 16)
            dataRow(label: Lang.s("gender_label"), value: genderLabel) {
                selectedGender = appVM.userProfile.gender
                showGenderPicker = true
            }
        }
        .padding(.vertical, 4)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private var genderLabel: String {
        switch appVM.userProfile.gender {
        case .male: return Lang.s("gender_male")
        case .female: return Lang.s("gender_female")
        case .other: return Lang.s("gender_other")
        }
    }

    private func dataRow(label: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func genderDisplayName(_ g: UserProfile.Gender) -> String {
        switch g {
        case .male: return Lang.s("gender_male")
        case .female: return Lang.s("gender_female")
        case .other: return Lang.s("gender_other")
        }
    }

    private func saveEdit() {
        guard let field = editingField, let val = Double(editValue.replacingOccurrences(of: ",", with: ".")) else { return }
        switch field {
        case .targetWeight:
            appVM.userProfile.targetWeightKg = val
        case .currentWeight:
            appVM.userProfile.currentWeightKg = val
        case .height:
            appVM.userProfile.heightCm = val
        }
        appVM.saveCurrentProfile()
        editingField = nil
    }
}
