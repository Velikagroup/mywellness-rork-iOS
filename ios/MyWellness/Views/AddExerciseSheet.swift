import SwiftUI

struct AddExerciseSheet: View {
    let currentDay: WorkoutDay
    let onAdd: (Exercise) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @State private var userInput: String = ""
    @State private var chatMessages: [ExerciseChatMessage] = []
    @State private var isTyping: Bool = false
    @State private var proposedExercise: Exercise?
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            chatHeader
            Divider().opacity(0.3)
            chatScrollArea
            if let exercise = proposedExercise {
                exerciseCard(exercise)
            }
            chatInputBar
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            sendInitialGreeting()
        }
    }

    private var chatHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.wellnessTeal.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: "brain.filled.head.profile")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.wellnessTeal)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(Lang.s("add_exercise_title"))
                    .font(.headline)
                Text(Lang.s("ai_chat_subtitle"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var chatScrollArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(chatMessages) { msg in
                        chatBubble(msg)
                            .id(msg.id)
                    }

                    if isTyping {
                        typingIndicator
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollIndicators(.hidden)
            .onChange(of: chatMessages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    if isTyping {
                        proxy.scrollTo("typing", anchor: .bottom)
                    } else if let last = chatMessages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: isTyping) { _, newVal in
                if newVal {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func chatBubble(_ message: ExerciseChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 60)
                Text(message.text)
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.wellnessTeal)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(Color.wellnessTeal)
                        .frame(width: 24, height: 24)
                        .background(Color.wellnessTeal.opacity(0.1))
                        .clipShape(Circle())

                    Text(message.text)
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                Spacer(minLength: 40)
            }
        }
    }

    private var typingIndicator: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundStyle(Color.wellnessTeal)
                .frame(width: 24, height: 24)
                .background(Color.wellnessTeal.opacity(0.1))
                .clipShape(Circle())

            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.secondary.opacity(0.5))
                        .frame(width: 7, height: 7)
                        .scaleEffect(isTyping ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.15),
                            value: isTyping
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Spacer(minLength: 40)
        }
    }

    private func exerciseCard(_ exercise: Exercise) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                    HStack(spacing: 8) {
                        Text(exercise.setDisplay)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.wellnessTeal)
                            .clipShape(Capsule())
                        if exercise.restSeconds > 0 {
                            Text("\(exercise.restSeconds)s rest")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if !exercise.difficulty.isEmpty {
                            Text(exercise.difficulty)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(difficultyColor(exercise.difficulty))
                        }
                    }
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.wellnessTeal)
            }

            if !exercise.muscleGroups.isEmpty {
                HStack(spacing: 6) {
                    ForEach(exercise.muscleGroups.prefix(4), id: \.self) { group in
                        Text(group)
                            .font(.caption2.weight(.medium))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .foregroundStyle(Color.wellnessTeal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(Color.wellnessTeal.opacity(0.3), lineWidth: 1)
                            )
                    }
                    Spacer()
                }
            }

            if !exercise.exerciseDescription.isEmpty {
                Text(exercise.exerciseDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }

            Button {
                onAdd(exercise)
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.bold))
                    Text(Lang.s("ai_chat_apply"))
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.wellnessTeal)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color.wellnessTeal.opacity(0.3), radius: 8, y: 3)
            }
            .buttonStyle(.plain)
            .conditionalSensoryFeedback(.impact(weight: .medium), trigger: proposedExercise?.id)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var chatInputBar: some View {
        HStack(spacing: 10) {
            TextField(Lang.s("ai_chat_placeholder"), text: $userInput, axis: .vertical)
                .font(.subheadline)
                .lineLimit(1...3)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .focused($isInputFocused)
                .onSubmit {
                    sendMessage()
                }
                .submitLabel(.send)

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(canSend ? Color.wellnessTeal : Color(.systemGray4))
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private var canSend: Bool {
        !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isTyping
    }

    private func sendInitialGreeting() {
        let greeting = ExerciseChatMessage(
            text: Lang.s("ai_chat_greeting"),
            isUser: false
        )
        withAnimation(.spring(response: 0.3)) {
            chatMessages.append(greeting)
        }
    }

    private func sendMessage() {
        let text = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userMsg = ExerciseChatMessage(text: text, isUser: true)
        withAnimation(.spring(response: 0.3)) {
            chatMessages.append(userMsg)
            proposedExercise = nil
        }

        userInput = ""

        withAnimation(.spring(response: 0.3)) {
            isTyping = true
        }

        Task {
            do {
                var history: [[String: String]] = []
                for msg in chatMessages {
                    history.append([
                        "role": msg.isUser ? "user" : "assistant",
                        "content": msg.text
                    ])
                }

                let response = try await AIService.exerciseChatReply(
                    chatHistory: history,
                    currentDay: currentDay,
                    profile: appVM.userProfile
                )

                withAnimation(.spring(response: 0.35)) {
                    isTyping = false
                    chatMessages.append(ExerciseChatMessage(text: response.message, isUser: false))
                    if response.exerciseReady, let exercise = response.exercise {
                        proposedExercise = exercise
                    }
                }
            } catch {
                withAnimation(.spring(response: 0.3)) {
                    isTyping = false
                    chatMessages.append(ExerciseChatMessage(
                        text: Lang.s("ai_exercise_error"),
                        isUser: false
                    ))
                }
            }
        }
    }

    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "beginner", "easy": return .green
        case "intermediate", "medium": return .orange
        case "advanced", "hard": return .red
        default: return .gray
        }
    }
}

struct ExerciseChatMessage: Identifiable {
    let id: UUID = UUID()
    let text: String
    let isUser: Bool
}

nonisolated enum AddExercisePhase: Sendable {
    case input
    case loading
    case suggestions
}
