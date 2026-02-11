import SwiftUI
import SwiftData

/// Chat-based Prompt Assistant that guides users through building a prompt.
struct ChatCoachView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var engine = CoachEngine()
    @State private var inputText = ""
    @State private var showSaveSheet = false
    @State private var showToast = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            messageList
            if engine.isComplete {
                refinementBar
            }
            inputBar
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Prompt Coach")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if let prompt = engine.generatedPrompt {
                        Button {
                            UIPasteboard.general.string = prompt
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showToast = true
                        } label: {
                            Label("Copy Prompt", systemImage: "doc.on.doc")
                        }

                        Button {
                            showSaveSheet = true
                        } label: {
                            Label("Save Prompt", systemImage: "bookmark")
                        }
                    }
                    Button(role: .destructive) {
                        engine.reset()
                    } label: {
                        Label("Start Over", systemImage: "arrow.counterclockwise")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .toast(isShowing: $showToast, message: "Copied to clipboard")
        .sheet(isPresented: $showSaveSheet) {
            if let prompt = engine.generatedPrompt {
                SavePromptSheet(
                    promptBody: prompt,
                    category: "Chat",
                    variants: engine.variants
                ) {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(engine.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .onChange(of: engine.messages.count) { _, _ in
                if let last = engine.messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Refinement Bar

    private var refinementBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(RefinementOption.allCases) { option in
                    Button {
                        engine.applyRefinement(option)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: option.icon)
                                .font(.caption)
                            Text(option.label)
                                .font(.caption.weight(.medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Type your message...", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .focused($isInputFocused)
                .accessibilityLabel("Message input")

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(inputText.trimmed.isEmpty ? .secondary : .accentColor)
            }
            .disabled(inputText.trimmed.isEmpty)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    private func sendMessage() {
        let text = inputText.trimmed
        guard !text.isEmpty else { return }
        inputText = ""
        engine.send(text)
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: CoachEngine.Message

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 48) }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.subheadline)
                    .textSelection(.enabled)

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(message.role == .user ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )

            if message.role == .coach { Spacer(minLength: 48) }
        }
    }
}
