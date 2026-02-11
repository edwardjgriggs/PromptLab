import Foundation
import SwiftData

/// Stores the user's onboarding preferences and profile settings.
@Model
final class UserProfile {
    var id: UUID
    var createdAt: Date
    var preferredCategories: [String]
    var verbosity: String          // "short" or "detailed"
    var targetModel: String        // "generic", "chatgpt", or "claude"
    var hasSeenOnboarding: Bool

    init(
        preferredCategories: [String] = [],
        verbosity: String = "detailed",
        targetModel: String = "generic",
        hasSeenOnboarding: Bool = false
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.preferredCategories = preferredCategories
        self.verbosity = verbosity
        self.targetModel = targetModel
        self.hasSeenOnboarding = hasSeenOnboarding
    }
}
