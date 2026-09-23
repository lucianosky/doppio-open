// CheckinEntity.swift
// App/Model — Ring 1 (Domain Entities)

import Foundation

// MARK: - CheckinGroupSize

enum CheckinGroupSize: String, CaseIterable {
    case solo
    case duo
    case group

    var label: String {
        switch self {
        case .solo:  return "Sozinho"
        case .duo:   return "Dupla"
        case .group: return "Grupo (3+)"
        }
    }

    var icon: String {
        switch self {
        case .solo:  return "person"
        case .duo:   return "person.2"
        case .group: return "person.3"
        }
    }
}

// MARK: - CheckinEntity

struct CheckinEntity: Identifiable {
    let id: UUID
    let shopId: Int
    let branchId: Int
    let note: String?
    let isFirstVisit: Bool
    let groupSize: CheckinGroupSize
    let billAmount: Decimal?
    let createdAt: Date
}
