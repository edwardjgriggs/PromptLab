import Foundation
import SwiftData

/// A saved prompt with optional variants, tags, and metadata.
@Model
final class Prompt {
    var id: UUID
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date
    var category: String
    var tags: [String]
    var isFavorite: Bool
    @Relationship(deleteRule: .cascade) var variants: [PromptVariant]
    var source: String             // "wizard" or "chat"

    init(
        title: String,
        body: String,
        category: String = "",
        tags: [String] = [],
        isFavorite: Bool = false,
        variants: [PromptVariant] = [],
        source: String = "wizard"
    ) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.createdAt = Date()
        self.updatedAt = Date()
        self.category = category
        self.tags = tags
        self.isFavorite = isFavorite
        self.variants = variants
        self.source = source
    }
}
