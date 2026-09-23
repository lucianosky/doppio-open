// CheckinRepository.swift
// App/Repository — Ring 3
//
// Writes check-in and rating records to the Supabase `checkins` table.
// Requires a valid user JWT (from SessionStore) — RLS uses auth.uid() to
// set user_id automatically, so it does NOT need to be sent in the body.

import Foundation

// MARK: - CheckinRepository

final class CheckinRepository {

    private let sessionStore: SessionStore
    private let restURL     = SupabaseConfig.restURL
    private let anonKey     = SupabaseConfig.anonKey

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }

    // MARK: - Check-in

    /// Submits a check-in record and returns the created record id.
    /// The id is used to link a subsequent rating to this visit.
    func submitCheckin(
        shopId: Int,
        branchId: Int?,
        isFirstVisit: Bool?,
        companion: String,
        billAmount: Decimal?,
        comment: String?
    ) async throws -> Int {
        let body = CheckinRequest(
            shopId: shopId,
            branchId: branchId,
            isFirstVisit: isFirstVisit,
            companion: companion,
            billAmount: billAmount.flatMap { $0 == 0 ? nil : $0 },
            comment: comment.flatMap { $0.isEmpty ? nil : $0 },
            rating: nil,
            checkinId: nil
        )
        return try await postReturningId(body: body, retryOnExpiry: true)
    }

    // MARK: - Rating

    /// Submits a rating record (rating 1–5 + optional comment).
    /// Pass checkinId to link this rating to a prior check-in of the same visit.
    func submitRating(
        shopId: Int,
        branchId: Int?,
        rating: Int,
        comment: String?,
        checkinId: Int? = nil
    ) async throws {
        let body = CheckinRequest(
            shopId: shopId,
            branchId: branchId,
            isFirstVisit: nil,
            companion: nil,
            billAmount: nil,
            comment: comment.flatMap { $0.isEmpty ? nil : $0 },
            rating: rating,
            checkinId: checkinId
        )
        try await postVoid(body: body, retryOnExpiry: true)
    }

    // MARK: - Private

    /// Posts and returns the created record id (uses return=representation).
    private func postReturningId(body: CheckinRequest, retryOnExpiry: Bool) async throws -> Int {
        guard let token = sessionStore.accessToken else {
            throw CheckinError.notAuthenticated
        }
        guard let url = URL(string: "\(restURL)/checkins") else {
            throw CheckinError.unknown
        }

        var req = buildRequest(url: url, token: token, prefer: "return=representation")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        req.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw CheckinError.unknown }

        if http.statusCode == 401 && retryOnExpiry {
            let refreshed = await sessionStore.refreshSession()
            if refreshed { return try await postReturningId(body: body, retryOnExpiry: false) }
            throw CheckinError.notAuthenticated
        }
        if http.statusCode >= 400 { throw CheckinError.serverError(parseError(data)) }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let records = try? decoder.decode([CheckinResponseDTO].self, from: data),
              let first = records.first else {
            throw CheckinError.unknown
        }
        return first.id
    }

    /// Posts without returning data (uses return=minimal).
    private func postVoid(body: CheckinRequest, retryOnExpiry: Bool) async throws {
        guard let token = sessionStore.accessToken else {
            throw CheckinError.notAuthenticated
        }
        guard let url = URL(string: "\(restURL)/checkins") else {
            throw CheckinError.unknown
        }

        var req = buildRequest(url: url, token: token, prefer: "return=minimal")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        req.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode >= 400 else { return }

        if retryOnExpiry && http.statusCode == 401 {
            let refreshed = await sessionStore.refreshSession()
            if refreshed { try await postVoid(body: body, retryOnExpiry: false); return }
            throw CheckinError.notAuthenticated
        }
        throw CheckinError.serverError(parseError(data))
    }

    private func buildRequest(url: URL, token: String, prefer: String) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue(prefer, forHTTPHeaderField: "Prefer")
        return req
    }

    private func parseError(_ data: Data) -> String {
        struct SupabaseError: Decodable { let code: String?; let message: String? }
        if let err = try? JSONDecoder().decode(SupabaseError.self, from: data) {
            switch err.code {
            case "42501": return "Sem permissão para registrar. Tente fazer login novamente."
            default:      return err.message ?? "Erro desconhecido."
            }
        }
        return "Erro desconhecido."
    }
}

// MARK: - CheckinError

enum CheckinError: LocalizedError {
    case notAuthenticated
    case serverError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:      return "Faça login para continuar."
        case .serverError(let msg):  return "Erro ao enviar: \(msg)"
        case .unknown:               return "Ocorreu um erro inesperado."
        }
    }
}
