// RemoteDataSource.swift
// Brew/Network

import Foundation

// MARK: - RemoteDataSource

/// Live `DataSource` implementation that fetches data from the Raipe API.
public final class RemoteDataSource: DataSource, @unchecked Sendable {

    // MARK: - Properties

    private let urlBuilder: URLBuilder
    private let session: NetworkSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let clientHeaders: [String: String]

    /// Weak reference to the unified session provider.
    /// Provides the Bearer token for every request and receives 401 notifications.
    private weak var sessionProvider: (any SessionProvider)?

    // MARK: - Init

    public init(
        urlBuilder: URLBuilder,
        session: NetworkSession,
        sessionProvider: any SessionProvider,
        decoder: JSONDecoder = .snakeCaseDecoder,
        encoder: JSONEncoder = JSONEncoder(),
        clientHeaders: [String: String] = [:]
    ) {
        self.urlBuilder = urlBuilder
        self.session = session
        self.sessionProvider = sessionProvider
        self.decoder = decoder
        self.encoder = encoder
        self.clientHeaders = clientHeaders
    }

    // MARK: - DataSource

    public func fetchList<T: Decodable>(path: any APIPathProvider) async throws -> [T] {
        let request = try buildRequest(path: path, method: "GET")
        let data = try await execute(request)
        return try decodeWrapped([T].self, from: data, path: path)
    }

    public func fetchOne<T: Decodable>(path: any APIPathProvider) async throws -> T {
        let request = try buildRequest(path: path, method: "GET")
        let data = try await execute(request)
        return try decodeWrapped(T.self, from: data, path: path)
    }

    public func post<T: Decodable>(
        path: any APIPathProvider,
        body: (any Encodable)?
    ) async throws -> T {
        let request = try buildRequest(path: path, method: "POST", body: body)
        let data = try await execute(request)
        return try decodeWrapped(T.self, from: data, path: path)
    }

    public func patch<T: Decodable>(
        path: any APIPathProvider,
        body: (any Encodable)?
    ) async throws -> T {
        let request = try buildRequest(path: path, method: "PATCH", body: body)
        let data = try await execute(request)
        return try decodeWrapped(T.self, from: data, path: path)
    }

    public func delete<T: Decodable>(path: any APIPathProvider) async throws -> T {
        let request = try buildRequest(path: path, method: "DELETE")
        let data = try await execute(request)
        return try decodeWrapped(T.self, from: data, path: path)
    }

    public func delete<T: Decodable>(path: any APIPathProvider, body: (any Encodable)?) async throws -> T {
        var request = try buildRequest(path: path, method: "DELETE")
        if let body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let data = try await execute(request)
        return try decodeWrapped(T.self, from: data, path: path)
    }

    // MARK: - Auth Routes (no data wrapper)

    /// Performs a POST for auth routes that return payload at the root level.
    /// Used by `POST /auth/login` and `POST /auth/register`.
    public func postUnwrapped<T: Decodable>(
        path: any APIPathProvider,
        body: (any Encodable)?
    ) async throws -> T {
        let request = try buildRequest(path: path, method: "POST", body: body)
        let data = try await execute(request)
        return try decodeDirect(T.self, from: data, path: path)
    }

    // MARK: - Private Helpers

    /// Executes the request via NetworkSession, intercepting 401 to notify
    /// the session invalidation handler before rethrowing the error.
    private func execute(_ request: URLRequest) async throws -> Data {
        do {
            return try await session.perform(request)
        } catch RepositoryError.unauthorized {
            let provider = sessionProvider
            Task { @MainActor in
                provider?.invalidateSession()
            }
            throw RepositoryError.unauthorized
        }
    }

    private func buildRequest(
        path: any APIPathProvider,
        method: String,
        body: (any Encodable)? = nil
    ) throws -> URLRequest {
        guard let url = urlBuilder.url(for: path) else {
            logError("Failed to build URL for path: \(path.path)", category: .network)
            throw RepositoryError.unknown
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        for (key, value) in clientHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Correlation-ID")

        if let token = sessionProvider?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            do {
                request.httpBody = try encoder.encode(AnyEncodable(body))
            } catch {
                logError("Failed to encode request body for \(path.path): \(error)", category: .network)
                throw RepositoryError.decoding("Failed to encode request body: \(error)")
            }
        }

        return request
    }

    private func decodeWrapped<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        path: any APIPathProvider
    ) throws -> T {
        do {
            return try decoder.decode(APIResponse<T>.self, from: data).data
        } catch {
            logError("Decoding failed for \(path.path) → \(T.self): \(error)", category: .network)
            logRawJSON(data, path: path)
            throw RepositoryError.decoding(String(describing: error))
        }
    }

    private func decodeDirect<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        path: any APIPathProvider
    ) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logError("Direct decoding failed for \(path.path) → \(T.self): \(error)", category: .network)
            logRawJSON(data, path: path)
            throw RepositoryError.decoding(String(describing: error))
        }
    }

    /// Logs the raw JSON response to the console on decode failure.
    /// Only active in DEBUG builds — no-op in release.
    private func logRawJSON(_ data: Data, path: any APIPathProvider) {
        #if DEBUG
        if let json = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let string = String(data: pretty, encoding: .utf8) {
            logDebug("Raw JSON for \(path.path):\n\(string)", category: .network)
        } else if let raw = String(data: data, encoding: .utf8) {
            logDebug("Raw response (not valid JSON) for \(path.path):\n\(raw)", category: .network)
        }
        #endif
    }
}

// MARK: - AnyEncodable

private struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init(_ wrapped: any Encodable) {
        self.encodeFunc = wrapped.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
