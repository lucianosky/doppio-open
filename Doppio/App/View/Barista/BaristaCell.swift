// BaristaCell.swift
// App/View/Barista

import SwiftUI

struct BaristaCell: View {
    let barista: BaristaSummaryEntity
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        HStack(spacing: 12) {
            // Circular avatar — 64pt
            Group {
                if let asset = barista.thumbnailAsset {
                    DoppioAsyncImage(url: asset)
                } else {
                    theme.tokens.colors.backgroundSecondary
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundColor(theme.tokens.colors.textSecondary)
                        )
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(barista.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(theme.tokens.colors.textPrimary)

                Text(barista.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.tokens.colors.primaryMain)
                    .lineLimit(2)

                if let shopName = barista.shopName {
                    Text(shopName)
                        .font(.system(size: 11))
                        .foregroundColor(theme.tokens.colors.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(theme.tokens.colors.textSecondary)
        }
        .padding(12)
        .background(theme.tokens.colors.backgroundCard)
        .cornerRadius(14)
        .padding(.horizontal, 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(barista.name). \(barista.title)")
        .accessibilityHint("Toque para ver os detalhes do barista.")
        .accessibilityAddTraits(.isButton)
    }
}
