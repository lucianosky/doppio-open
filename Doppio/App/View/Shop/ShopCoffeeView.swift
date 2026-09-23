// ShopCoffeeView.swift
// App/View/Shop

import SwiftUI

struct ShopCoffeeView: View {
    let shop: ShopEntity
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let openingDate = shop.openingDate,
               let formatted = ShopCoffeeView.formatOpeningDate(openingDate) {
                ShopInfoRow(title: "Funcionando desde:", value: formatted)
            }

            if let machine = shop.coffee?.machine, !machine.isEmpty {
                ShopInfoRow(title: "Máquina de café:", value: machine)
            }

            if let methods = shop.coffee?.methods, !methods.isEmpty {
                ShopInfoRow(title: "Métodos:", value: methods.joined(separator: ", "))
            }

            if let beans = shop.coffee?.beans, !beans.isEmpty {
                ShopInfoRow(title: "Tipos de grãos:", value: beans.joined(separator: ", "))
            }
        }
        .padding()
        .background(theme.tokens.colors.backgroundCard)
        .cornerRadius(theme.tokens.radius.radiusCard)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Informações sobre café")
    }
}

// MARK: - Helpers

extension ShopCoffeeView {
    /// "2020-01-23" → "janeiro de 2020 · há 5 anos"
    static func formatOpeningDate(_ iso: String) -> String? {
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"
        isoFormatter.locale = Locale(identifier: "pt_BR")
        guard let date = isoFormatter.date(from: iso) else { return nil }

        let monthYear = DateFormatter()
        monthYear.dateFormat = "MMMM 'de' yyyy"
        monthYear.locale = Locale(identifier: "pt_BR")
        let absolute = monthYear.string(from: date)

        let calendar = Calendar.current
        let years = calendar.dateComponents([.year], from: date, to: Date()).year ?? 0
        let months = calendar.dateComponents([.month], from: date, to: Date()).month ?? 0

        let relative: String
        if years >= 1 {
            relative = "há \(years) \(years == 1 ? "ano" : "anos")"
        } else if months >= 1 {
            relative = "há \(months) \(months == 1 ? "mês" : "meses")"
        } else {
            relative = "recém aberto"
        }

        return "\(absolute) · \(relative)"
    }
}

private struct ShopInfoRow: View {
    let title: String
    let value: String
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        HStack {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(theme.tokens.colors.textSecondary)
            Spacer()
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundColor(theme.tokens.colors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
}
