import SwiftUI

// MARK: - DoppioTypographyTokens

/// Concrete typography token implementation for the Doppio app.
///
/// Doppio uses system fonts exclusively — no custom font files required.
/// All Font values are stored properties resolved once at init time.
public struct DoppioTypographyTokens: TypographyTokens {

    // MARK: Font family names (informational — system fonts have no custom name)

    public let fontFamilyTitle: String = "-apple-system"
    public let fontFamilyBody: String  = "-apple-system"

    // MARK: Line height multipliers

    public let lineHeightTight: CGFloat   = 1.20
    public let lineHeightMedium: CGFloat  = 1.40
    public let lineHeightSpaced: CGFloat  = 1.50
    public let lineHeightDistant: CGFloat = 1.80

    // MARK: Title styles — system Bold

    public let titleH1: Font = .system(size: 56, weight: .bold)
    public let titleH2: Font = .system(size: 48, weight: .bold)
    public let titleH3: Font = .system(size: 40, weight: .bold)
    public let titleH4: Font = .system(size: 32, weight: .bold)
    public let titleH5: Font = .system(size: 24, weight: .bold)
    public let titleH6: Font = .system(size: 20, weight: .bold)

    // MARK: Display — system ExtraBold (Heavy)

    public let displayLarge: Font  = .system(size: 40, weight: .heavy)
    public let displayMedium: Font = .system(size: 32, weight: .heavy)
    public let displaySmall: Font  = .system(size: 24, weight: .heavy)

    // MARK: Label — system SemiBold

    public let labelLarge: Font  = .system(size: 16, weight: .semibold)
    public let labelMedium: Font = .system(size: 14, weight: .semibold)
    public let labelSmall: Font  = .system(size: 12, weight: .semibold)

    // MARK: Caption — system Medium

    public let captionLarge: Font  = .system(size: 12, weight: .medium)
    public let captionMedium: Font = .system(size: 10, weight: .medium)

    // MARK: Body XLarge — 18pt

    public let bodyXLargeBold: Font     = .system(size: 18, weight: .bold)
    public let bodyXLargeSemibold: Font = .system(size: 18, weight: .semibold)
    public let bodyXLargeMedium: Font   = .system(size: 18, weight: .medium)
    public let bodyXLargeRegular: Font  = .system(size: 18, weight: .regular)

    // MARK: Body Large — 16pt

    public let bodyLargeBold: Font     = .system(size: 16, weight: .bold)
    public let bodyLargeSemibold: Font = .system(size: 16, weight: .semibold)
    public let bodyLargeMedium: Font   = .system(size: 16, weight: .medium)
    public let bodyLargeRegular: Font  = .system(size: 16, weight: .regular)

    // MARK: Body Medium — 14pt

    public let bodyMediumBold: Font     = .system(size: 14, weight: .bold)
    public let bodyMediumSemibold: Font = .system(size: 14, weight: .semibold)
    public let bodyMediumMedium: Font   = .system(size: 14, weight: .medium)
    public let bodyMediumRegular: Font  = .system(size: 14, weight: .regular)

    // MARK: Body Small — 12pt

    public let bodySmallBold: Font     = .system(size: 12, weight: .bold)
    public let bodySmallSemibold: Font = .system(size: 12, weight: .semibold)
    public let bodySmallMedium: Font   = .system(size: 12, weight: .medium)
    public let bodySmallRegular: Font  = .system(size: 12, weight: .regular)

    // MARK: Overline — 10pt Bold

    public let overlineBold: Font = .system(size: 10, weight: .bold)
}
