import SwiftUI

// MARK: - BrewButtonStyle

/// Visual style variants for `BrewActionButton`.
public enum BrewButtonStyle {
    /// White background, primary-colored label. Main CTA.
    case primary
    /// Solid dark fill (primaryDarker). Secondary CTA.
    case secondary
    /// Solid blue fill (primaryDark). Tertiary solid CTA.
    case solid
    /// Transparent background, primary-colored border and label.
    case outlined
    /// Transparent background, primary-colored label only.
    case ghost
    /// Destructive action — error-colored border and label.
    case destructive
    /// Disabled state — applies automatically when `isEnabled = false`.
    case disabled
}

// MARK: - BrewButtonSize

public enum BrewButtonSize {
    /// Full-width tall button (~52pt). Default for most screens.
    case large
    /// Compact button (~36pt). Used in cards and inline actions.
    case small
}

// MARK: - BrewActionButton

/// Generic reusable button for the Brew design system.
/// App-agnostic: reads all values from the injected `BrewTheme` environment.
///
/// Usage:
/// ```swift
/// BrewActionButton("Entrar", style: .primary, trailingChevron: true) {
///     viewModel.login()
/// }
/// BrewActionButton("Copiar link", style: .outlined, icon: "link") {
///     viewModel.copyLink()
/// }
/// ```
public struct BrewActionButton: View {

    private let label: String
    private let style: BrewButtonStyle
    private let size: BrewButtonSize
    private let icon: String?
    private let trailingChevron: Bool
    private let isLoading: Bool
    private let isEnabled: Bool
    private let action: () -> Void

    @Environment(BrewTheme.self) private var theme
    @Environment(\.isEnabled) private var environmentIsEnabled

    public init(
        _ label: String,
        style: BrewButtonStyle = .primary,
        size: BrewButtonSize = .large,
        icon: String? = nil,
        trailingChevron: Bool = false,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.style = style
        self.size = size
        self.icon = icon
        self.trailingChevron = trailingChevron
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: { if isEnabled && !isLoading { action() } }, label: {
            ZStack {
                buttonBackground
                if trailingChevron && !isLoading {
                    // Text centered, chevron pinned to trailing edge
                    Text(label)
                        .font(theme.tokens.typography.labelLarge)
                        .foregroundColor(labelColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(labelColor)
                    }
                    .padding(.horizontal, theme.tokens.spacing.md)
                } else {
                    HStack(spacing: theme.tokens.spacing.xs) {
                        if let icon {
                            Image(systemName: icon)
                                .font(.system(size: iconSize, weight: .semibold))
                                .foregroundColor(labelColor)
                        }
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(labelColor)
                                .scaleEffect(0.8)
                        } else {
                            Text(label)
                                .font(theme.tokens.typography.labelLarge)
                                .foregroundColor(labelColor)
                        }
                    }
                    .padding(.horizontal, theme.tokens.spacing.md)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .clipShape(Capsule())
            .overlay(buttonBorder)
        })
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled && environmentIsEnabled ? 1 : 0.5)
    }

    private var buttonHeight: CGFloat { size == .large ? 52 : 36 }
    private var iconSize: CGFloat { size == .large ? 16 : 13 }

    @ViewBuilder private var buttonBackground: some View {
        let colors = theme.tokens.colors
        switch style {
        case .primary:     Capsule().fill(Color.white)
        case .secondary:   Capsule().fill(colors.primaryMain)
        case .solid:       Capsule().fill(colors.primaryDark)
        case .outlined:    Capsule().fill(Color.clear)
        case .ghost:       Capsule().fill(Color.clear)
        case .destructive: Capsule().fill(Color.clear)
        case .disabled:    Capsule().fill(colors.gray600)
        }
    }

    @ViewBuilder private var buttonBorder: some View {
        let colors = theme.tokens.colors
        switch style {
        case .outlined:    Capsule().strokeBorder(colors.primaryDark, lineWidth: 1.5)
        case .destructive: Capsule().strokeBorder(colors.errorMain, lineWidth: 1.5)
        case .ghost:       Capsule().strokeBorder(colors.gray600, lineWidth: 1)
        case .disabled:    Capsule().strokeBorder(colors.gray600, lineWidth: 1)
        default:           EmptyView()
        }
    }

    private var labelColor: Color {
        let colors = theme.tokens.colors
        switch style {
        case .primary:     return colors.primaryDark
        case .secondary:   return colors.textPrimary
        case .solid:       return colors.textPrimary
        case .outlined:    return colors.primaryDark
        case .ghost:       return colors.primaryDark
        case .destructive: return colors.errorMain
        case .disabled:    return colors.textDisabled
        }
    }
}

// MARK: - Preview
// Inject your app tokens via .environment(BrewTheme(YourAppTokens())) on the preview container.
