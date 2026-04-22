import SwiftUI

struct ModifySessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @State private var userMessage: String = ""
    @State private var chatMessages: [SessionChatMessage] = []
    @State private var isProcessing: Bool = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        aiWelcomeMessage

                        if appVM.hasActiveSessionOverride {
                            activeOverrideBanner
                        }

                        ForEach(chatMessages) { msg in
                            chatBubble(msg)
                        }

                        if isProcessing {
                            processingBubble
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .id("chatBottom")
                }
                .scrollIndicators(.hidden)
                .onChange(of: chatMessages.count) { _, _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("chatBottom", anchor: .bottom)
                    }
                }
                .onChange(of: isProcessing) { _, _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("chatBottom", anchor: .bottom)
                    }
                }
            }

            Divider()

            inputBar
        }
        .presentationContentInteraction(.scrolls)
    }

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(Lang.s("ai_consultation_title"))
                    .font(.headline)
                Text(Lang.s("session_temp_only"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if appVM.hasActiveSessionOverride {
                Button {
                    appVM.clearSessionOverride()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.caption.weight(.bold))
                        Text(Lang.s("reset_session"))
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }

    private var aiWelcomeMessage: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "wand.and.stars")
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.wellnessTeal)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(Lang.s("ai_session_welcome"))
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Text(Lang.s("ai_consultation_placeholder"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Spacer(minLength: 40)
        }
    }

    private var activeOverrideBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(Color(red: 0.15, green: 0.55, blue: 0.3))
            Text(Lang.s("session_modified_active"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(red: 0.15, green: 0.55, blue: 0.3))
            Spacer()
        }
        .padding(10)
        .background(Color(red: 0.15, green: 0.55, blue: 0.3).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func chatBubble(_ msg: SessionChatMessage) -> some View {
        HStack {
            if msg.isUser { Spacer(minLength: 60) }

            if !msg.isUser {
                Image(systemName: "wand.and.stars")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.wellnessTeal)
                    .clipShape(Circle())
            }

            VStack(alignment: msg.isUser ? .trailing : .leading, spacing: 4) {
                Text(msg.text)
                    .font(.subheadline)
                    .foregroundStyle(msg.isUser ? .white : .primary)

                if msg.isError {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                        Text(Lang.s("try_again"))
                            .font(.caption2)
                    }
                    .foregroundStyle(.red)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(msg.isUser ? Color.wellnessTeal : (msg.isError ? Color.red.opacity(0.1) : Color(.systemGray6)))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if !msg.isUser { Spacer(minLength: 40) }
        }
    }

    private var processingBubble: some View {
        HStack {
            Image(systemName: "wand.and.stars")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(Color.wellnessTeal)
                .clipShape(Circle())

            HStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(Color.wellnessTeal)
                Text(Lang.s("ai_modifying_session"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Spacer(minLength: 40)
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField(Lang.s("session_input_placeholder"), text: $userMessage, axis: .vertical)
                .font(.subheadline)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .focused($isInputFocused)

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(canSend ? Color.wellnessTeal : Color(.systemGray4))
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
            .conditionalSensoryFeedback(.impact(weight: .medium), trigger: chatMessages.count)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var canSend: Bool {
        !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isProcessing
    }

    private func sendMessage() {
        let text = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        chatMessages.append(SessionChatMessage(text: text, isUser: true))
        userMessage = ""
        isProcessing = true

        Task {
            await appVM.modifyTodaySession(userRequest: text)
            isProcessing = false

            if let error = appVM.sessionModificationError {
                chatMessages.append(SessionChatMessage(text: error, isUser: false, isError: true))
            } else {
                chatMessages.append(SessionChatMessage(
                    text: Lang.s("session_modified_success"),
                    isUser: false
                ))
            }
        }
    }
}

struct SessionChatMessage: Identifiable {
    let id: UUID = UUID()
    let text: String
    let isUser: Bool
    var isError: Bool = false
}
