// BaristaListView.swift
// App/View/Barista

import SwiftUI

struct BaristaListView: View {
    @ObservedObject var viewModel: BaristaListViewModel
    @EnvironmentObject private var coordinator: BaristaCoordinator
    @Environment(BrewTheme.self) private var theme
    @State private var isRefreshing = false

    var body: some View {
        ZStack {
            switch viewModel.viewLoadState {
            case .preload, .loading:
                if !isRefreshing {
                    LoadingView(message: "Carregando baristas…")
                }

            case .error(let message, let canRetry):
                ErrorView(
                    errorMessage: message,
                    retryAction: canRetry ? { Task { await viewModel.loadData() } } : nil
                )

            case .content:
                if viewModel.baristas.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "person.2")
                            .font(.system(size: 40))
                            .foregroundColor(theme.tokens.colors.textSecondary)
                        Text("Nenhum barista cadastrado")
                            .font(.subheadline)
                            .foregroundColor(theme.tokens.colors.textSecondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    List(viewModel.baristas) { item in
                        Button {
                            coordinator.push(.baristaDetail(id: item.id))
                        } label: {
                            BaristaCell(barista: item)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(theme.tokens.colors.backgroundPrimary)
                        .listRowInsets(EdgeInsets(top: 2, leading: 5, bottom: 5, trailing: 10))
                        .listRowSeparator(.hidden)
                        .accessibilityIdentifier("barista_cell_\(item.id)")
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
        .navigationTitle("Baristas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Baristas").font(.headline)
                    .accessibilityIdentifier("barista_nav_title")
            }
        }
        .task {
            if viewModel.viewLoadState == .preload {
                await viewModel.loadData()
            }
        }
    }
}
