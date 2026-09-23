// CollectionRepository.swift
// Brew/Repository
//
// Generic base class for repositories that hold an in-memory collection
// of domain entities.
//
// The type parameter T is a domain Entity (ring 1) — no Codable required.
// Decoding from JSON is the responsibility of the DataSource (ring 4) via
// generics, and mapping DTO → Entity is the responsibility of the Repository
// subclass (ring 3). The base class has no knowledge of either.
//
// For repositories that cache a single object, use SingleObjectRepository<T>.
// For action-oriented repositories (auth, purchase, playback), use ActionRepository.

import Combine
import Foundation

// MARK: - CollectionRepository

/// Generic base for repositories that hold an in-memory collection of domain entities.
///
/// Provides a `@Published var items: [T]` collection that subclasses
/// populate via `fetch()`. ViewModels read from `items` after calling `fetch()`.
///
/// Subclasses fetch DTOs from the DataSource, map them to Entities,
/// and assign the result to `items`:
///
/// ```swift
/// final class CatalogRepository: CollectionRepository<TitleSummaryEntity> {
///     override func fetch() async throws {
///         guard items.isEmpty else { return }   // memory hit
///         let dtos: [TitleSummaryDTO] = try await dataSource.fetchList(path: .titles)
///         items = dtos.map { $0.toDomain() }
///     }
/// }
/// ```
///
/// Examples in Raipe:
/// - `CatalogRepository` — `TitleSummaryEntity` list
/// - `SearchRepository` — search results and recent searches
/// - `UserRepository` — favorites, devices
/// - `NotificationRepository` — inbox items
open class CollectionRepository<T> {

    // MARK: - Published State

    /// The current collection of entities held in memory.
    @Published public var items: [T] = []

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

    /// Fetches data from the data source, maps DTOs to Entities, and updates `items`.
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
        items = []
    }
}
