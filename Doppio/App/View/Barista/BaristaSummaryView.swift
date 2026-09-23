// BaristaSummaryView.swift
// App/View/Barista

import SwiftUI

struct BaristaSummaryView: View {
    let barista: BaristaSummaryEntity
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        HStack(spacing: 12) {
            // V1: thumbnail placeholder
            theme.tokens.colors.backgroundSecondary
                .frame(width: 44, height: 44)
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 2) {
                Text(barista.name)
                    .font(.headline)
                    .foregroundColor(theme.tokens.colors.textPrimary)
                Text(barista.title)
                    .font(.caption)
                    .foregroundColor(theme.tokens.colors.textSecondary)
            }

            Spacer()
        }
        .padding()
        .background(theme.tokens.colors.backgroundCard)
        .cornerRadius(15)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(barista.name). \(barista.title)")
        .accessibilityHint("Barista relacionado à notícia.")
    }
}
