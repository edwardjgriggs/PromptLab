import SwiftUI

/// A button that copies text to the clipboard with haptic feedback and a toast confirmation.
struct CopyButton: View {
    let text: String
    let label: String

    @State private var showCopied = false

    init(_ text: String, label: String = "Copy") {
        self.text = text
        self.label = label
    }

    var body: some View {
        Button {
            UIPasteboard.general.string = text
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            showCopied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showCopied = false
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                Text(showCopied ? "Copied!" : label)
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(showCopied ? Color.green : Color.accentColor)
        }
        .animation(.easeInOut(duration: 0.2), value: showCopied)
        .accessibilityLabel(showCopied ? "Copied to clipboard" : "Copy \(label)")
    }
}
