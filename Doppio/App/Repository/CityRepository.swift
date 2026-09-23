// CityRepository.swift
// App/Repository — Ring 3

import Foundation

// MARK: - CityRepository

/// Holds the current city in memory.
/// V1 serves a single city (Porto Alegre) — the `items` array has one element.
final class CityRepository: CollectionRepository<CityEntity> {

    override func fetch() async throws {
        guard items.isEmpty else { return }
        let dtos: [CityDTO] = try await dataSource.fetchList(path: DoppioAPIPath.cities)
        items = dtos.map { $0.toDomain() }
    }
}
