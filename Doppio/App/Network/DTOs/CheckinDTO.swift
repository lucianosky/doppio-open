// CheckinDTO.swift
// App/Network/DTOs — Ring 3 (Data Transfer Objects)

import Foundation

// MARK: - CheckinRequest

/// Encodable body for POST /rest/v1/checkins.
///
/// Field mapping (camelCase → snake_case via encoder):
///   shopId        → shop_id
///   branchId      → branch_id
///   isFirstVisit  → is_first_visit
///   companion     → companion  (raw value: "solo" | "duo" | "group")
///   billAmount    → bill_amount
///   comment       → comment    (check-in note OR rating comment)
///   rating        → rating     (1–5, nil when submitting a plain check-in)
///   checkinId     → checkin_id (links a rating record to its originating check-in)
struct CheckinRequest: Encodable {
    let shopId: Int
    let branchId: Int?
    let isFirstVisit: Bool?
    let companion: String?
    let billAmount: Decimal?
    let comment: String?
    let rating: Int?
    let checkinId: Int?
}

// MARK: - CheckinResponseDTO

/// Decoded from Supabase when Prefer: return=representation is set.
/// Only `id` is needed — remaining fields are ignored.
struct CheckinResponseDTO: Decodable {
    let id: Int
}
