import SwiftUI

// MARK: - DesignTokens

/// Central protocol that every app must conform to in order to provide
/// its concrete design token values to the Brew component library.
///
/// Usage:
///   1. Create a concrete type in your App layer (e.g. `RaipeTokens`)
///   2. Conform it to `DesignTokens`
///   3. Inject it via `BrewTheme` at app startup: `.environment(BrewTheme(RaipeTokens()))`
///
/// Brew components read tokens via `@Environment(BrewTheme.self) private var theme`.
/// Never reference a concrete token type (e.g. `RaipeTokens`) inside Brew/.
public protocol DesignTokens {
    var colors: any ColorTokens { get }
    var typography: any TypographyTokens { get }
    var spacing: any SpacingTokens { get }
    var radius: any RadiusTokens { get }
}

// MARK: - ColorTokens

/// Semantic color contract. Apps provide hex/rgba values; Brew uses role names only.
public protocol ColorTokens {

    // MARK: Brand — Primary
    var primaryMain: Color { get }
    var primaryLighter: Color { get }
    var primaryLight: Color { get }
    var primaryDark: Color { get }
    var primaryDarker: Color { get }

    // MARK: Brand — Gradients
    var gradientIcons: LinearGradient { get }
    var gradientTitles: LinearGradient { get }
    var gradientPremium: LinearGradient { get }
    var gradientError: LinearGradient { get }
    var gradientBackground: LinearGradient { get }
    var gradientSuccess: LinearGradient { get }

    // MARK: Neutral — Gray scale
    var gray100: Color { get }
    var gray200: Color { get }
    var gray300: Color { get }
    var gray400: Color { get }
    var gray500: Color { get }
    var gray600: Color { get }
    var gray700: Color { get }
    var gray800: Color { get }
    var gray900: Color { get }

    // MARK: Feedback
    var errorMain: Color { get }
    var errorLight: Color { get }
    var errorDark: Color { get }

    var successMain: Color { get }
    var successLight: Color { get }
    var successDark: Color { get }

    var warningMain: Color { get }
    var warningLight: Color { get }
    var warningDark: Color { get }

    // MARK: Brand accent
    var creditGold: Color { get }

    // MARK: Semantic aliases (used by components)
    var backgroundPrimary: Color { get }
    var backgroundSecondary: Color { get }
    var backgroundCard: Color { get }

    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var textDisabled: Color { get }
    var textOnDark: Color { get }

    var borderDefault: Color { get }
    var borderFocused: Color { get }
    var borderError: Color { get }
}

// MARK: - ColorTokens default implementations

public extension ColorTokens {
    /// Fallback for themes that do not define a credit gold accent.
    var creditGold: Color { Color(hex: "#F5C518") }
}

// MARK: - TypographyTokens

/// Semantic typography contract.
/// Apps define which concrete font families map to each semantic role.
public protocol TypographyTokens {

    // MARK: Font families (semantic roles)
    /// Primary font — used for titles and interactive elements.
    var fontFamilyTitle: String { get }
    /// Secondary font — used for body, tags, captions and smaller text.
    var fontFamilyBody: String { get }

    // MARK: Title styles (DM Sans / fontFamilyTitle)
    var titleH1: Font { get }   // 56pt, Bold 700, lineHeight 120%
    var titleH2: Font { get }   // 48pt, Bold 700, lineHeight 120%
    var titleH3: Font { get }   // 40pt, Bold 700, lineHeight 120%
    var titleH4: Font { get }   // 32pt, Bold 700, lineHeight 120%
    var titleH5: Font { get }   // 24pt, Bold 700, lineHeight 120%
    var titleH6: Font { get }   // 20pt, Bold 700, lineHeight 130%

    // Display — ExtraBold 800 (logo, splash, hero feature text)
    var displayLarge: Font { get }   // 40pt, ExtraBold 800
    var displayMedium: Font { get }  // 32pt, ExtraBold 800
    var displaySmall: Font { get }   // 24pt, ExtraBold 800

