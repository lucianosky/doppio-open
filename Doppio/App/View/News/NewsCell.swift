// NewsCell.swift
// App/View/News

import SwiftUI

struct NewsCell: View {
    let news: NewsListItemEntity
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Image area — 100pt placeholder; swap for AsyncImage when imageURL is available
            Group {
                if let asset = news.imageAsset {
                    DoppioAsyncImage(url: asset)
                } else {
                    theme.tokens.colors.backgroundSecondary
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 22))
                                .foregroundColor(theme.tokens.colors.textSecondary)
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .clipped()

            VStack(alignment: .leading, spacing: 6) {
                if let category = news.category {
                    Text(category.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(category.lowercased() == "evento" ? Color.green : Color.orange)
                        .cornerRadius(6)
                }

                Text(news.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.tokens.colors.textPrimary)

                Text(news.summaryText)
                    .font(.system(size: 12))
                    .foregroundColor(theme.tokens.colors.textSecondary)
                    .lineLimit(2)
                    .truncationMode(.tail)

                Text(news.publishedAt.doppioDate)
                    .font(.system(size: 11))
                    .foregroundColor(theme.tokens.colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(12)
        }
        .background(theme.tokens.colors.backgroundCard)
        .cornerRadius(14)
        .padding(.horizontal, 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(news.title). Publicado em \(news.publishedAt.doppioDate)")
        .accessibilityHint("Toque para ver os detalhes da notícia.")
        .accessibilityAddTraits(.isButton)
    }
}
