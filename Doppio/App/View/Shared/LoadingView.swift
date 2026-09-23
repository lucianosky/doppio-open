// LoadingView.swift
// App/View/Shared

import SwiftUI

struct LoadingView: View {
    var message: String?
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        ZStack {
            theme.tokens.colors.backgroundPrimary.ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .tint(theme.tokens.colors.primaryMain)

                if let message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(theme.tokens.colors.textSecondary)
                }
            }
        }
        .accessibilityLabel(message ?? "Carregando")
    }
}
