import SwiftUI

// MARK: - DoppioTokens

/// Root design token implementation for the Doppio app.
/// Assembles all concrete token groups and conforms to `DesignTokens`.
///
/// **Setup — inject via environment at app root:**
/// ```swift
/// let theme = BrewTheme(DoppioTokens())
/// WindowGroup { ContentView() }.environment(theme)
/// ```
public struct DoppioTokens: DesignTokens {
    public let colors: any ColorTokens
    public let typography: any TypographyTokens
    public let spacing: any SpacingTokens
    public let radius: any RadiusTokens

    public init() {
        colors     = DoppioColorTokens()
        typography = DoppioTypographyTokens()
        spacing    = DoppioSpacingTokens()
        radius     = DoppioRadiusTokens()
    }
}
