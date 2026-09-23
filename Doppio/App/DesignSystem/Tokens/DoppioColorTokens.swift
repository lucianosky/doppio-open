import SwiftUI

// MARK: - DoppioColorTokens

/// Concrete color token implementation for the Doppio app.
///
/// All values are fixed hex — Doppio is a dark-only app.
/// `Color(hex:)` is resolved once at init time; never call it inside a SwiftUI body.
///
/// Palette reference: DESIGN.md (espresso dark aesthetic)
/// Background #15100A · Surface #241A10 · Surface Elevated #2E2218
/// Text Primary #F2E6D0 · Text Secondary #8A7A6A
/// Accent Orange #E85C0D · Accent Red #C0392B · Accent Green #6BAF92
public struct DoppioColorTokens: ColorTokens {

    // MARK: Brand — Primary (Accent Orange)

    public let primaryMain: Color    = Color(hex: "#E85C0D")  // CTA, active tab, status Aberto
    public let primaryLighter: Color = Color(hex: "#F28A50")
    public let primaryLight: Color   = Color(hex: "#F5B08A")
    public let primaryDark: Color    = Color(hex: "#B84A0A")
    public let primaryDarker: Color  = Color(hex: "#8B3A07")

    // MARK: Brand — Gradients

    private let _gradOrangeStart: Color  = Color(hex: "#E85C0D")
    private let _gradOrangeEnd: Color    = Color(hex: "#B84A0A")
    private let _gradErrorStart: Color   = Color(hex: "#C0392B")
    private let _gradErrorEnd: Color     = Color(hex: "#E74C3C")
    private let _gradSuccessStart: Color = Color(hex: "#6BAF92")
    private let _gradSuccessEnd: Color   = Color(hex: "#4A9070")
    private let _gradBgStart: Color      = Color(hex: "#15100A")
    private let _gradBgEnd: Color        = Color(hex: "#241A10")

    public var gradientIcons: LinearGradient {
        LinearGradient(colors: [_gradOrangeStart, _gradOrangeEnd], startPoint: .leading, endPoint: .trailing)
    }
    public var gradientTitles: LinearGradient {
        LinearGradient(colors: [_gradOrangeStart, _gradOrangeEnd], startPoint: .leading, endPoint: .trailing)
    }
    public var gradientPremium: LinearGradient {
        LinearGradient(colors: [_gradOrangeStart, _gradOrangeEnd], startPoint: .leading, endPoint: .trailing)
    }
    public var gradientError: LinearGradient {
        LinearGradient(colors: [_gradErrorStart, _gradErrorEnd], startPoint: .leading, endPoint: .trailing)
    }
    public var gradientBackground: LinearGradient {
        LinearGradient(colors: [_gradBgStart, _gradBgEnd], startPoint: .top, endPoint: .bottom)
    }
    public var gradientSuccess: LinearGradient {
        LinearGradient(colors: [_gradSuccessStart, _gradSuccessEnd], startPoint: .leading, endPoint: .trailing)
    }

    // MARK: Neutral — Warm dark scale (espresso browns)

    public let gray100: Color = Color(hex: "#2E2218")  // Surface Elevated
    public let gray200: Color = Color(hex: "#2A1F14")  // Separator
    public let gray300: Color = Color(hex: "#241A10")  // Surface
    public let gray400: Color = Color(hex: "#1E1610")
    public let gray500: Color = Color(hex: "#8A7A6A")  // Text Secondary
    public let gray600: Color = Color(hex: "#6A5A4A")
    public let gray700: Color = Color(hex: "#4A3A2A")
    public let gray800: Color = Color(hex: "#2A1F14")
    public let gray900: Color = Color(hex: "#15100A")  // Background

    // MARK: Feedback — Error (Accent Red)

    public let errorMain: Color  = Color(hex: "#C0392B")  // status Fechado, alertas
    public let errorLight: Color = Color(hex: "#3A1A18")
    public let errorDark: Color  = Color(hex: "#C0392B")

    // MARK: Feedback — Success (Accent Green)

    public let successMain: Color  = Color(hex: "#6BAF92")  // badges de categoria, estados positivos
    public let successLight: Color = Color(hex: "#1E3028")
    public let successDark: Color  = Color(hex: "#4A9070")

    // MARK: Feedback — Warning

    public let warningMain: Color  = Color(hex: "#F6A623")
    public let warningLight: Color = Color(hex: "#3A2A10")
    public let warningDark: Color  = Color(hex: "#C08010")

    // MARK: Semantic aliases

    /// #15100A — background primário (espresso escuro)
    public let backgroundPrimary: Color   = Color(hex: "#15100A")

    /// #2E2218 — surface elevada: modais, sheets, tab bar, nav bar
    public let backgroundSecondary: Color = Color(hex: "#2E2218")

    /// #241A10 — surface: cards, células de lista
    public let backgroundCard: Color      = Color(hex: "#241A10")

    /// #F2E6D0 — texto primário (creme do leite vaporizado)
    public let textPrimary: Color   = Color(hex: "#F2E6D0")

    /// #8A7A6A — texto secundário (latte — legendas, datas, hints)
    public let textSecondary: Color = Color(hex: "#8A7A6A")

    public let textDisabled: Color  = Color(hex: "#4A3A2A")
    public let textOnDark: Color    = Color(hex: "#FFFFFF")

    /// #2A1F14 — separador sutil entre elementos
    public let borderDefault: Color = Color(hex: "#2A1F14")

    /// #E85C0D — borda focada (Accent Orange)
    public let borderFocused: Color = Color(hex: "#E85C0D")

    /// #C0392B — borda de erro (Accent Red)
    public let borderError: Color   = Color(hex: "#C0392B")
}
