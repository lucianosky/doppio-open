// BaristaCoordinator.swift
// App/Coordinator

import SwiftUI
import Combine

// MARK: - BaristaCoordinator

@MainActor
final class BaristaCoordinator: ObservableObject {

    @Published var path = NavigationPath()

    enum Route: Hashable {
        case baristaDetail(id: Int)
    }

    func push(_ route: Route) { path.append(route) }
    func pop() { guard !path.isEmpty else { return }; path.removeLast() }
    func popToRoot() { path.removeLast(path.count) }
}
