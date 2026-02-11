import Foundation
import SwiftData

/// Tracks which lessons the user has completed.
@Model
final class LessonProgress {
    var id: UUID
    var lessonId: String
    var completedAt: Date

    init(lessonId: String) {
        self.id = UUID()
        self.lessonId = lessonId
        self.completedAt = Date()
    }
}
