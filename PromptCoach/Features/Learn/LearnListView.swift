import SwiftUI
import SwiftData

struct LearnListView: View {
    @Query private var progressRecords: [LessonProgress]
    private let lessons = LessonCatalog.all

    private func isCompleted(_ lessonId: String) -> Bool {
        progressRecords.contains { $0.lessonId == lessonId }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(lessons) { lesson in
                        NavigationLink {
                            LessonDetailView(lesson: lesson)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: lesson.icon)
                                    .font(.title3)
                                    .foregroundStyle(.accent)
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(lesson.title)
                                        .font(.subheadline.weight(.semibold))
                                    Text(lesson.summary)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }

                                Spacer()

                                if isCompleted(lesson.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else {
                                    Text(lesson.durationLabel)
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("Prompting Fundamentals")
                } footer: {
                    let completed = progressRecords.count
                    Text("\(completed)/\(lessons.count) lessons completed")
                }
            }
            .navigationTitle("Learn")
        }
    }
}
