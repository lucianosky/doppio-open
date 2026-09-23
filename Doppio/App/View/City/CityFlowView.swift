// CityFlowView.swift
// App/View/City

import SwiftUI

struct CityFlowView: View {
    @ObservedObject var viewModel: CityViewModel
    @StateObject private var coordinator = CityCoordinator()
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            CityView(viewModel: viewModel)
                .navigationDestination(for: CityCoordinator.Route.self) { route in
                    switch route {
                    case .shopDetail(let id):
                        ShopDetailContainerView(
                            shopRepository: appState.container.shopRepository,
                            id: id
                        )
                    case .baristaDetail(let id):
                        BaristaDetailContainerView(
                            baristaRepository: appState.container.baristaRepository,
                            id: id
                        )
                    case .checkin(let shopId, let branchId, let shopName, let district):
                        CheckinView(vm: CheckinViewModel(
                            repository: appState.container.checkinRepository,
                            shopId: shopId,
                            branchId: branchId,
                            shopName: shopName,
                            district: district
                        ))
                    case .rating(let shopId, let branchId, let shopName, let checkinId):
                        RatingView(vm: RatingViewModel(
                            repository: appState.container.checkinRepository,
                            shopId: shopId,
                            branchId: branchId,
                            shopName: shopName,
                            checkinId: checkinId
                        ))
                    }
                }
        }
        .environmentObject(coordinator)
    }
}
