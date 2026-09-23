// SupabaseDataSource.swift
// App/Network
//
// DataSource implementation backed by Supabase PostgREST.
//
// Design notes:
// • PostgREST returns arrays directly — no { "data": ... } envelope.
// • fetchOne unwraps the first element of a single-item array (?id=eq.N).
// • For V1, only read operations are implemented (public anon key, no auth).
// • Write operations throw .unauthorized — to be implemented when auth lands.
//
// URL mapping (DoppioAPIPath.path → Supabase view):
//   /shops       → v_shop
//   /shops/N     → v_shop?id=eq.N
//   /baristas    → v_barista
//   /baristas/N  → v_barista?id=eq.N
//   /news        → v_news
//   /news/N      → v_news?id=eq.N
//   /cities      → cities

import Foundation

// MARK: - SupabaseDataSource

final class SupabaseDataSource: DataSource, @unchecked Sendable {

    // MARK: - Properties

    private let session: NetworkSession
    private let decoder: JSONDecoder
    private let restURL: String
    private let anonKey: String

    // MARK: - Init

    init(
        restURL: String = SupabaseConfig.restURL,
        anonKey: String = SupabaseConfig.anonKey,
        session: NetworkSession = NetworkSession(),
        decoder: JSONDecoder = .snakeCaseDecoder
    ) {
        self.restURL = restURL
        self.anonKey = anonKey
        self.session = session
        self.decoder = decoder
    }

    // MARK: - DataSource (read)

    func fetchList<T: Decodable>(path: any APIPathProvider) async throws -> [T] {
        guard let (view, _) = postgrestQuery(from: path.path) else {
            throw RepositoryError.unknown
        }
        let url = try buildURL(view: view, filter: nil)
        let data = try await session.perform(request(for: url))
        return try decodeDirect([T].self, from: data, path: path)
    }

    func fetchOne<T: Decodable>(path: any APIPathProvider) async throws -> T {
        guard let (view, id) = postgrestQuery(from: path.path), let id else {
            throw RepositoryError.unknown
        }
        let url = try buildURL(view: view, filter: "id=eq.\(id)")
        let data = try await session.perform(request(for: url))
        let items = try decodeDirect([T].self, from: data, path: path)
        guard let first = items.first else { throw RepositoryError.notFound }
        return first
    }

    // MARK: - DataSource (write — V1 stubs)

    func post<T: Decodable>(path: any APIPathProvider, body: (any Encodable)?) async throws -> T {
        throw RepositoryError.unauthorized
    }

    func patch<T: Decodable>(path: any APIPathProvider, body: (any Encodable)?) async throws -> T {
        throw RepositoryError.unauthorized
    }

    func delete<T: Decodable>(path: any APIPathProvider) async throws -> T {
        throw RepositoryError.unauthorized
    }

    func delete<T: Decodable>(path: any APIPathProvider, body: (any Encodable)?) async throws -> T {
        throw RepositoryError.unauthorized
    }

    func postUnwrapped<T: Decodable>(path: any APIPathProvider, body: (any Encodable)?) async throws -> T {
        throw RepositoryError.unauthorized
    }

    // MARK: - Private Helpers

    /// Maps a DoppioAPIPath path string to the Supabase view name and optional id filter.
    ///
    /// Examples:
    ///   "/shops"     → ("v_shop",    nil)
    ///   "/shops/1"   → ("v_shop",    1)
    ///   "/baristas"  → ("v_barista", nil)
    ///   "/news/3"    → ("v_news",    3)
    private func postgrestQuery(from path: String) -> (view: String, id: Int?)? {
        let parts = path.split(separator: "/").map(String.init)
        guard let collection = parts.first else { return nil }

        let viewMapping: [String: String] = [
            "shops": "v_shop",
            "baristas": "v_barista",
            "news": "v_news",
            "cities": "cities"
        ]

        guard let view = viewMapping[collection] else { return nil }
        let id = parts.count > 1 ? Int(parts[1]) : nil
        return (view, id)
    }

    private func buildURL(view: String, filter: String?) throws -> URL {
        var urlString = "\(restURL)/\(view)?order=id"
        if let filter {
            urlString = "\(restURL)/\(view)?\(filter)"
        }
        guard let url = URL(string: urlString) else {
            throw RepositoryError.unknown
        }
        return url
    }

    private func request(for url: URL) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        return req
    }

    private func decodeDirect<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        path: any APIPathProvider
    ) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logError("Supabase decoding failed for \(path.path) → \(T.self): \(error)", category: .network)
            if let raw = String(data: data, encoding: .utf8) {
                logDebug("Raw Supabase response: \(raw)", category: .network)
            }
            throw RepositoryError.decoding(String(describing: error))
        }
    }
}
