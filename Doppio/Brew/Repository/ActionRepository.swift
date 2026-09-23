// ActionRepository.swift
// Brew/Repository
//
// Base class for action-oriented repositories that do not hold in-memory state.
//
// Use this for repositories whose primary role is to trigger actions and return
// results — auth, purchase, playback, progress. These repositories don't cache
// collections; each call returns a fresh result to the caller.
//
// Contrast with BaseRepository<T>, which is for repositories that hold and
// publish a collection (catalog, search results, wallet, etc.).

import Foundation

// MARK: - ActionRepository

/// Base class for repositories that perform actions rather than hold state.
///
/// Provides the shared `dataSource` dependency and a consistent error
/// mapping pattern. Subclasses add domain-specific methods.
///
/// Examples of ActionRepository subclasses in Raipe:
/// - `AuthRepository` — login, register, logout, me, bootstrap
/// - `PurchaseRepository` — confirm purchase, redeem coupon, restore
/// - `PlaybackRepository` — episode access, unlock, player payload, progress
///
/// Usage:
/// ```swift
/// final class AuthRepository: ActionRepository {
///
///     func login(email: String, password: String) async throws -> AuthResponse {
///         try await dataSource.postUnwrapped(
///             path: APIPath.login,
///             body: LoginRequest(email: email, password: password)
///         )
///     }
///
///     func logout() async throws {
///         let _: LogoutResponse = try await dataSource.post(
///             path: APIPath.logout,
///             body: nil
///         )
///     }
/// }
/// ```
open class ActionRepository {

    // MARK: - Properties

    /// The data source used to perform requests. Injected via `AppContainer`.
    public let dataSource: any DataSource

    // MARK: - Init

    /// Creates an action repository with the given data source.
    ///
    /// - Parameter dataSource: The data source to delegate requests to.
    public init(dataSource: any DataSource) {
        self.dataSource = dataSource
    }
}
