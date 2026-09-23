// BrewFeedback.swift
// Brew/DesignSystem/Components/Feedback

import SwiftUI

// MARK: - BrewModal

/// Generic modal dialog (bottom sheet style).
/// Used for confirmation dialogs and account deletion flows.
///
/// Usage:
/// ```swift
/// BrewModal(
///     title: "Excluir conta",
///     subtitle: "Ah não! Não nos deixe...",
///     message: "Antes de prosseguir, ...",
///     primaryAction: .init(label: "Cancelar", style: .solid) { isPresented = false },
///     secondaryAction: .init(label: "Excluir", style: .destructive) { viewModel.deleteAccount() }
/// )
/// ```
public struct BrewModal: View {

    // MARK: ModalAction

    public struct ModalAction {
        public let label: String
        public let style: BrewButtonStyle
        public let action: () -> Void

        public init(label: String, style: BrewButtonStyle, action: @escaping () -> Void) {
            self.label = label
            self.style = style
            self.action = action
        }
    }

    // MARK: Properties

    private let title: String
    private let subtitle: String?
    private let message: String?          // renamed from `body` to avoid conflict with View.body
    private let primaryAction: ModalAction
    private let secondaryAction: ModalAction?
    private let onDismiss: (() -> Void)?

    @Environment(BrewTheme.self) private var theme

    // MARK: Init

    public init(
        title: String,
        subtitle: String? = nil,
        message: String? = nil,
        primaryAction: ModalAction,
        secondaryAction: ModalAction? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.onDismiss = onDismiss
    }

    // MARK: Body

