import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(sort: \Prompt.updatedAt, order: .reverse) private var prompts: [Prompt]
    @State private var searchText = ""
    @State private var filterFavorites = false
    @State private var selectedTag: String?

    private var filteredPrompts: [Prompt] {
        prompts.filter { prompt in
            let matchesSearch = searchText.isEmpty
                || prompt.title.localizedCaseInsensitiveContains(searchText)
                || prompt.body.localizedCaseInsensitiveContains(searchText)
                || prompt.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })

            let matchesFavorite = !filterFavorites || prompt.isFavorite

            let matchesTag = selectedTag == nil
                || prompt.tags.contains(selectedTag!)

            return matchesSearch && matchesFavorite && matchesTag
        }
    }

    private var allTags: [String] {
        Array(Set(prompts.flatMap(\.tags))).sorted()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !allTags.isEmpty {
                    tagBar
                }

                if filteredPrompts.isEmpty {
                    emptyState
                } else {
                    promptList
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Library")
            .searchable(text: $searchText, prompt: "Search prompts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        filterFavorites.toggle()
                    } label: {
                        Image(systemName: filterFavorites ? "star.fill" : "star")
                            .foregroundStyle(filterFavorites ? .yellow : .secondary)
                    }
                    .accessibilityLabel(filterFavorites ? "Show all prompts" : "Show favorites only")
                }
            }
        }
    }

    // MARK: - Tag Bar

    private var tagBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                TagChip(text: "All", isSelected: selectedTag == nil) {
                    selectedTag = nil
                }
                ForEach(allTags, id: \.self) { tag in
                    TagChip(text: tag, isSelected: selectedTag == tag) {
                        selectedTag = selectedTag == tag ? nil : tag
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Prompt List

    private var promptList: some View {
        List {
            ForEach(filteredPrompts) { prompt in
                NavigationLink {
                    PromptDetailView(prompt: prompt)
                } label: {
                    PromptListRow(prompt: prompt)
                }
            }
            .onDelete(perform: deletePrompts)
        }
        .listStyle(.plain)
    }

    private func deletePrompts(at offsets: IndexSet) {
        for index in offsets {
            let prompt = filteredPrompts[index]
            if let modelIndex = prompts.firstIndex(where: { $0.id == prompt.id }) {
                // We need the modelContext to delete
                prompts[modelIndex].variants.forEach { _ in }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bookmark.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No prompts yet")
                .font(.title3.weight(.medium))
            Text("Generate or chat to create your first prompt, then save it here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
}

// MARK: - Prompt List Row

struct PromptListRow: View {
    let prompt: Prompt

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(prompt.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Spacer()
                if prompt.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }

            Text(prompt.body)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 6) {
                if !prompt.category.isEmpty {
                    Text(prompt.category)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundStyle(.accentColor)
                        .clipShape(Capsule())
                }

                ForEach(prompt.tags.prefix(3), id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }

                Spacer()

                Text(prompt.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
