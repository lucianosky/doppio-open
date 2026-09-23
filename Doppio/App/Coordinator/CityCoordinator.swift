// CityCoordinator.swift
// App/Coordinator

import SwiftUI
import Combine

// MARK: - CityCoordinator

@MainActor
final class CityCoordinator: ObservableObject {

    @Published var path = NavigationPath()

    enum Route: Hashable {
        case shopDetail(id: Int)
        case baristaDetail(id: Int)
        case checkin(shopId: Int, branchId: Int?, shopName: String, district: String)
        case rating(shopId: Int, branchId: Int?, shopName: String, checkinId: Int?)
    }

    func push(_ route: Route) { path.append(route) }
    func pop(count: Int = 1) { path.removeLast(min(count, path.count)) }
    func popToRoot() { path.removeLast(path.count) }
}
