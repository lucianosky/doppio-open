// ShopDTO.swift
// App/Network/DTOs — Ring 3 (Data Transfer Objects)

import Foundation

// MARK: - AddressDTO

struct AddressDTO: Decodable {
    let district: String
    let street: String?
    let number: String?
    let complement: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let latitude: Double?
    let longitude: Double?

    func toDomain() -> AddressEntity {
        AddressEntity(
            district: district,
            street: street ?? "",
            number: number,
            complement: complement,
            city: city,
            state: state,
            zipCode: zipCode,
            latitude: latitude,
            longitude: longitude
        )
    }
}

// MARK: - BranchDTO

struct BranchDTO: Decodable {
    let id: Int
    let label: String?
    let address: AddressDTO
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

    // convertFromSnakeCase handles all snake_case → camelCase automatically.
    // food99/"99food" starts with a number and cannot be auto-mapped — stays nil until backend.

    func toDomain() -> BranchEntity {
        BranchEntity(
            id: id,
            label: label,
            address: address.toDomain(),
            openingHours: openingHours,
            googleMaps: googleMaps,
            plusCode: plusCode,
            phone: phone,
            priceRange: priceRange,
            ifood: ifood,
            menu: menu,
            rappi: rappi,
            uberEats: uberEats,
            food99: food99,
            reservation: reservation
        )
    }
}

// MARK: - ContactDTO

struct ContactDTO: Decodable {
    let whatsapp: String?
    let instagram: String?
    let site: String?
    let spotify: String?
    let linktree: String?

    func toDomain() -> ContactEntity {
        ContactEntity(
            whatsapp: whatsapp,
            instagram: instagram,
            site: site,
            spotify: spotify,
            linktree: linktree
        )
    }
}

// MARK: - CoffeeDTO

struct CoffeeDTO: Decodable {
    let machine: String?
    let methods: [String]
    let beans: [String]

    func toDomain() -> CoffeeEntity {
        CoffeeEntity(machine: machine, methods: methods, beans: beans)
    }
}

// MARK: - BaristaSummaryDTO

struct BaristaSummaryDTO: Decodable {
    let id: Int
    let nickname: String
    let name: String
    let title: String
    let shopName: String?
    let thumbnailAsset: String?

    func toDomain() -> BaristaSummaryEntity {
        BaristaSummaryEntity(
            id: id, nickname: nickname, name: name, title: title,
            thumbnailAsset: thumbnailAsset, shopName: shopName
        )
    }
}

// MARK: - ShopDTO

struct ShopDTO: Decodable {
    let id: Int
    let longName: String
    let shortName: String
    let about: String?
    let logoAsset: String?
    let openingDate: String?
    let contact: ContactDTO?
    let coffee: CoffeeDTO?
    let baristas: [BaristaSummaryDTO]?
    let imageAssets: [String]?
    let tags: [String]?
    let branches: [BranchDTO]

    func toDomain() -> ShopEntity {
        ShopEntity(
            id: id,
            longName: longName,
            shortName: shortName,
            about: about,
            logoAsset: logoAsset,
            openingDate: openingDate,
            contact: contact?.toDomain(),
            coffee: coffee?.toDomain(),
            baristas: baristas?.map { $0.toDomain() } ?? [],
            imageAssets: imageAssets ?? [],
            tags: tags ?? [],
            branches: branches.map { $0.toDomain() }
        )
    }
}