    public var body: some View {
        VStack(spacing: theme.tokens.spacing.lg) {
            header
            if let message { messageText(message) }
            actions
        }
        .padding(theme.tokens.spacing.lg)
        .background(theme.tokens.colors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: theme.tokens.radius.xl))
        .padding(.horizontal, theme.tokens.spacing.md)
    }

    private var header: some View {
        VStack(spacing: theme.tokens.spacing.xs) {
            HStack {
                Spacer()
                Button(action: { onDismiss?() }, label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.tokens.colors.textSecondary)
                })
            }
            Text(title)
                .font(theme.tokens.typography.titleH5)
                .foregroundColor(theme.tokens.colors.primaryDark)
                .multilineTextAlignment(.center)
            if let subtitle {
                Text(subtitle)
                    .font(theme.tokens.typography.bodyMediumRegular)
                    .foregroundColor(theme.tokens.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func messageText(_ text: String) -> some View {
        Text(text)
            .font(theme.tokens.typography.bodyMediumRegular)
            .foregroundColor(theme.tokens.colors.textPrimary)
            .multilineTextAlignment(.center)
    }

    private var actions: some View {
        VStack(spacing: theme.tokens.spacing.sm) {
            BrewActionButton(
                primaryAction.label,
                style: primaryAction.style,
                action: primaryAction.action
            )
            if let secondary = secondaryAction {
                BrewActionButton(
                    secondary.label,
                    style: secondary.style,
                    action: secondary.action
                )
            }
        }
    }
}

// MARK: - BrewToast

/// Transient toast notification shown at the top or bottom of the screen.
/// Auto-dismisses after `duration` seconds.
///
/// Usage (in a ZStack overlay):
/// ```swift
/// .overlay(alignment: .top) {
///     if showToast {
///         BrewToast(
///             style: .success,
///             message: "Sua conta agora está mais segura.",
///             duration: 3
///         ) { showToast = false }
///         .transition(.move(edge: .top).combined(with: .opacity))
///     }
/// }
/// ```
public struct BrewToast: View {

    public enum ToastStyle {
        case success
        case error
        case warning
    }

    private let style: ToastStyle
    private let message: String
    private let duration: TimeInterval
    private let onDismiss: () -> Void

    @Environment(BrewTheme.self) private var theme

    public init(
        style: ToastStyle,
        message: String,
        duration: TimeInterval = 3,
        onDismiss: @escaping () -> Void
    ) {
        self.style = style
        self.message = message
        self.duration = duration
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: theme.tokens.spacing.sm) {
            Image(systemName: toastIcon)
                .font(.system(size: 14, weight: .bold))
            Text(message)
                .font(theme.tokens.typography.bodySmallMedium)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, theme.tokens.spacing.md)
        .padding(.vertical, theme.tokens.spacing.sm)
        .background(toastColor)
        .task {
            try? await Task.sleep(for: .seconds(duration))
            onDismiss()
        }
    }

    private var toastColor: Color {
        switch style {
        case .success: return theme.tokens.colors.successMain
        case .error:   return theme.tokens.colors.errorMain
        case .warning: return theme.tokens.colors.warningMain
        }
    }

    private var toastIcon: String {
        switch style {
        case .success: return "checkmark.circle.fill"
        case .error:   return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - BrewPasswordValidationView

/// Password strength indicator used in the create-password flow.
/// Displays a list of rules with check/cross icons.
///
/// Usage:
/// ```swift
/// BrewPasswordValidationView(password: $password)
/// ```
public struct BrewPasswordValidationView: View {

    @Binding private var password: String
    @Binding private var confirmPassword: String
    @Environment(BrewTheme.self) private var theme

    public init(password: Binding<String>, confirmPassword: Binding<String> = .constant("")) {
        self._password = password
        self._confirmPassword = confirmPassword
    }

    private var rules: [(label: String, isMet: Bool)] {
        var base: [(label: String, isMet: Bool)] = [
            (String(localized: "password.rule.length"), password.count >= 8),
            (String(localized: "password.rule.letters"), password.filter(\.isLetter).count >= 2),
            (String(localized: "password.rule.uppercase"), password.contains(where: \.isUppercase)),
            (String(localized: "password.rule.special"), password.contains(where: { "#@!%&-".contains($0) }))
        ]
        if !confirmPassword.isEmpty {
            base.append((String(localized: "password.rule.match"), !password.isEmpty && password == confirmPassword))
        }
        return base
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.tokens.spacing.xxs) {
            ForEach(rules, id: \.label) { rule in
                HStack(spacing: theme.tokens.spacing.xs) {
                    Image(systemName: rule.isMet ? "checkmark" : "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(rule.isMet ? theme.tokens.colors.successMain : theme.tokens.colors.errorMain)
                    Text(rule.label)
                        .font(theme.tokens.typography.bodySmallRegular)
                        .foregroundColor(theme.tokens.colors.textSecondary)
                }
            }
        }
    }
}

// MARK: - BrewDeviceRow

/// Device management list row (Dispositivos conectados screen).
///
/// Usage:
/// ```swift
/// BrewDeviceRow(
///     platform: .iPhone,
///     name: "iPhone 13",
///     detail: "Este dispositivo • Online",
///     isCurrentDevice: true,
///     onDelete: nil
/// )
/// ```
public struct BrewDeviceRow: View {

    public enum Platform {
        case iPhone, android
    }

    private let platform: Platform
    private let name: String
    private let detail: String
    private let isCurrentDevice: Bool
    private let onDelete: (() -> Void)?

    @Environment(BrewTheme.self) private var theme

    public init(
        platform: Platform,
        name: String,
        detail: String,
        isCurrentDevice: Bool = false,
        onDelete: (() -> Void)? = nil
    ) {
        self.platform = platform
        self.name = name
        self.detail = detail
        self.isCurrentDevice = isCurrentDevice
        self.onDelete = onDelete
    }

    public var body: some View {
        HStack(spacing: theme.tokens.spacing.sm) {
            Image(systemName: platform == .iPhone ? "iphone" : "iphone")
                .font(.system(size: 20))
                .foregroundStyle(theme.tokens.colors.gradientIcons)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(theme.tokens.typography.bodyMediumSemibold)
                    .foregroundColor(theme.tokens.colors.textPrimary)
                Text(detail)
                    .font(theme.tokens.typography.bodySmallRegular)
                    .foregroundColor(theme.tokens.colors.textSecondary)
            }

            Spacer()

            if isCurrentDevice {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.tokens.colors.successMain)
            } else if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(theme.tokens.colors.textSecondary)
                }
            }
        }
        .padding(theme.tokens.spacing.md)
        .background(theme.tokens.colors.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: theme.tokens.radius.md))
    }
}
