import SwiftUI
import SwiftData

@main
struct PromptCoachApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            UserProfile.self,
            Prompt.self,
            PromptVariant.self,
            LessonProgress.self
        ])
    }
}
