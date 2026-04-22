import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @State private var step: Int = 0
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var selectedColorIndex: Int = 2
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImageData: Data?

    private let avatarColors: [Color] = [
        .pink, .purple, Color(red: 0.2, green: 0.78, blue: 0.7), .orange, .pink.opacity(0.8)
    ]

    var body: some View {
        VStack(spacing: 0) {
            headerBar(title: nil, onBack: {
                if step > 0 {
                    withAnimation(.spring(response: 0.3)) { step -= 1 }
                } else {
                    dismiss()
                }
            })

            Group {
                switch step {
                case 0: nameStep
                case 1: usernameStep
                case 2: photoStep
                default: EmptyView()
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            Spacer()

            Button {
                if step < 2 {
                    withAnimation(.spring(response: 0.3)) { step += 1 }
                } else {
                    saveFinal()
                    dismiss()
                }
            } label: {
                Text(Lang.s("continue"))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canContinue ? Color.black : Color(.systemGray4))
                    .clipShape(.rect(cornerRadius: 16))
            }
            .disabled(!canContinue)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
    }

    private var canContinue: Bool {
        switch step {
        case 0: return !firstName.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return !username.trimmingCharacters(in: .whitespaces).isEmpty
        default: return true
        }
    }

    // MARK: - Name Step

    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Lang.s("profile_confirm_name"))
                .font(.title.bold())
            Text(Lang.s("profile_name_visible"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                TextField(Lang.s("profile_first_name"), text: $firstName)
                    .font(.body)
                    .padding(16)
                    .background(Color(.systemBackground))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
                    .clipShape(.rect(cornerRadius: 12))

                TextField(Lang.s("profile_last_name"), text: $lastName)
                    .font(.body)
                    .padding(16)
                    .background(Color(.systemBackground))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }

    // MARK: - Username Step

    private var usernameStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Lang.s("profile_create_username"))
                .font(.title.bold())
            Text(Lang.s("profile_username_help"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField(Lang.s("profile_username_ph"), text: $username)
                .font(.body)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(16)
                .background(Color(.systemBackground))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
                .clipShape(.rect(cornerRadius: 12))
                .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(usernameSuggestions, id: \.self) { suggestion in
                        Button {
                            username = suggestion
                        } label: {
                            Text(suggestion)
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .clipShape(.capsule)
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }

    private var usernameSuggestions: [String] {
        let first = firstName.lowercased().trimmingCharacters(in: .whitespaces)
        let last = lastName.lowercased().trimmingCharacters(in: .whitespaces)
        guard !first.isEmpty else { return [] }
        var suggestions: [String] = []
        if !last.isEmpty {
            suggestions.append(first + last)
            suggestions.append(first + "_" + last)
            suggestions.append(String(first.prefix(1)) + last)
        }
        suggestions.append(first + "\(Int.random(in: 10...99))")
        return suggestions
    }

    // MARK: - Photo Step

    private var photoStep: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(Lang.s("profile_add_photo"))
                    .font(.title.bold())
                Text(Lang.s("profile_photo_help"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<avatarColors.count, id: \.self) { index in
                        let isSelected = selectedColorIndex == index
                        ZStack {
                            Circle()
                                .fill(avatarColors[index])
                                .frame(width: isSelected ? 80 : 64, height: isSelected ? 80 : 64)
                            Text(initials)
                                .font(isSelected ? .title2.bold() : .body.bold())
                                .foregroundStyle(.white)
                        }
                        .overlay {
                            if isSelected {
                                Circle()
                                    .stroke(Color.primary, lineWidth: 2)
                                    .frame(width: 90, height: 90)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedColorIndex = index
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .contentMargins(.horizontal, 0)

            Text(Lang.s("profile_scroll_color"))
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(Lang.s("profile_or"))
                .font(.caption)
                .foregroundStyle(.secondary)

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.body)
                    Text(Lang.s("profile_upload_photo"))
                        .font(.body.weight(.medium))
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.systemBackground))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray4), lineWidth: 1))
                .clipShape(.rect(cornerRadius: 14))
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 24)
    }

    private var initials: String {
        let f = firstName.prefix(1).uppercased()
        let l = lastName.prefix(1).uppercased()
        let result = f + l
        return result.isEmpty ? "MW" : result
    }

    private func saveFinal() {
        let fullName = [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
        appVM.userProfile.name = fullName
        appVM.saveCurrentProfile()
    }
}
