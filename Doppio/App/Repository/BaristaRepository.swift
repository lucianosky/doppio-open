// BaristaRepository.swift
// App/Repository — Ring 3

import Foundation

// MARK: - BaristaRepository

final class BaristaRepository: CollectionRepository<BaristaSummaryEntity> {

    private var detailCache: [Int: BaristaEntity] = [:]

    override func fetch() async throws {
        guard items.isEmpty else { return }
        let dtos: [BaristaSummaryDTO] = try await dataSource.fetchList(path: DoppioAPIPath.baristas)
        items = dtos.map { $0.toDomain() }
    }

    func fetchDetail(id: Int) async throws -> BaristaEntity {
        if let cached = detailCache[id] { return cached }
        let dto: BaristaDTO = try await dataSource.fetchOne(path: DoppioAPIPath.baristaDetail(id: id))
        let entity = dto.toDomain()
        detailCache[id] = entity
        return entity
    }

    override func clearCache() {
        super.clearCache()
        detailCache = [:]
    }
}
