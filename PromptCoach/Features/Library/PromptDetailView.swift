import SwiftUI
import SwiftData

struct PromptDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var prompt: Prompt
    @State private var showToast = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(prompt.title)
                            .font(.title2.bold())
                        HStack(spacing: 6) {
                            if !prompt.category.isEmpty {
                                TagChip(text: prompt.category)
                            }
                            Text(prompt.source == "wizard" ? "Generator" : "Chat")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Button {
                        prompt.isFavorite.toggle()
                        try? modelContext.save()
                    } label: {
                        Image(systemName: prompt.isFavorite ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundStyle(prompt.isFavorite ? .yellow : .secondary)
                    }
                    .accessibilityLabel(prompt.isFavorite ? "Remove from favorites" : "Add to favorites")
                }

                // Prompt body
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Prompt")
                            .font(.headline)
                        Spacer()
                        CopyButton(prompt.body)
                    }
                    Text(prompt.body)
                        .font(.body)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .textSelection(.enabled)
                }

                // Tags
                if !prompt.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(prompt.tags, id: \.self) { tag in
                                    TagChip(text: tag)
                                }
                            }
                        }
                    }
                }

                // Variants
                if !prompt.variants.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Variants")
                            .font(.headline)
                        ForEach(prompt.variants) { variant in
                            DisclosureGroup(variant.label) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(variant.body)
                                        .font(.caption)
                                        .textSelection(.enabled)
                                    CopyButton(variant.body, label: "Copy variant")
                                }
                                .padding(.top, 4)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }

                // Metadata
                VStack(alignment: .leading, spacing: 4) {
                    Text("Created: \(prompt.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text("Updated: \(prompt.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toast(isShowing: $showToast, message: "Copied to clipboard")
    }
}
