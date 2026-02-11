import SwiftUI
import SwiftData

/// Root view that decides whether to show onboarding or the main tab view.
struct RootView: View {
    @Query private var profiles: [UserProfile]

    var body: some View {
        if let profile = profiles.first, profile.hasSeenOnboarding {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}
