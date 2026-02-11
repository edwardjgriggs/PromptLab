import SwiftUI

/// A small chip/pill view for displaying tags.
struct TagChip: View {
    let text: String
    var isSelected: Bool = false
    var onTap: (() -> Void)?

    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .onTapGesture {
                onTap?()
            }
            .accessibilityAddTraits(onTap != nil ? .isButton : [])
            .accessibilityLabel(text)
    }
}
