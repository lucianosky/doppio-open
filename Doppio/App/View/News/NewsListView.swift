// NewsListView.swift
// App/View/News

import SwiftUI

struct NewsListView: View {
    @ObservedObject var viewModel: NewsListViewModel
    @EnvironmentObject private var coordinator: NewsCoordinator
    @Environment(BrewTheme.self) private var theme
    @State private var isRefreshing = false

    var body: some View {
        ZStack {
            switch viewModel.viewLoadState {
            case .preload, .loading:
                if !isRefreshing {
                    LoadingView(message: "Carregando notícias…")
                }

            case .error(let message, let canRetry):
                ErrorView(
                    errorMessage: message,
                    retryAction: canRetry ? { Task { await viewModel.loadData() } } : nil
                )

            case .content:
                if viewModel.news.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "newspaper")
                            .font(.system(size: 40))
                            .foregroundColor(theme.tokens.colors.textSecondary)
                        Text("Nenhuma novidade por enquanto")
                            .font(.subheadline)
                            .foregroundColor(theme.tokens.colors.textSecondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    List(viewModel.news) { item in
                        Button {
                            coordinator.push(.newsDetail(id: item.id))
                        } label: {
                            NewsCell(news: item)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(theme.tokens.colors.backgroundPrimary)
                        .listRowInsets(EdgeInsets(top: 2, leading: 5, bottom: 5, trailing: 10))
                        .listRowSeparator(.hidden)
                        .accessibilityIdentifier("news_cell_\(item.id)")
                    }
                    .listStyle(.plain)
                    .background(theme.tokens.colors.backgroundPrimary)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        isRefreshing = true
                        await viewModel.loadData()
                        isRefreshing = false
                    }
                }
            }
        }
        .navigationTitle("Notícias")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Notícias").font(.headline)
                    .accessibilityIdentifier("news_nav_title")
            }
        }
        .task {
            if viewModel.viewLoadState == .preload {
                await viewModel.loadData()
            }
        }
    }
}
