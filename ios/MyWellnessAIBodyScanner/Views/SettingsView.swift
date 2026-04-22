import SwiftUI
import MessageUI
import RevenueCat

struct SettingsView: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(StoreViewModel.self) private var storeVM
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appleHealthConnected") private var appleHealthConnected: Bool = false
    @State private var showDeleteConfirm = false
    @State private var showLogoutConfirm = false
    @State private var showLanguagePicker = false
    @State private var showPersonalData = false
    @State private var showPreferences = false
    @State private var showFamilyPlan = false
    @State private var showNutritionGoals = false
    @State private var showWeightGoals = false
    @State private var showReminders = false
    @State private var showPDFReport = false
    @State private var showProfileSetup = false
    @State private var showMailComposer = false
    @State private var showFeatureRequest = false
    @State private var lastSyncTime: Date = Date()
    @State private var isSyncing = false
    @State private var showWidgetInstructions = false
    @State private var showInviteFriend = false

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 120)

                    VStack(spacing: 24) {
                        profileHeaderSection
                        inviteFriendsSection
                        accountSection
                        goalsTrackingSection
                        widgetSection
                        supportSection
                        followUsSection
                        accountActionsSection
                    }
                    .padding(.horizontal, 16)

                    Text("MyWellnessAIBodyScanner v1.0")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 28)
                        .padding(.bottom, 120)
                }
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)

            WellnessNavBarOverlay()
        }
        .confirmationDialog(
            selectedLanguage.name,
            isPresented: $showLanguagePicker,
            titleVisibility: .visible
        ) {
            ForEach(AppLanguage.all) { lang in
                Button(lang.flag + " " + lang.name) {
                    withAnimation(.spring(response: 0.3)) {
                        appLanguage = lang.code
                    }
                }
            }
            Button("Annulla", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showPersonalData) {
            PersonalDataView()
        }
        .fullScreenCover(isPresented: $showProfileSetup) {
            ProfileSetupView()
        }
        .fullScreenCover(isPresented: $showFamilyPlan) {
            FamilyPlanView()
        }
        .fullScreenCover(isPresented: $showPDFReport) {
            PDFReportFlowView()
        }
        .fullScreenCover(isPresented: $showPreferences) {
            PreferencesView()
        }
        .fullScreenCover(isPresented: $showNutritionGoals) {
            NutritionGoalsView()
        }
        .fullScreenCover(isPresented: $showWeightGoals) {
            WeightGoalsView()
        }
        .fullScreenCover(isPresented: $showReminders) {
            RemindersView()
        }
        .fullScreenCover(isPresented: $showFeatureRequest) {
            FeatureRequestView()
        }
        .fullScreenCover(isPresented: $showInviteFriend) {
            InviteFriendView()
                .environment(appVM)
        }
        .sheet(isPresented: $showMailComposer) {
            SupportMailView()
        }
        .sheet(isPresented: $showWidgetInstructions) {
            WidgetInstructionsView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: appLanguage) { _, _ in
            NotificationService.syncAllNotifications()
        }
        .overlay {
            if showDeleteConfirm {
                customAlert(
                    title: Lang.s("delete_account_q"),
                    message: Lang.s("delete_account_msg"),
                    cancelTitle: Lang.s("cancel"),
                    confirmTitle: Lang.s("delete"),
                    isDestructive: true,
                    onCancel: { withAnimation(.spring(response: 0.3)) { showDeleteConfirm = false } },
                    onConfirm: {
                        withAnimation(.spring(response: 0.3)) { showDeleteConfirm = false }
                        appVM.deleteAccount()
                    }
                )
            }
            if showLogoutConfirm {
                customAlert(
                    title: Lang.s("log_out_q"),
                    message: Lang.s("log_out_msg"),
                    cancelTitle: Lang.s("cancel"),
                    confirmTitle: Lang.s("log_out"),
                    isDestructive: true,
                    onCancel: { withAnimation(.spring(response: 0.3)) { showLogoutConfirm = false } },
                    onConfirm: {
                        withAnimation(.spring(response: 0.3)) { showLogoutConfirm = false }
                        appVM.logout()
                    }
                )
            }
        }
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage.all.first { $0.code == appLanguage } ?? AppLanguage.all[0]
    }

    // MARK: - Profile Header

    private var profileHeaderSection: some View {
        Button {
            showProfileSetup = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 56, height: 56)
                    if let img = appVM.memojiUIImage(for: .good) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text(storeVM.isPremium ? "Premium" : "Free")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(appVM.userProfile.name.isEmpty ? Lang.s("tap_to_setup") : appVM.userProfile.name)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(Lang.s("and_username"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color(.systemBackground).opacity(0.8))
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Invite Friends

    private var inviteFriendsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Lang.s("invite_friends"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            Button {
                showInviteFriend = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 20))
                        .foregroundStyle(.primary)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(Lang.s("invite_friend_earn"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(Lang.s("invite_friend_desc"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
                .background(Color(.systemBackground).opacity(0.8))
                .clipShape(.rect(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Account

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Lang.s("account"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                settingsRow(icon: "person.text.rectangle", title: Lang.s("personal_data")) {
                    showPersonalData = true
                }
                rowDivider
                settingsRow(icon: "gearshape", title: Lang.s("preferences")) {
                    showPreferences = true
                }
                rowDivider
                settingsRow(icon: "globe", title: Lang.s("language"), trailing: selectedLanguage.name) {
                    showLanguagePicker = true
                }
                rowDivider
                settingsRow(icon: "person.2", title: Lang.s("switch_family_plan")) {
                    showFamilyPlan = true
                }
            }
            .background(Color(.systemBackground).opacity(0.8))
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        }
    }

    // MARK: - Goals & Tracking

    private var goalsTrackingSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Lang.s("goals_tracking"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                Button {
                    openHealthApp()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "heart")
                            .font(.system(size: 16))
                            .foregroundStyle(.primary)
                            .frame(width: 24)

                        Text("Apple Health")
                            .font(.subheadline)
                            .foregroundStyle(.primary)

                        Spacer()

                        if appleHealthConnected {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.semibold))
                                Text(Lang.s("connected"))
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }

                        Image(systemName: "arrow.up.forward")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                rowDivider

                settingsRow(icon: "scope", title: Lang.s("edit_nutrition_goals")) {
                    showNutritionGoals = true
                }
                rowDivider
                settingsRow(icon: "flag", title: Lang.s("goals_current_weight")) {
                    showWeightGoals = true
                }
                rowDivider
                settingsRow(icon: "bell", title: Lang.s("logging_reminders")) {
                    showReminders = true
                }

            }
            .background(Color(.systemBackground).opacity(0.8))
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        }
    }

    // MARK: - Widget

    private var widgetSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(Lang.s("widget"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    showWidgetInstructions = true
                } label: {
                    Text(Lang.s("how_to_add"))
                        .font(.caption)
                        .foregroundStyle(Color.wellnessTeal)
                }
            }
            .padding(.horizontal, 4)

            HealthWidgetCard()
                .environment(appVM)
        }
    }

    private func openHealthApp() {
        if let url = URL(string: "x-apple-health://") {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Support

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Lang.s("support_legal"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                settingsRow(icon: "megaphone", title: Lang.s("request_feature")) {
                    showFeatureRequest = true
                }
                rowDivider
                settingsRow(icon: "envelope", title: Lang.s("support_email")) {
                    showMailComposer = true
                }
                rowDivider
                settingsRow(icon: "square.and.arrow.up", title: Lang.s("export_pdf")) {
                    showPDFReport = true
                }
                rowDivider
                HStack(spacing: 14) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                        .frame(width: 24)

                    Text(Lang.s("sync_data"))
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(Lang.s("last_sync"))\(lastSyncTime.formatted(date: .omitted, time: .shortened))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard !isSyncing else { return }
                    isSyncing = true
                    Task {
                        await appVM.fetchHealthData()
                        lastSyncTime = Date()
                        isSyncing = false
                    }
                }

                rowDivider
                settingsRow(icon: "doc.text", title: Lang.s("terms_conditions")) {
                    if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                        UIApplication.shared.open(url)
                    }
                }
                rowDivider
                settingsRow(icon: "shield.checkered", title: Lang.s("privacy_policy")) {
                    if let url = URL(string: "https://www.apple.com/privacy/") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            .background(Color(.systemBackground).opacity(0.8))
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        }
    }

    // MARK: - Follow Us

    private var followUsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Lang.s("follow_us"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                socialRow(title: "Instagram", icon: "camera") {
                    if let url = URL(string: "https://instagram.com/projectmywellness") {
                        UIApplication.shared.open(url)
                    }
                }
                rowDivider
                socialRow(title: "TikTok", icon: "music.note") {
                    if let url = URL(string: "https://tiktok.com/@projectmywellness.com") {
                        UIApplication.shared.open(url)
                    }
                }
                rowDivider
                socialRow(title: "Facebook", icon: "person.2") {
                    if let url = URL(string: "https://www.facebook.com/profile.php?id=61587568215714") {
                        UIApplication.shared.open(url)
                    }
                }
                rowDivider
                socialRow(title: "YouTube", icon: "play.rectangle") {
                    if let url = URL(string: "https://www.youtube.com/@projectmywellness") {
                        UIApplication.shared.open(url)
                    }
                }

            }
            .background(Color(.systemBackground).opacity(0.8))
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        }
    }

    private func socialRow(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                    .frame(width: 24)

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Account Actions

    private var accountActionsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Lang.s("account_actions"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                settingsRow(icon: "rectangle.portrait.and.arrow.right", title: Lang.s("log_out")) {
                    withAnimation(.spring(response: 0.3)) { showLogoutConfirm = true }
                }
                rowDivider
                settingsRow(icon: "person.badge.minus", title: Lang.s("delete_account")) {
                    withAnimation(.spring(response: 0.3)) { showDeleteConfirm = true }
                }
            }
            .background(Color(.systemBackground).opacity(0.8))
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        }
    }

    // MARK: - Helpers

    private func settingsRow(icon: String, title: String, trailing: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                    .frame(width: 24)

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                if let trailing {
                    Text(trailing)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private var rowDivider: some View {
        Divider().padding(.leading, 54)
    }

    private func customAlert(
        title: String,
        message: String,
        cancelTitle: String,
        confirmTitle: String,
        isDestructive: Bool,
        onCancel: @escaping () -> Void,
        onConfirm: @escaping () -> Void
    ) -> some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 16) {
                HStack {
                    Text(title)
                        .font(.title3.bold())
                    Spacer()
                    Button { onCancel() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    Button { onCancel() } label: {
                        Text(cancelTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray6))
                            .clipShape(.capsule)
                    }

                    Button { onConfirm() } label: {
                        Text(confirmTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isDestructive ? Color.red : Color.blue)
                            .clipShape(.capsule)
                    }
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .clipShape(.rect(cornerRadius: 24))
            .shadow(color: .black.opacity(0.15), radius: 30, y: 10)
            .padding(.horizontal, 32)
        }
        .transition(.opacity)
    }
}

nonisolated struct AppLanguage: Identifiable, Sendable {
    let id: String
    let code: String
    let name: String
    let flag: String

    static let all: [AppLanguage] = [
        AppLanguage(id: "it", code: "it", name: "Italiano", flag: "🇮🇹"),
        AppLanguage(id: "en", code: "en", name: "English", flag: "🇬🇧"),
        AppLanguage(id: "es", code: "es", name: "Español", flag: "🇪🇸"),
        AppLanguage(id: "de", code: "de", name: "Deutsch", flag: "🇩🇪"),
        AppLanguage(id: "fr", code: "fr", name: "Français", flag: "🇫🇷"),
        AppLanguage(id: "pt", code: "pt", name: "Português", flag: "🇵🇹"),
    ]
}
