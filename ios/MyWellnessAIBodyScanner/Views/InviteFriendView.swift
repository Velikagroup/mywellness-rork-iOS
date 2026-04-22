import SwiftUI

struct InviteFriendView: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss
    @State private var showCopied: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var orbScale: CGFloat = 1.0
    @State private var orbOpacity: Double = 0.6

    private let appStoreURL = "https://apps.apple.com/app/mywellness"

    private var referralCode: String {
        if let stored = UserDefaults.standard.string(forKey: "userReferralCode"), !stored.isEmpty {
            return stored
        }
        let code = makeCode()
        UserDefaults.standard.set(code, forKey: "userReferralCode")
        return code
    }

    private func makeCode() -> String {
        let name = appVM.userProfile.name.uppercased().filter { $0.isLetter }
        let prefix: String
        if name.count >= 3 {
            prefix = String(name.prefix(3))
        } else if name.count > 0 {
            prefix = String(name.prefix(name.count)).padding(toLength: 3, withPad: "W", startingAt: 0)
        } else {
            prefix = "MYW"
        }
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        let suffix = String((0..<3).map { _ in chars.randomElement()! })
        return prefix + suffix
    }

    private var shareMessage: String {
        let template = Lang.s("share_message")
        return template.replacingOccurrences(of: "%@", with: referralCode, options: [], range: template.range(of: "%@")).replacingOccurrences(of: "%@", with: appStoreURL)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        avatarCluster
                            .padding(.top, 8)
                            .padding(.bottom, 24)

                        headlineSection
                            .padding(.bottom, 32)

                        codeCard
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)

                        shareButton
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)

                        howToEarnCard
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                    }
                }
                .scrollIndicators(.hidden)

                if showCopied {
                    copiedToast
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(10)
                }
            }
            .navigationTitle(Lang.s("invite_friend_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityShareSheet(items: [shareMessage])
                .ignoresSafeArea()
        }
    }

    // MARK: - Avatar Cluster

    private var avatarCluster: some View {
        ZStack {
            let orbColors: [(Color, CGFloat, CGFloat, CGFloat)] = [
                (.teal,       -88, -28, 52),
                (.orange,     -44, -64, 48),
                (.blue,        50, -52, 56),
                (.purple,      90, -10, 44),
                (.pink,       -60,  36, 46),
                (.green,       40,  42, 50),
            ]

            let avatarIcons = ["person.fill", "person.fill", "person.fill", "person.fill", "person.fill", "person.fill"]

            ForEach(Array(orbColors.enumerated()), id: \.offset) { idx, config in
                let (color, x, y, size) = config
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.85), color.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay {
                        Image(systemName: avatarIcons[idx])
                            .font(.system(size: size * 0.42))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .shadow(color: color.opacity(0.3), radius: 8, y: 4)
                    .offset(x: x, y: y)
                    .scaleEffect(orbScale)
                    .animation(
                        .easeInOut(duration: 2.8 + Double(idx) * 0.4)
                        .repeatForever(autoreverses: true)
                        .delay(Double(idx) * 0.35),
                        value: orbScale
                    )
            }

            ZStack {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 72, height: 72)
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 4)

                Image("AppLogoReferral")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .frame(height: 160)
        .onAppear {
            orbScale = 1.06
        }
    }

    // MARK: - Headline

    private var headlineSection: some View {
        VStack(spacing: 6) {
            Text(Lang.s("support_friends"))
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
            Text(Lang.s("achieve_together"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Code Card

    private var codeCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Lang.s("your_promo_code"))
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Text(referralCode)
                    .font(.system(.title2, design: .monospaced, weight: .bold))
                    .foregroundStyle(.primary)
                    .tracking(4)

                Spacer()

                Button {
                    UIPasteboard.general.string = referralCode
                    withAnimation(.spring(response: 0.3)) {
                        showCopied = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.spring(response: 0.3)) {
                            showCopied = false
                        }
                    }
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 20))
                        .foregroundStyle(.primary)
                        .padding(10)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button {
            showShareSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                Text(Lang.s("share"))
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(Color.primary)
            .clipShape(.capsule)
        }
        .buttonStyle(.plain)
    }

    // MARK: - How To Earn

    private var howToEarnCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text(Lang.s("how_to_earn"))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)

                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 26, height: 26)
                    Text("$")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                earnStep(
                    number: "1",
                    color: Color.wellnessTeal,
                    text: Lang.s("earn_step_1")
                )
                earnStep(
                    number: "2",
                    color: .orange,
                    text: Lang.s("earn_step_2")
                )
                earnStep(
                    number: "3",
                    color: .purple,
                    text: Lang.s("earn_step_3")
                )
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private func earnStep(number: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 28, height: 28)
                Text(number)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(color)
            }

            if let attributed = try? AttributedString(markdown: text) {
                Text(attributed)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Copied Toast

    private var copiedToast: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.wellnessTeal)
                Text(Lang.s("code_copied"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(.capsule)
            .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
            .padding(.top, 16)

            Spacer()
        }
    }
}

// MARK: - UIActivityViewController wrapper

struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
