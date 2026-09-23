// BrewBadges.swift
// Brew/DesignSystem/Components/Badges
//
// Domain-agnostic badge components.
//
// BrewGenreBadge has been removed — genre is a Raipe domain concept.
// Use RaipeGenreBadge (App/DesignSystem/Components/Badges/RaipeBadges.swift) instead.
// For badges displayed over poster images, use RaipeHeroBadge.

import SwiftUI

// MARK: - BrewEpisodeBadge

/// Numbered episode range badge (01-11, 11-20, etc.).
///
/// Usage:
/// ```swift
/// BrewEpisodeBadge("01-11", isActive: currentRange == "01-11")
/// ```
public struct BrewEpisodeBadge: View {

    private let label: String
    private let isActive: Bool
    @Environment(BrewTheme.self) private var theme

    public init(_ label: String, isActive: Bool = false) {
        self.label = label
        self.isActive = isActive
    }

    public var body: some View {
        Text(label)
            .font(theme.tokens.typography.bodySmallMedium)
            .foregroundColor(isActive ? theme.tokens.colors.textPrimary : theme.tokens.colors.textSecondary)
            .padding(.horizontal, theme.tokens.spacing.sm)
            .padding(.vertical, theme.tokens.spacing.xxs)
            .background(
                RoundedRectangle(cornerRadius: theme.tokens.radius.xs)
                    .fill(isActive ? theme.tokens.colors.primaryDark : Color.clear)
            )
    }
}

// MARK: - BrewAccessBadge

/// Free / Paid access indicator badge on episode rows.
///
/// Usage:
/// ```swift
/// BrewAccessBadge(isFree: episode.accessModel == .free)
/// ```
public struct BrewAccessBadge: View {

    public enum AccessType {
        case free
        case paid
        case new        // "Novidade" — gradient pill
    }

    private let accessType: AccessType
    @Environment(BrewTheme.self) private var theme

    public init(_ accessType: AccessType) {
        self.accessType = accessType
    }

    public var body: some View {
        Group {
            switch accessType {
            case .free:
                label(String(localized: "badge.free"), textColor: theme.tokens.colors.successDark,
                      background: theme.tokens.colors.successMain.opacity(0.2),
                      border: theme.tokens.colors.successMain)
            case .paid:
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(theme.tokens.colors.warningMain)
                    Text(String(localized: "badge.paid"))
                        .font(theme.tokens.typography.bodySmallMedium)
                        .foregroundColor(theme.tokens.colors.warningMain)
                }
                .padding(.horizontal, theme.tokens.spacing.xs)
                .padding(.vertical, theme.tokens.spacing.xxs)
                .background(
                    Capsule().fill(theme.tokens.colors.warningMain.opacity(0.15))
                )
                .overlay(Capsule().strokeBorder(theme.tokens.colors.warningMain, lineWidth: 1))
            case .new:
                Text(String(localized: "badge.new"))
                    .font(theme.tokens.typography.bodySmallMedium)
                    .foregroundColor(.white)
                    .padding(.horizontal, theme.tokens.spacing.xs)
                    .padding(.vertical, theme.tokens.spacing.xxs)
                    .background(Capsule().fill(theme.tokens.colors.gradientTitles))
            }
        }
    }

    private func label(
        _ text: String,
        textColor: Color,
        background: Color,
        border: Color
    ) -> some View {
        Text(text)
            .font(theme.tokens.typography.bodySmallMedium)
            .foregroundColor(textColor)
            .padding(.horizontal, theme.tokens.spacing.xs)
            .padding(.vertical, theme.tokens.spacing.xxs)
            .background(Capsule().fill(background))
            .overlay(Capsule().strokeBorder(border, lineWidth: 1))
    }
}

// MARK: - BrewAlertBanner

/// Full-width colored alert banner (error / warning / success).
/// Used at the top of screens for account alerts.
///
/// Usage:
/// ```swift
/// BrewAlertBanner(
///     style: .error,
///     message: "Encontramos problemas na sua conta.",
///     actionLabel: "Verificar"
/// ) {
///     viewModel.openSecurityCenter()
/// }
/// ```
public struct BrewAlertBanner: View {

    public enum AlertStyle {
        case error    // red
        case warning  // orange/yellow
        case success  // green
    }

    private let style: AlertStyle
    private let message: String
    private let actionLabel: String?
    private let onAction: (() -> Void)?
    private let onDismiss: (() -> Void)?

    @Environment(BrewTheme.self) private var theme

    public init(
        style: AlertStyle,
        message: String,
        actionLabel: String? = nil,
        onAction: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.style = style
        self.message = message
        self.actionLabel = actionLabel
        self.onAction = onAction
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: theme.tokens.spacing.sm) {
            Button(action: { onDismiss?() }, label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            })

            Text(message)
                .font(theme.tokens.typography.bodySmallMedium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let actionLabel {
                Button(action: { onAction?() }, label: {
                    Text(actionLabel)
                        .font(theme.tokens.typography.bodySmallSemibold)
                        .foregroundColor(bannerColor)
                        .padding(.horizontal, theme.tokens.spacing.sm)
                        .padding(.vertical, theme.tokens.spacing.xxs)
                        .background(Capsule().fill(.white))
                })
            }
        }
        .padding(.horizontal, theme.tokens.spacing.md)
        .padding(.vertical, theme.tokens.spacing.sm)
        .background(bannerColor)
    }

    private var bannerColor: Color {
        switch style {
        case .error:   return theme.tokens.colors.errorMain
        case .warning: return theme.tokens.colors.warningMain
        case .success: return theme.tokens.colors.successMain
        }
    }
}

// MARK: - BrewPaymentStatusBadge

/// Inline badge for payment status alerts (PAGAMENTO PENDENTE, Pagamento não aprovado).
///
/// Usage:
/// ```swift
/// BrewPaymentStatusBadge(status: .pending)
/// ```
public struct BrewPaymentStatusBadge: View {

    public enum PaymentStatus {
        case pending   // warning color
        case rejected  // error color
    }

    private let status: PaymentStatus
    @Environment(BrewTheme.self) private var theme

    public init(status: PaymentStatus) {
        self.status = status
    }

    public var body: some View {
        HStack(spacing: theme.tokens.spacing.xxs) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 12))
            Text(statusLabel)
                .font(theme.tokens.typography.overlineBold)
                .tracking(1)
        }
        .foregroundColor(statusColor)
        .padding(.horizontal, theme.tokens.spacing.sm)
        .padding(.vertical, theme.tokens.spacing.xxs)
        .overlay(Capsule().strokeBorder(statusColor, lineWidth: 1))
    }

    private var statusLabel: String {
        switch status {
        case .pending:  return String(localized: "badge.payment.pending")
        case .rejected: return String(localized: "badge.payment.rejected")
        }
    }

    private var statusColor: Color {
        switch status {
        case .pending:  return theme.tokens.colors.warningMain
        case .rejected: return theme.tokens.colors.errorMain
        }
    }
}
