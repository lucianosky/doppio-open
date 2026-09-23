// NewsCoordinator.swift
// App/Coordinator

import SwiftUI
import Combine

// MARK: - NewsCoordinator

@MainActor
final class NewsCoordinator: ObservableObject {

    @Published var path = NavigationPath()

    enum Route: Hashable {
        case newsDetail(id: Int)
        case shopDetail(id: Int)
        case baristaDetail(id: Int)
    }

    func push(_ route: Route) { path.append(route) }
    func pop() { guard !path.isEmpty else { return }; path.removeLast() }
    func popToRoot() { path.removeLast(path.count) }
}
