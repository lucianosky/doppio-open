import SwiftUI

// MARK: - LineHeightScale

/// Semantic line height multipliers matching the design system scale.
public enum LineHeightScale {
    /// 120% — large titles and headings
    case tight
    /// 140% — medium headings
    case medium
    /// 150% — body text
    case spaced
    /// 180% — long-form articles and terms
    case distant
}

// MARK: - LineHeightModifier

private struct LineHeightModifier: ViewModifier {
    @Environment(BrewTheme.self) private var theme
    let scale: LineHeightScale
    let fontSize: CGFloat

    func body(content: Content) -> some View {
        let multiplier: CGFloat
        switch scale {
        case .tight:   multiplier = theme.tokens.typography.lineHeightTight
        case .medium:  multiplier = theme.tokens.typography.lineHeightMedium
        case .spaced:  multiplier = theme.tokens.typography.lineHeightSpaced
        case .distant: multiplier = theme.tokens.typography.lineHeightDistant
        }
        let lineSpacing = (fontSize * multiplier) - fontSize
        return content.lineSpacing(max(0, lineSpacing))
    }
}

// MARK: - View + lineHeight

public extension View {
    /// Applies correct line spacing for a given semantic scale and font size.
    ///
    /// SwiftUI doesn't expose a direct `lineHeight` API, so this approximates
    /// it via `lineSpacing`, which adds space *between* lines (not above the first).
    ///
    /// Usage:
    /// ```swift
    /// Text("Hello world")
    ///     .font(theme.tokens.typography.bodyLargeRegular)
    ///     .lineHeight(.spaced, fontSize: 16)
    /// ```
    func lineHeight(_ scale: LineHeightScale, fontSize: CGFloat) -> some View {
        modifier(LineHeightModifier(scale: scale, fontSize: fontSize))
    }
}
