// NewsEntity.swift
// App/Model — Ring 1 (Domain Entities)

import Foundation

// MARK: - ShopSummaryEntity

struct ShopSummaryEntity: Identifiable, Hashable {
    let id: Int
    let name: String
    let logoAsset: String?
}

// MARK: - NewsListItemEntity

struct NewsListItemEntity: Identifiable, Hashable {
    let id: Int
    let title: String
    let summaryText: String
    let category: String?
    let imageAsset: String?
    let publishedAt: Date
}

// MARK: - NewsEntity

struct NewsEntity: Identifiable, Hashable {
    let id: Int
    let title: String
    let summaryText: String
    let category: String?
    let contentMD: String
    let imageAsset: String?
    let publishedAt: Date
    let barista: BaristaSummaryEntity?
    let coffeeShop: ShopSummaryEntity?
}
