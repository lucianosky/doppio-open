// CityDTO.swift
// App/Network/DTOs — Ring 3 (Data Transfer Object)

import Foundation

// MARK: - CityDTO

struct CityDTO: Decodable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let latDelta: Double
    let longDelta: Double

    func toDomain() -> CityEntity {
        CityEntity(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            latDelta: latDelta,
            longDelta: longDelta
        )
    }
}
