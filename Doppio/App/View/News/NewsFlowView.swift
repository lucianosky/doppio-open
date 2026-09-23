// NewsFlowView.swift
// App/View/News

import SwiftUI

struct NewsFlowView: View {
    @ObservedObject var viewModel: NewsListViewModel
    @StateObject private var coordinator = NewsCoordinator()
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            NewsListView(viewModel: viewModel)
                .navigationDestination(for: NewsCoordinator.Route.self) { route in
                    switch route {
                    case .newsDetail(let id):
                        NewsDetailContainerView(newsRepository: appState.container.newsRepository, id: id)
                    case .shopDetail(let id):
                        ShopDetailContainerView(shopRepository: appState.container.shopRepository, id: id)
                    case .baristaDetail(let id):
                        BaristaDetailContainerView(baristaRepository: appState.container.baristaRepository, id: id)
                    }
                }
        }
        .environmentObject(coordinator)
    }
}
