import CoreGraphics

// MARK: - DoppioSpacingTokens

/// Concrete spacing token implementation for the Doppio app.
/// 8-pt base grid, matching the Brew standard scale.
public struct DoppioSpacingTokens: SpacingTokens {
    public let xxs: CGFloat  =  4
    public let xs: CGFloat   =  8
    public let sm: CGFloat   = 12
    public let md: CGFloat   = 16
    public let lg: CGFloat   = 24
    public let xl: CGFloat   = 32
    public let xxl: CGFloat  = 48
    public let xxxl: CGFloat = 64
}

// MARK: - DoppioRadiusTokens

/// Concrete corner radius token implementation for the Doppio app.
public struct DoppioRadiusTokens: RadiusTokens {
    public let none: CGFloat =   0
    public let xs: CGFloat   =   4
    public let sm: CGFloat   =   8
    public let md: CGFloat   =  12
    public let lg: CGFloat   =  16
    public let xl: CGFloat   =  24
    public let full: CGFloat = 999
}
