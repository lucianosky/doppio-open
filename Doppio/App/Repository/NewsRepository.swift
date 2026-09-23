// NewsRepository.swift
// App/Repository — Ring 3

import Foundation

// MARK: - NewsRepository

final class NewsRepository: CollectionRepository<NewsListItemEntity> {

    private var detailCache: [Int: NewsEntity] = [:]

    override func fetch() async throws {
        guard items.isEmpty else { return }
        let dtos: [NewsListItemDTO] = try await dataSource.fetchList(path: DoppioAPIPath.news)
        items = dtos.map { $0.toDomain() }
    }

    func fetchDetail(id: Int) async throws -> NewsEntity {
        if let cached = detailCache[id] { return cached }
        let dto: NewsDTO = try await dataSource.fetchOne(path: DoppioAPIPath.newsDetail(id: id))
        let entity = dto.toDomain()
        detailCache[id] = entity
        return entity
    }

    override func clearCache() {
        super.clearCache()
        detailCache = [:]
    }
}
