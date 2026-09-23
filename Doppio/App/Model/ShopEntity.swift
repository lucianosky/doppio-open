// ShopEntity.swift
// App/Model — Ring 1 (Domain Entities)

import Foundation

// MARK: - AddressEntity

struct AddressEntity: Hashable {
    let district: String
    let street: String
    let number: String?
    let complement: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let latitude: Double?
    let longitude: Double?
}

// MARK: - BranchEntity

struct BranchEntity: Identifiable, Hashable {
    let id: Int
    let label: String?        // "Moinhos", "Petrópolis" — nil for single-branch shops
    let address: AddressEntity
    let openingHours: String?
    let googleMaps: String?
    let plusCode: String?
    let phone: String?
    let priceRange: String?
    let ifood: String?
    let menu: String?
    let rappi: String?
    let uberEats: String?
    let food99: String?
    let reservation: String?
}

// MARK: - ContactEntity

struct ContactEntity: Hashable {
    let whatsapp: String?
    let instagram: String?
    let site: String?
    let spotify: String?
    let linktree: String?
}

// MARK: - CoffeeEntity

struct CoffeeEntity: Hashable {
    let machine: String?
    let methods: [String]
    let beans: [String]
}

// MARK: - BaristaSummaryEntity

struct BaristaSummaryEntity: Identifiable, Hashable {
    let id: Int
    let nickname: String
    let name: String
    let title: String
    let thumbnailAsset: String?
    let shopName: String?
}

// MARK: - ShopEntity

struct ShopEntity: Identifiable, Hashable {
    let id: Int
    let longName: String
    let shortName: String
    let about: String?
    let logoAsset: String?
    let openingDate: String?
    let contact: ContactEntity?
    let coffee: CoffeeEntity?
    let baristas: [BaristaSummaryEntity]
    let imageAssets: [String]
    let tags: [String]
    let branches: [BranchEntity]

    var primaryBranch: BranchEntity? { branches.first }
}
