import Foundation
import SwiftData

/// A variant of a prompt (e.g., concise, detailed, strict-format).
@Model
final class PromptVariant {
    var id: UUID
    var label: String
    var body: String

    init(label: String, body: String) {
        self.id = UUID()
        self.label = label
        self.body = body
    }
}
