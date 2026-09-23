// SingleObjectRepository.swift
// Brew/Repository
//
// Generic base class for repositories that cache a single domain entity.
//
// The type parameter T is a domain Entity (ring 1) — no Codable required.
// Decoding from JSON is the responsibility of the DataSource (ring 4) via
// generics, and mapping DTO → Entity is the responsibility of the Repository
// subclass (ring 3). The base class has no knowledge of either.
//
// For repositories that hold a collection of entities, use CollectionRepository<T>.
// For action-oriented repositories (auth, purchase, playback), use ActionRepository.

import Combine
import Foundation

// MARK: - SingleObjectRepository

/// Generic base for repositories that cache a single domain entity.
///
/// Provides a `@Published var object: T?` that subclasses populate
/// via `fetch()`. ViewModels read from `object` after calling `fetch()`.
///
/// Subclasses fetch a DTO from the DataSource, map it to an Entity,
/// and assign the result to `object`:
///
/// ```swift
/// final class HomeRepository: SingleObjectRepository<HomeEntity> {
///     override func fetch() async throws {
///         guard object == nil else { return }   // memory hit
///         let dto: HomeResponseDTO = try await dataSource.fetchOne(path: .home)
///         object = dto.toDomain()
///     }
/// }
/// ```
///
/// Examples in Raipe:
/// - `HomeRepository` — `HomeEntity` from `GET /home`
/// - `BootstrapRepository` — feature flags and session config _(future)_
/// - `PaywallRepository` — subscription plans and credit packs _(future)_
open class SingleObjectRepository<T> {

    // MARK: - Published State

    /// The cached entity, or `nil` before the first successful fetch.
    @Published public var object: T?

    // MARK: - Properties

    /// The data source used to fetch data. Injected via `AppContainer`.
    public let dataSource: any DataSource

    // MARK: - Init

    /// Creates a repository with the given data source.
    ///
    /// - Parameter dataSource: The data source to delegate fetches to.
    public init(dataSource: any DataSource) {
        self.dataSource = dataSource
    }

    // MARK: - Public Methods

    /// Fetches the entity from the data source and updates `object`.
    ///
    /// The default implementation is a no-op. Subclasses must override
    /// with their fetch and mapping logic.
    ///
    /// - Throws: `RepositoryError` on network, decoding, or mapping failure.
    open func fetch() async throws {
        // Subclasses must override.
    }

    /// Clears the in-memory cache.
    ///
    /// Call this on logout or when a full refresh is required.
    public func clearCache() {
        object = nil
    }
}
