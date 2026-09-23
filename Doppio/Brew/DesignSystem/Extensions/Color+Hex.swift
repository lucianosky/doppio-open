import SwiftUI

// MARK: - Color + Hex

public extension Color {
    /// Initializes a `Color` from a hex string.
    /// Supports `#RRGGBB` and `#RRGGBBAA` formats.
    ///
    /// Usage:
    /// ```swift
    /// Color(hex: "#253068")
    /// Color(hex: "#25306880") // with alpha
    /// ```
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red, green, blue, alpha: UInt64
        switch hex.count {
        case 6:
            (red, green, blue, alpha) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF, 255)
        case 8:
            (red, green, blue, alpha) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (red, green, blue, alpha) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
