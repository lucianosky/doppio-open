// NewsDTO.swift
// App/Network/DTOs — Ring 3 (Data Transfer Objects)

import Foundation

// MARK: - ShopSummaryDTO

struct ShopSummaryDTO: Decodable {
    let id: Int
    let name: String
    let logoAsset: String?

    func toDomain() -> ShopSummaryEntity {
        ShopSummaryEntity(id: id, name: name, logoAsset: logoAsset)
    }
}

// MARK: - NewsListItemDTO

struct NewsListItemDTO: Decodable {
    let id: Int
    let title: String
    let summaryText: String
    let category: String?
    let imageAsset: String?
    let publishedAt: Date

    func toDomain() -> NewsListItemEntity {
        NewsListItemEntity(
            id: id,
            title: title,
            summaryText: summaryText,
            category: category,
            imageAsset: imageAsset,
            publishedAt: publishedAt
        )
    }
}

// MARK: - NewsDTO

struct NewsDTO: Decodable {
    let id: Int
    let title: String
    let summaryText: String
    let category: String?
    let contentMd: String
    let imageAsset: String?
    let publishedAt: Date
    let barista: BaristaSummaryDTO?
    let coffeeShop: ShopSummaryDTO?

    func toDomain() -> NewsEntity {
        NewsEntity(
            id: id,
            title: title,
            summaryText: summaryText,
            category: category,
            contentMD: contentMd,
            imageAsset: imageAsset,
            publishedAt: publishedAt,
            barista: barista?.toDomain(),
            coffeeShop: coffeeShop?.toDomain()
        )
    }
}
