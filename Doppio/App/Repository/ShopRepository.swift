// ShopRepository.swift
// App/Repository — Ring 3

import Foundation

// MARK: - ShopRepository

/// Holds the shop list and caches detail fetches in memory.
final class ShopRepository: CollectionRepository<ShopEntity> {

    // MARK: - Private Cache

    private var detailCache: [Int: ShopEntity] = [:]

    // MARK: - Fetch List

    override func fetch() async throws {
        guard items.isEmpty else { return }
        let dtos: [ShopDTO] = try await dataSource.fetchList(path: DoppioAPIPath.shops)
        items = dtos.map { $0.toDomain() }
    }

    // MARK: - Fetch Detail

    func fetchDetail(id: Int) async throws -> ShopEntity {
        if let cached = detailCache[id] { return cached }
        let dto: ShopDTO = try await dataSource.fetchOne(path: DoppioAPIPath.shopDetail(id: id))
        let entity = dto.toDomain()
        detailCache[id] = entity
        return entity
    }

    // MARK: - Cache

    override func clearCache() {
        super.clearCache()
        detailCache = [:]
    }
}
