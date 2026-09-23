import SwiftUI
import Observation

// MARK: - BrewTheme

/// Observable theme container. Inject once at app startup via `.environment(theme)`.
///
/// **Setup — in your App entry point:**
/// ```swift
/// @main
/// struct MyApp: App {
///     let theme = BrewTheme(MyAppTokens())
///     var body: some Scene {
///         WindowGroup { RootView() }
///             .environment(theme)
///     }
/// }
/// ```
///
/// **Usage inside Brew components:**
/// ```swift
/// @Environment(BrewTheme.self) private var theme
/// // theme.tokens.colors.primaryMain
/// // theme.tokens.typography.titleH1
/// // theme.tokens.spacing.md
/// ```
///
/// IMPORTANT: Never reference concrete token types (e.g. `RaipeTokens`)
/// inside Brew/. The Brew layer must remain app-agnostic.
@Observable
public final class BrewTheme {

    /// The active design tokens for this theme.
    public let tokens: any DesignTokens

    public init(_ tokens: any DesignTokens) {
        self.tokens = tokens
    }
}
