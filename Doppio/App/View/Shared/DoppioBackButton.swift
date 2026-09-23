// DoppioBackButton.swift
// App/View/Shared

import SwiftUI

/// Aplica o botão back circular do design (32pt, #2E2218, chevron branco).
/// Uso: `.modifier(DoppioBackButton())`
struct DoppioBackButton: ViewModifier {
    @Environment(BrewTheme.self) private var theme
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }, label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(theme.tokens.colors.textPrimary)
                            .frame(width: 32, height: 32)
                            .background(theme.tokens.colors.backgroundSecondary)
                            .clipShape(Circle())
                    })
                    .accessibilityLabel("Voltar")
                }
            }
    }
}

extension View {
    func doppioBackButton() -> some View {
        modifier(DoppioBackButton())
    }
}
