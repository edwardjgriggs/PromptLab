import SwiftUI
import SwiftData

/// First-launch onboarding that collects user preferences.
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @State private var selectedCategories: Set<String> = []
    @State private var verbosity: String = "detailed"
    @State private var targetModel: String = "generic"

    private let totalPages = 4

    var body: some View {
        VStack(spacing: 0) {
            StepProgressBar(totalSteps: totalPages, currentStep: currentPage)
                .padding(.top)

            Group {
                switch currentPage {
                case 0: welcomePage
                case 1: categoriesPage
                case 2: verbosityPage
                case 3: modelPage
                default: EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut, value: currentPage)

            bottomBar
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Pages

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.system(size: 64))
                .foregroundStyle(.accent)
                .accessibilityHidden(true)

            Text("Welcome to PromptCoach")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("Prompting is how you talk to AI. A great prompt gives you a great answer. A vague prompt gives you a vague answer.\n\nThis app helps you write clear, effective prompts — no technical skills needed.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
    }

    private var categoriesPage: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: 40)
                Text("What will you use AI for?")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("Select all that apply. This helps us personalize your experience.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                categoriesGrid
                    .padding(.horizontal)

                Spacer(minLength: 40)
            }
            .padding()
        }
    }

    private var categoriesGrid: some View {
        let categories = ["Writing", "Work email", "School", "Coding help", "Brainstorming", "Other"]
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(categories, id: \.self) { category in
                categoryChip(category)
            }
        }
    }

    private func categoryChip(_ category: String) -> some View {
        let isSelected = selectedCategories.contains(category)
        return Button {
            if isSelected {
                selectedCategories.remove(category)
            } else {
                selectedCategories.insert(category)
            }
        } label: {
            Text(category)
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var verbosityPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("How detailed should your prompts be?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                verbosityOption(
                    title: "Short & direct",
                    description: "Quick prompts that get straight to the point",
                    value: "short",
                    icon: "bolt.fill"
                )
                verbosityOption(
                    title: "Detailed & thorough",
                    description: "Comprehensive prompts with full context and constraints",
                    value: "detailed",
                    icon: "doc.text.fill"
                )
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }

    private var modelPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Which AI do you mainly use?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("We'll tailor formatting tips accordingly. You can change this later.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                modelOption(title: "Generic / Not sure", value: "generic", icon: "sparkles")
                modelOption(title: "ChatGPT", value: "chatgpt", icon: "bubble.left.fill")
                modelOption(title: "Claude", value: "claude", icon: "brain.head.profile")
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            if currentPage > 0 {
                Button("Back") {
                    withAnimation { currentPage -= 1 }
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                if currentPage < totalPages - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    completeOnboarding()
                }
            } label: {
                Text(currentPage == totalPages - 1 ? "Get Started" : "Next")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    // MARK: - Helpers

    private func verbosityOption(title: String, description: String, value: String, icon: String) -> some View {
        Button {
            verbosity = value
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(description).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if verbosity == value {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accent)
                }
            }
            .padding()
            .background(verbosity == value ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(verbosity == value ? .isSelected : [])
    }

    private func modelOption(title: String, value: String, icon: String) -> some View {
        Button {
            targetModel = value
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 32)
                Text(title).font(.headline)
                Spacer()
                if targetModel == value {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accent)
                }
            }
            .padding()
            .background(targetModel == value ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(targetModel == value ? .isSelected : [])
    }

    private func completeOnboarding() {
        let profile = UserProfile(
            preferredCategories: Array(selectedCategories),
            verbosity: verbosity,
            targetModel: targetModel,
            hasSeenOnboarding: true
        )
        modelContext.insert(profile)
        try? modelContext.save()
    }
}
