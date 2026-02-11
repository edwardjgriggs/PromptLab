import SwiftUI
import SwiftData

struct LessonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var progressRecords: [LessonProgress]

    let lesson: Lesson

    @State private var showGenerator = false

    private var isCompleted: Bool {
        progressRecords.contains { $0.lessonId == lesson.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Image(systemName: lesson.icon)
                        .font(.title)
                        .foregroundStyle(.accent)
                    VStack(alignment: .leading) {
                        Text(lesson.title)
                            .font(.title2.bold())
                        Text(lesson.durationLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if isCompleted {
                        Label("Done", systemImage: "checkmark.circle.fill")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.green)
                    }
                }

                // Content sections
                ForEach(Array(lesson.sections.enumerated()), id: \.offset) { _, section in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(section.heading)
                            .font(.headline)
                        Text(markdownText: section.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                // Bad example
                exampleCard(
                    example: lesson.badExample,
                    color: .red,
                    iconName: "xmark.circle.fill"
                )

                // Good example
                exampleCard(
                    example: lesson.goodExample,
                    color: .green,
                    iconName: "checkmark.circle.fill"
                )

                Divider()

                // Try it button
                Button {
                    showGenerator = true
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Try It in the Generator")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Mark complete
                if !isCompleted {
                    Button {
                        markComplete()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Mark as Complete")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showGenerator) {
            NavigationStack {
                GeneratorWizardView()
            }
        }
    }

    // MARK: - Example Card

    private func exampleCard(example: LessonExample, color: Color, iconName: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .foregroundStyle(color)
                Text(example.label)
                    .font(.subheadline.weight(.semibold))
            }

            Text(example.prompt)
                .font(.caption)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .textSelection(.enabled)

            Text(example.explanation)
                .font(.caption)
                .foregroundStyle(.secondary)
                .italic()

            CopyButton(example.prompt, label: "Copy example")
        }
        .padding()
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func markComplete() {
        let progress = LessonProgress(lessonId: lesson.id)
        modelContext.insert(progress)
        try? modelContext.save()
    }
}

// MARK: - Markdown Text Helper

extension Text {
    /// Simple initializer that renders basic markdown.
    init(markdownText: String) {
        self.init(LocalizedStringKey(markdownText))
    }
}
