import SwiftUI

/// A horizontal step progress indicator for the Generator wizard.
struct StepProgressBar: View {
    let totalSteps: Int
    let currentStep: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.accentColor : Color(.systemGray4))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.25), value: currentStep)
        .accessibilityLabel("Step \(currentStep + 1) of \(totalSteps)")
    }
}
