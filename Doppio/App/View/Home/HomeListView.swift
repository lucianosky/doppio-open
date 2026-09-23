// HomeListView.swift
// App/View/Home

import SwiftUI

struct HomeListView: View {
    @ObservedObject var viewModel: NewsListViewModel
    @EnvironmentObject private var coordinator: NewsCoordinator
    @Environment(BrewTheme.self) private var theme
    @State private var showProfile = false

    var body: some View {
        ZStack {
            switch viewModel.viewLoadState {
            case .preload, .loading:
                LoadingView(message: "Carregando…")

            case .error(let message, let canRetry):
                ErrorView(
                    errorMessage: message,
                    retryAction: canRetry ? { Task { await viewModel.loadData() } } : nil
                )

            case .content:
                if viewModel.news.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "house")
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
                    }
                    .listStyle(.plain)
                    .background(theme.tokens.colors.backgroundPrimary)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        Task { await viewModel.loadData() }
                    }
                }
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Home").font(.headline)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showProfile = true }, label: {
                    Image(systemName: "person.circle")
                        .font(.system(size: 20))
                        .foregroundColor(theme.tokens.colors.textPrimary)
                })
                .accessibilityLabel("Perfil")
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileSheetView()
        }
        .task {
            if viewModel.viewLoadState == .preload {
                await viewModel.loadData()
            }
        }
    }
}
