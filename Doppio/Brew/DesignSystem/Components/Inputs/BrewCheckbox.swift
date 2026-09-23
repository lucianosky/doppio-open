import SwiftUI

// MARK: - BrewCheckbox

/// Checkbox used in forms (terms acceptance, keep me logged in, etc).
/// Supports attributed string labels for inline links (e.g. Termos de uso).
///
/// Usage:
/// ```swift
/// BrewCheckbox(isChecked: $acceptedTerms) {
///     Text("Concordo com os ") + Text("Termos e Condições").underline()
/// }
/// ```
public struct BrewCheckbox<Label: View>: View {

    @Binding private var isChecked: Bool
    private let label: () -> Label

    @Environment(BrewTheme.self) private var theme

    public init(
        isChecked: Binding<Bool>,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self._isChecked = isChecked
        self.label = label
    }

    public var body: some View {
        Button(action: { isChecked.toggle() }, label: {
            HStack(alignment: .top, spacing: theme.tokens.spacing.xs) {
                checkboxIcon
                label()
                    .font(theme.tokens.typography.bodyMediumRegular)
                    .foregroundColor(theme.tokens.colors.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        })
        .buttonStyle(.plain)
    }

    private var checkboxIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: theme.tokens.radius.xs)
                .fill(isChecked ? Color.white : Color.clear)
                .frame(width: 18, height: 18)

            RoundedRectangle(cornerRadius: theme.tokens.radius.xs)
                .strokeBorder(
                    isChecked ? Color.white : theme.tokens.colors.textPrimary.opacity(0.72),
                    lineWidth: 1.5
                )
                .frame(width: 18, height: 18)

            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(theme.tokens.colors.primaryDark)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isChecked)
    }
}
