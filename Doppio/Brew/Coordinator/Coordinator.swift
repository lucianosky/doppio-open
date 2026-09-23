// Coordinator.swift
// Brew/Coordinator

import SwiftUI

// MARK: - Coordinator

/// Defines the navigation pattern for all coordinators in the Brew architecture.
///
/// This protocol serves as documentation and a structural reference.
/// Concrete coordinators in App/Coordinator/ follow this pattern by convention
/// but do not explicitly conform to this protocol — the `associatedtype Route`
/// constraint causes Swift 6 strict concurrency errors when combined with
/// `@MainActor` and `ObservableObject` synthesis.
///
/// Every concrete coordinator must implement:
///   - `@Published var path: NavigationPath`
///   - `enum Route: Hashable` with all destination cases
///   - `func push(_ route: Route)`
///   - `func pop()`
///   - `func popToRoot()`
///
/// Example:
/// ```swift
/// @MainActor
/// final class HomeCoordinator: ObservableObject {
///
///     @Published var path = NavigationPath()
///
///     enum Route: Hashable {
///         case titleDetail(slug: String)
///         case episodePlayer(episodeId: String)
///         case paywall
///     }
///
///     func push(_ route: Route) { path.append(route) }
///     func pop() { guard !path.isEmpty else { return }; path.removeLast() }
///     func popToRoot() { path.removeLast(path.count) }
/// }
/// ```
///
/// Each tab has a FlowView that owns its NavigationStack:
/// ```swift
/// NavigationStack(path: $coordinator.path) {
///     HomeView()
///         .navigationDestination(for: HomeCoordinator.Route.self) { route in
///             switch route {
///             case .titleDetail(let slug): TitleDetailView(slug: slug)
///             case .episodePlayer(let id): EpisodePlayerView(episodeId: id)
///             case .paywall:              PaywallView()
///             }
///         }
/// }
/// ```
public protocol Coordinator: AnyObject {
    associatedtype Route: Hashable
    var path: NavigationPath { get set }
    func push(_ route: Route)
    func pop()
    func popToRoot()
}
