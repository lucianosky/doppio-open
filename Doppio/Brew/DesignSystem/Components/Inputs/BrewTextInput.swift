import SwiftUI

// MARK: - BrewInputState

public enum BrewInputState {
    case idle
    case focused
    case filled
    case error(message: String)
    case valid
}

// MARK: - BrewTextInput

/// Generic single-line text input for the Brew design system.
/// Covers: email, name, date, phone, confirm fields.
///
/// Usage:
/// ```swift
/// BrewTextInput(
///     label: "E-mail",
///     text: $email,
///     state: emailState,
///     keyboardType: .emailAddress
/// )
/// ```
public struct BrewTextInput: View {

    // MARK: Properties

    private let label: String
    @Binding private var text: String
    private let state: BrewInputState
    private let keyboardType: UIKeyboardType
    private let autocapitalization: TextInputAutocapitalization
    private let textContentType: UITextContentType?
    private let trailingIcon: String?
    private let onTrailingIconTap: (() -> Void)?
    private let onEditingChanged: ((Bool) -> Void)?

    @FocusState private var isFocused: Bool
    @Environment(BrewTheme.self) private var theme

    // MARK: Init

    public init(
        label: String,
        text: Binding<String>,
        state: BrewInputState = .idle,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .never,
        textContentType: UITextContentType? = nil,
        trailingIcon: String? = nil,
        onTrailingIconTap: (() -> Void)? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self.label = label
        self._text = text
        self.state = state
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.textContentType = textContentType
        self.trailingIcon = trailingIcon
        self.onTrailingIconTap = onTrailingIconTap
        self.onEditingChanged = onEditingChanged
    }

    // MARK: Body

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.tokens.spacing.xxs) {
            labelView
            inputRow
                .frame(minHeight: 32)
            Rectangle()
                .fill(dividerColor)
                .frame(height: 1)
            if case .error(let message) = state {
                errorLabel(message)
            }
        }
    }

    // MARK: Subviews

    private var labelView: some View {
        HStack {
            Text(label)
                .font(theme.tokens.typography.bodyMediumBold)
                .foregroundColor(labelColor)
        }
    }

    private var inputRow: some View {
        HStack(spacing: theme.tokens.spacing.xs) {
            TextField("", text: $text)
                .font(theme.tokens.typography.bodyLargeRegular)
                .foregroundColor(theme.tokens.colors.textPrimary)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .textContentType(textContentType)
                .focused($isFocused)
                .onChange(of: isFocused) { _, newValue in
                    onEditingChanged?(newValue)
                }

            trailingIconView
        }
    }

    @ViewBuilder
    private var trailingIconView: some View {
        if case .valid = state {
            Image(systemName: "checkmark")
                .foregroundColor(theme.tokens.colors.successMain)
                .font(.system(size: 14, weight: .semibold))
        } else if let icon = trailingIcon {
            Button(action: { onTrailingIconTap?() }, label: {
                Image(systemName: icon)
                    .foregroundColor(theme.tokens.colors.textSecondary)
                    .font(.system(size: 16))
            })
        }
    }

    private func errorLabel(_ message: String) -> some View {
        Text(message)
            .font(theme.tokens.typography.bodySmallRegular)
            .foregroundColor(theme.tokens.colors.errorMain)
    }

    // MARK: Computed colors

    private var labelColor: Color {
        switch state {
        case .error: return theme.tokens.colors.textPrimary
        default:     return theme.tokens.colors.textPrimary
        }
    }

    private var dividerColor: Color {
        switch state {
        case .focused:   return theme.tokens.colors.borderFocused
        case .error:     return theme.tokens.colors.errorMain
        case .valid:     return theme.tokens.colors.successMain
        default:         return theme.tokens.colors.borderDefault
        }
    }

    private var errorText: String {
        if case .error(let msg) = state { return msg }
        return ""
    }
}

// MARK: - BrewSecureInput

/// Password / secure text input with show/hide toggle.
///
/// Usage:
/// ```swift
/// BrewSecureInput(label: "Senha", text: $password, state: passwordState)
/// ```
public struct BrewSecureInput: View {

    private let label: String
    @Binding private var text: String
    private let state: BrewInputState
    private let textContentType: UITextContentType?

    @State private var isVisible = false
    @FocusState private var isFocused: Bool
    @Environment(BrewTheme.self) private var theme

    public init(
        label: String,
        text: Binding<String>,
        state: BrewInputState = .idle,
        textContentType: UITextContentType? = nil
    ) {
        self.label = label
        self._text = text
        self.state = state
        self.textContentType = textContentType
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.tokens.spacing.xxs) {
            Text(label)
                .font(theme.tokens.typography.bodyMediumBold)
                .foregroundColor(theme.tokens.colors.textPrimary)

            HStack(spacing: theme.tokens.spacing.xs) {
                Group {
                    if isVisible {
                        TextField("", text: $text)
                            .textContentType(textContentType)
                    } else {
                        SecureField("", text: $text)
                            // When textContentType is provided use it; otherwise fall back to
                            // .oneTimeCode which suppresses the "Save Password?" alert in UITests.
                            .textContentType(textContentType ?? .oneTimeCode)
                    }
                }
                .font(theme.tokens.typography.bodyLargeRegular)
                .foregroundColor(theme.tokens.colors.textPrimary)
                .autocorrectionDisabled()
                .focused($isFocused)

                Button(action: { isVisible.toggle() }, label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .foregroundColor(theme.tokens.colors.textSecondary)
                        .font(.system(size: 16))
                })
            }

            Rectangle()
                .fill(dividerColor)
                .frame(height: 1)

            if case .error(let message) = state {
                Text(message)
                    .font(theme.tokens.typography.bodySmallRegular)
                    .foregroundColor(theme.tokens.colors.errorMain)
            }
        }
    }

    private var dividerColor: Color {
        switch state {
        case .focused: return theme.tokens.colors.borderFocused
        case .error:   return theme.tokens.colors.errorMain
        default:       return theme.tokens.colors.borderDefault
        }
    }
}

// MARK: - BrewSearchInput

/// Search bar input with magnifying glass icon and clear button.
///
/// Usage:
/// ```swift
/// BrewSearchInput(text: $query, placeholder: "O que quer assistir")
/// ```
public struct BrewSearchInput: View {

    @Binding private var text: String
    private let placeholder: String
    @Environment(BrewTheme.self) private var theme

    public init(text: Binding<String>, placeholder: String = "Buscar") {
        self._text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        HStack(spacing: theme.tokens.spacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(theme.tokens.colors.textSecondary)
                .font(.system(size: 16))

            TextField(placeholder, text: $text)
                .font(theme.tokens.typography.bodyLargeRegular)
                .foregroundColor(theme.tokens.colors.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button(action: { text = "" }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(theme.tokens.colors.textSecondary)
                        .font(.system(size: 14, weight: .medium))
                })
            }
        }
        .padding(.horizontal, theme.tokens.spacing.md)
        .padding(.vertical, theme.tokens.spacing.sm)
        .background(theme.tokens.colors.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: theme.tokens.radius.full))
    }
}
