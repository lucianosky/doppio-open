// BaristaDTO.swift
// App/Network/DTOs — Ring 3 (Data Transfer Objects)

import Foundation

// MARK: - BaristaDTO

struct BaristaDTO: Decodable {
    let id: Int
    let nickname: String
    let name: String
    let title: String
    let about: String?
    let shopName: String?
    let thumbnailAsset: String?
    let imageAsset: String?
    let instagram: String?
    let email: String?

    func toDomain() -> BaristaEntity {
        BaristaEntity(
            id: id,
            nickname: nickname,
            name: name,
            title: title,
            about: about,
            shopName: shopName,
            thumbnailAsset: thumbnailAsset,
            imageAsset: imageAsset,
            instagram: instagram,
            email: email
        )
    }
}
