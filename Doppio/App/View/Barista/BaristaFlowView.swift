// BaristaFlowView.swift
// App/View/Barista

import SwiftUI

struct BaristaFlowView: View {
    @ObservedObject var viewModel: BaristaListViewModel
    @StateObject private var coordinator = BaristaCoordinator()
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            BaristaListView(viewModel: viewModel)
                .navigationDestination(for: BaristaCoordinator.Route.self) { route in
                    switch route {
                    case .baristaDetail(let id):
                        BaristaDetailContainerView(
                            baristaRepository: appState.container.baristaRepository,
                            id: id
                        )
                    }
                }
        }
        .environmentObject(coordinator)
    }
}
