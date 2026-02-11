import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var profiles: [UserProfile]
    @State private var showPrivacy = false
    @State private var showAPIKeySheet = false
    @State private var hasOpenAIKey = KeychainService.exists(key: KeychainService.openAIKeyName)
    @State private var hasAnthropicKey = KeychainService.exists(key: KeychainService.anthropicKeyName)

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                // Profile section
                if let profile {
                    Section("Profile") {
                        HStack {
                            Text("Output style")
                            Spacer()
                            Text(profile.verbosity == "short" ? "Short" : "Detailed")
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Target AI")
                            Spacer()
                            Text(modelDisplayName(profile.targetModel))
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Categories")
                            Spacer()
                            Text(profile.preferredCategories.joined(separator: ", "))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }

                // API Keys (BYOK)
                Section {
                    Button {
                        showAPIKeySheet = true
                    } label: {
                        HStack {
                            Label("API Keys", systemImage: "key.fill")
                            Spacer()
                            if hasOpenAIKey || hasAnthropicKey {
                                Text("Configured")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("AI Integration (Optional)")
                } footer: {
                    Text("Add your own API key to use AI-powered prompt refinement. This is optional — all core features work offline.")
                }

                // Privacy
                Section {
                    Button {
                        showPrivacy = true
                    } label: {
                        Label("Privacy & Data", systemImage: "hand.raised.fill")
                    }
                    .foregroundStyle(.primary)
                } footer: {
                    Text("PromptCoach stores everything on your device.")
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPrivacy) {
                PrivacyView()
            }
            .sheet(isPresented: $showAPIKeySheet) {
                APIKeySettingsView(hasOpenAIKey: $hasOpenAIKey, hasAnthropicKey: $hasAnthropicKey)
            }
        }
    }

    private func modelDisplayName(_ model: String) -> String {
        switch model {
        case "chatgpt": return "ChatGPT"
        case "claude": return "Claude"
        default: return "Generic"
        }
    }
}

// MARK: - Privacy View

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    privacySection(
                        icon: "iphone",
                        title: "On-Device Storage",
                        body: "All your prompts, preferences, and lesson progress are stored locally on your device using SwiftData. Nothing is sent to any server by default."
                    )

                    privacySection(
                        icon: "key.fill",
                        title: "API Keys",
                        body: "If you choose to add an API key for AI-powered refinement, it is stored securely in the iOS Keychain — encrypted and accessible only to this app. The key is never logged or transmitted to anyone except the API provider you configure."
                    )

                    privacySection(
                        icon: "network.slash",
                        title: "No Analytics or Tracking",
                        body: "PromptCoach does not collect analytics, usage data, or telemetry. There are no third-party SDKs or trackers."
                    )

                    privacySection(
                        icon: "hand.raised.fill",
                        title: "Your Control",
                        body: "You can delete all your data at any time by uninstalling the app. If you add an API key, you can remove it from Settings at any time."
                    )

                    privacySection(
                        icon: "globe",
                        title: "External Calls",
                        body: "Network requests are only made if you explicitly enable the BYOK (Bring Your Own Key) feature and submit a prompt for AI refinement. In that case, your prompt text is sent to the API provider (OpenAI or Anthropic) according to their privacy policy."
                    )
                }
                .padding()
            }
            .navigationTitle("Privacy & Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func privacySection(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - API Key Settings

struct APIKeySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var hasOpenAIKey: Bool
    @Binding var hasAnthropicKey: Bool
    @State private var openAIKeyInput = ""
    @State private var anthropicKeyInput = ""
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("OpenAI API Key", systemImage: "key")
                            .font(.subheadline.weight(.medium))
                        if hasOpenAIKey {
                            HStack {
                                Text("Key saved securely")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                                Spacer()
                                Button("Delete", role: .destructive) {
                                    KeychainService.delete(key: KeychainService.openAIKeyName)
                                    hasOpenAIKey = false
                                    toastMessage = "OpenAI key deleted"
                                    showToast = true
                                }
                                .font(.caption)
                            }
                        } else {
                            SecureField("sk-...", text: $openAIKeyInput)
                                .textFieldStyle(.roundedBorder)
                                .font(.caption)
                                .textContentType(.password)
                                .autocorrectionDisabled()
                                .accessibilityLabel("OpenAI API key input")
                            Button("Save Key") {
                                saveKey(openAIKeyInput, name: KeychainService.openAIKeyName)
                                hasOpenAIKey = true
                                openAIKeyInput = ""
                                toastMessage = "OpenAI key saved"
                                showToast = true
                            }
                            .disabled(openAIKeyInput.trimmed.isEmpty)
                        }
                    }
                } header: {
                    Text("OpenAI")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Anthropic API Key", systemImage: "key")
                            .font(.subheadline.weight(.medium))
                        if hasAnthropicKey {
                            HStack {
                                Text("Key saved securely")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                                Spacer()
                                Button("Delete", role: .destructive) {
                                    KeychainService.delete(key: KeychainService.anthropicKeyName)
                                    hasAnthropicKey = false
                                    toastMessage = "Anthropic key deleted"
                                    showToast = true
                                }
                                .font(.caption)
                            }
                        } else {
                            SecureField("sk-ant-...", text: $anthropicKeyInput)
                                .textFieldStyle(.roundedBorder)
                                .font(.caption)
                                .textContentType(.password)
                                .autocorrectionDisabled()
                                .accessibilityLabel("Anthropic API key input")
                            Button("Save Key") {
                                saveKey(anthropicKeyInput, name: KeychainService.anthropicKeyName)
                                hasAnthropicKey = true
                                anthropicKeyInput = ""
                                toastMessage = "Anthropic key saved"
                                showToast = true
                            }
                            .disabled(anthropicKeyInput.trimmed.isEmpty)
                        }
                    }
                } header: {
                    Text("Anthropic")
                }

                Section {
                    Text("API keys are stored in the iOS Keychain and never logged. They are only used to make requests to the respective AI provider when you explicitly request AI-powered refinement.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("API Keys")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .toast(isShowing: $showToast, message: toastMessage)
        }
    }

    private func saveKey(_ key: String, name: String) {
        KeychainService.save(key: name, value: key.trimmed)
    }
}
