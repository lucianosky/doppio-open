import SwiftUI

// MARK: - BrewOTPInput

/// 5-digit OTP code input used in email verification flows.
///
/// Features:
/// - Auto-advances focus to the next digit on entry
/// - Backspace moves focus to the previous digit
/// - Shows idle / error / success states
/// - Emits the complete code via `onComplete` when all digits are filled
///
/// Usage:
/// ```swift
/// BrewOTPInput(state: otpState, onComplete: { code in
///     viewModel.verifyCode(code)
/// })
/// ```
public struct BrewOTPInput: View {

    // MARK: Properties

    private let digitCount: Int
    private let state: OTPState
    private let onComplete: (String) -> Void

    @State private var digits: [String]
    @FocusState private var focusedIndex: Int?

    @Environment(BrewTheme.self) private var theme

    // MARK: OTPState

    public enum OTPState {
        case idle
        case error    // shows error indicator on filled digit
        case success  // shows checkmark on filled digit
    }

    // MARK: Init

    public init(
        digitCount: Int = 5,
        state: OTPState = .idle,
        onComplete: @escaping (String) -> Void
    ) {
        self.digitCount = digitCount
        self.state = state
        self.onComplete = onComplete
        self._digits = State(initialValue: Array(repeating: "", count: digitCount))
    }

    // MARK: Body

    public var body: some View {
        VStack(spacing: theme.tokens.spacing.sm) {
            HStack(spacing: theme.tokens.spacing.sm) {
                ForEach(0..<digitCount, id: \.self) { index in
                    digitCell(at: index)
                }
            }
            stateIndicator
        }
    }

    // MARK: Digit cell

    private func digitCell(at index: Int) -> some View {
        ZStack {
            cellBackground(at: index)
            TextField("", text: $digits[index])
                .font(theme.tokens.typography.titleH5)
                .foregroundColor(cellTextColor(at: index))
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focusedIndex, equals: index)
                .accessibilityIdentifier("otp_digit_\(index)")
                .onChange(of: digits[index]) { _, newValue in
                    handleInput(newValue, at: index)
                }
        }
        .frame(width: 52, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: theme.tokens.radius.sm))
        .onTapGesture { focusedIndex = index }
    }

    @ViewBuilder
    private func cellBackground(at index: Int) -> some View {
        let isFocused = focusedIndex == index
        let isFilled = !digits[index].isEmpty

        RoundedRectangle(cornerRadius: theme.tokens.radius.sm)
            .fill(theme.tokens.colors.backgroundCard)
            .overlay(
                RoundedRectangle(cornerRadius: theme.tokens.radius.sm)
                    .strokeBorder(cellBorderColor(isFocused: isFocused, isFilled: isFilled),
                                  lineWidth: 1.5)
            )
    }

    @ViewBuilder
    private var stateIndicator: some View {
        switch state {
        case .idle:
            EmptyView()
        case .error:
            HStack(spacing: theme.tokens.spacing.xxs) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                Text(String(localized: "otp.error"))
                    .font(theme.tokens.typography.bodySmallMedium)
            }
            .foregroundColor(theme.tokens.colors.errorMain)
        case .success:
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.tokens.colors.successMain)
        }
    }

    // MARK: Input handling

    private func handleInput(_ value: String, at index: Int) {
        // Allow only a single digit
        let filtered = value.filter(\.isNumber).prefix(1)
        digits[index] = String(filtered)

        if filtered.isEmpty {
            // Backspace — move back
            if index > 0 { focusedIndex = index - 1 }
        } else {
            // Digit entered — move forward
            if index < digitCount - 1 {
                focusedIndex = index + 1
            } else {
                focusedIndex = nil
                fireCompleteIfNeeded()
            }
        }
    }

    private func fireCompleteIfNeeded() {
        let code = digits.joined()
        if code.count == digitCount { onComplete(code) }
    }

    // MARK: Colors

    private func cellBorderColor(isFocused: Bool, isFilled: Bool) -> Color {
        switch state {
        case .error:   return theme.tokens.colors.errorMain
        case .success: return theme.tokens.colors.successMain
        case .idle:
            if isFocused { return theme.tokens.colors.borderFocused }
            if isFilled { return theme.tokens.colors.borderDefault }
            return theme.tokens.colors.borderDefault
        }
    }

    private func cellTextColor(at index: Int) -> Color {
        switch state {
        case .error:   return theme.tokens.colors.errorMain
        case .success: return theme.tokens.colors.successMain
        case .idle:    return theme.tokens.colors.textPrimary
        }
    }
}
