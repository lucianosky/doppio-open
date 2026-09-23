// ErrorView.swift
// App/View/Shared

import SwiftUI

struct ErrorView: View {
    let errorMessage: String
    let retryAction: (() -> Void)?
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        ZStack {
            theme.tokens.colors.backgroundPrimary.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(theme.tokens.colors.primaryMain)

                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(theme.tokens.colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                if let retryAction {
                    Button(action: retryAction) {
                        Text("Tentar novamente")
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(theme.tokens.colors.primaryMain)
                            .foregroundColor(theme.tokens.colors.textOnDark)
                            .cornerRadius(theme.tokens.radius.radiusChip)
                    }
                    .accessibilityIdentifier("retry_button")
                } else {
                    Text("Verifique sua conexão e reinicie o app.")
                        .font(.subheadline)
                        .foregroundColor(theme.tokens.colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
        }
    }
}
