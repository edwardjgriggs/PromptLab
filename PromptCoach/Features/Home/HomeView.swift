import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Prompt.updatedAt, order: .reverse) private var prompts: [Prompt]
    @State private var showGenerator = false
    @State private var showChat = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    tilesSection
                    recentPromptsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("PromptCoach")
            .fullScreenCover(isPresented: $showGenerator) {
                NavigationStack {
                    GeneratorWizardView()
                }
            }
            .fullScreenCover(isPresented: $showChat) {
                NavigationStack {
                    ChatCoachView()
                }
            }
        }
    }

    // MARK: - Tiles

    private var tilesSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                HomeTile(
                    title: "Generate a Prompt",
                    subtitle: "Step-by-step wizard",
                    icon: "wand.and.stars",
                    color: .blue
                ) {
                    showGenerator = true
                }

                HomeTile(
                    title: "Prompt Assistant",
                    subtitle: "Chat with your coach",
                    icon: "bubble.left.and.text.bubble.right.fill",
                    color: .purple
                ) {
                    showChat = true
                }
            }

            NavigationLink {
                LearnListView()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Learn Prompting", systemImage: "book.fill")
                            .font(.headline)
                        Text("Short lessons to level up")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Recent Prompts

    private var recentPromptsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !prompts.isEmpty {
                Text("Recent Prompts")
                    .font(.headline)

                ForEach(prompts.prefix(5)) { prompt in
                    NavigationLink {
                        PromptDetailView(prompt: prompt)
                    } label: {
                        RecentPromptRow(prompt: prompt)
                    }
                    .buttonStyle(.plain)
                }

                if prompts.count > 5 {
                    NavigationLink("See all", destination: LibraryView())
                        .font(.subheadline)
                }
            }
        }
    }
}

// MARK: - Home Tile

struct HomeTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title): \(subtitle)")
    }
}

// MARK: - Recent Prompt Row

struct RecentPromptRow: View {
    let prompt: Prompt

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(prompt.title)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                    if prompt.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }

                Text(prompt.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            CopyButton(prompt.body, label: "")
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 1)
    }
}
