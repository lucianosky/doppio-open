// ShopSummaryView.swift
// App/View/Shop

import SwiftUI

struct ShopSummaryView: View {
    let shop: ShopSummaryEntity
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        HStack(spacing: 12) {
            // V1: logo placeholder
            theme.tokens.colors.textSecondary.opacity(0.3)
                .frame(width: 44, height: 44)
                .cornerRadius(6)

            Text(shop.name)
                .font(.headline)
                .foregroundColor(theme.tokens.colors.textPrimary)

            Spacer()
        }
        .padding()
        .background(theme.tokens.colors.backgroundCard)
        .cornerRadius(15)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(shop.name)
        .accessibilityHint("Cafeteria relacionada à notícia.")
    }
}
