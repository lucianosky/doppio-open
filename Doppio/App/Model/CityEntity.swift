// CityEntity.swift
// App/Model — Ring 1 (Domain Entity)

import Foundation

// MARK: - CityEntity

/// Represents a city with its map viewport.
struct CityEntity: Identifiable, Hashable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let latDelta: Double
    let longDelta: Double
}
