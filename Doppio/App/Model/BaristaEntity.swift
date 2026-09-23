// BaristaEntity.swift
// App/Model — Ring 1 (Domain Entities)

import Foundation

// MARK: - BaristaEntity

struct BaristaEntity: Identifiable, Hashable {
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
}