    // Label — SemiBold 600 (buttons, rail headers, form labels)
    var labelLarge: Font { get }   // 16pt, SemiBold 600
    var labelMedium: Font { get }  // 14pt, SemiBold 600
    var labelSmall: Font { get }   // 12pt, SemiBold 600

    // Caption — Medium 500 (tab bar labels, metadata)
    var captionLarge: Font { get }   // 12pt, Medium 500
    var captionMedium: Font { get }  // 10pt, Medium 500

    // MARK: Body styles (Avenir / fontFamilyBody)
    var bodyXLargeBold: Font { get }      // 18pt, 700, lh 140%
    var bodyXLargeSemibold: Font { get }  // 18pt, 600, lh 140%
    var bodyXLargeMedium: Font { get }    // 18pt, 500, lh 140%
    var bodyXLargeRegular: Font { get }   // 18pt, 400, lh 140%

    var bodyLargeBold: Font { get }       // 16pt, 700, lh 150%
    var bodyLargeSemibold: Font { get }   // 16pt, 600, lh 150%
    var bodyLargeMedium: Font { get }     // 16pt, 500, lh 150%
    var bodyLargeRegular: Font { get }    // 16pt, 400, lh 150%

    var bodyMediumBold: Font { get }      // 14pt, 700, lh 150%
    var bodyMediumSemibold: Font { get }  // 14pt, 600, lh 150%
    var bodyMediumMedium: Font { get }    // 14pt, 500, lh 150%
    var bodyMediumRegular: Font { get }   // 14pt, 400, lh 150%

    var bodySmallBold: Font { get }       // 12pt, 700, lh 150%
    var bodySmallSemibold: Font { get }   // 12pt, 600, lh 150%
    var bodySmallMedium: Font { get }     // 12pt, 500, lh 150%
    var bodySmallRegular: Font { get }    // 12pt, 400, lh 150%

    var overlineBold: Font { get }        // 10pt, 700, lh 150%, tracking 1pt

    // MARK: Line height multipliers (reference values)
    /// 120% — titles and large headings
    var lineHeightTight: CGFloat { get }
    /// 140% — medium headings
    var lineHeightMedium: CGFloat { get }
    /// 150% — body text
    var lineHeightSpaced: CGFloat { get }
    /// 180% — long-form text
    var lineHeightDistant: CGFloat { get }
}

// MARK: - SpacingTokens

/// 8-pt base spacing scale.
/// Apps can override values but must conform to the semantic names.
public protocol SpacingTokens {
    var xxs: CGFloat { get }  //  4pt
    var xs: CGFloat { get }   //  8pt
    var sm: CGFloat { get }   // 12pt
    var md: CGFloat { get }   // 16pt
    var lg: CGFloat { get }   // 24pt
    var xl: CGFloat { get }   // 32pt
    var xxl: CGFloat { get }  // 48pt
    var xxxl: CGFloat { get } // 64pt
}

// MARK: - RadiusTokens

/// Corner radius scale used across cards, buttons, inputs and sheets.
public protocol RadiusTokens {
    var none: CGFloat { get }   //  0
    var xs: CGFloat { get }     //  4
    var sm: CGFloat { get }     //  8
    var md: CGFloat { get }     // 12
    var lg: CGFloat { get }     // 16
    var xl: CGFloat { get }     // 24
    var full: CGFloat { get }   // 999 (pill / fully rounded)

    // MARK: Semantic role aliases
    var radiusCard: CGFloat { get }     // container-level (cards, sheets) — default: md = 12
    var radiusControl: CGFloat { get }  // inputs and primary buttons — default: 10
    var radiusChip: CGFloat { get }     // small option chips — default: sm = 8
}

public extension RadiusTokens {
    var radiusCard: CGFloat { md }
    var radiusControl: CGFloat { 10 }
    var radiusChip: CGFloat { sm }
}
