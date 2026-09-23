// NewsDetailView.swift
// App/View/News

import MarkdownUI
import SwiftUI

struct NewsDetailView: View {
    @EnvironmentObject private var coordinator: NewsCoordinator
    @ObservedObject var viewModel: NewsDetailViewModel
    @Environment(BrewTheme.self) private var theme
    let id: Int

    var body: some View {
        Group {
            switch viewModel.viewLoadState {
            case .preload, .loading:
                LoadingView(message: "Carregando detalhes…")

            case .error(let message, let canRetry):
                ErrorView(
                    errorMessage: message,
                    retryAction: canRetry ? { Task { await viewModel.loadData(id: id) } } : nil
                )

            case .content:
                if let news = viewModel.newsItem {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(news.title)
                                    .font(.title)
                                    .foregroundColor(theme.tokens.colors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .accessibilityIdentifier("news_detail_title")

                                Text("Publicado em: \(news.publishedAt.doppioDate)")
                                    .font(.caption)
                                    .foregroundColor(theme.tokens.colors.textSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(theme.tokens.colors.backgroundCard)
                            .cornerRadius(theme.tokens.radius.radiusCard)

                            if let barista = news.barista {
                                Button { coordinator.push(.baristaDetail(id: barista.id)) } label: {
                                    BaristaSummaryView(barista: barista)
                                }
                                .buttonStyle(.plain)
                            }

                            if let shop = news.coffeeShop {
                                Button { coordinator.push(.shopDetail(id: shop.id)) } label: {
                                    ShopSummaryView(shop: shop)
                                }
                                .buttonStyle(.plain)
                            }

                            Text(news.summaryText)
                                .font(.headline)
                                .foregroundColor(theme.tokens.colors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(theme.tokens.colors.backgroundCard)
                                .cornerRadius(theme.tokens.radius.radiusCard)

                            // V1: image placeholder
                            theme.tokens.colors.backgroundSecondary
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .cornerRadius(theme.tokens.radius.radiusCard)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 36))
                                        .foregroundColor(theme.tokens.colors.textSecondary.opacity(0.4))
                                )

                            Markdown(news.contentMD)
                                .markdownTextStyle(\.text) {
                                    FontSize(16)
                                    ForegroundColor(theme.tokens.colors.textPrimary)
                                }
                                .multilineTextAlignment(.leading)
                                .padding()
                                .background(theme.tokens.colors.backgroundCard)
                                .cornerRadius(theme.tokens.radius.radiusCard)
                        }
                        .padding()
                    }
                    .background(theme.tokens.colors.backgroundPrimary)
                    .scrollContentBackground(.hidden)
                } else {
                    ErrorView(
                        errorMessage: "Dados não encontrados",
                        retryAction: { Task { await viewModel.loadData(id: id) } }
                    )
                }
            }
        }
        .navigationBarTitle("Notícia", displayMode: .inline)
        .doppioBackButton()
        .task {
            if viewModel.viewLoadState == .preload {
                await viewModel.loadData(id: id)
            }
        }
    }
}
