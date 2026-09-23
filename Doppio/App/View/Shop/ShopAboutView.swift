// ShopAboutView.swift
// App/View/Shop

import SwiftUI

struct ShopAboutView: View {
    let shop: ShopEntity
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        Text(shop.about ?? "Descrição não disponível")
            .font(.body)
            .foregroundColor(theme.tokens.colors.textPrimary)
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.tokens.colors.backgroundCard)
            .cornerRadius(theme.tokens.radius.radiusCard)
    }
}
