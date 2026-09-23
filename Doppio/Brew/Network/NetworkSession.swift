// NetworkSession.swift
// Brew/Network

import Foundation

// MARK: - NetworkSessionProtocol

/// Abstracts URLSession for testing purposes.
public protocol NetworkSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSessionProtocol {}

// MARK: - NetworkSession

/// Executes HTTP requests and maps errors to `RepositoryError`.
public final class NetworkSession {

    // MARK: - Private Properties

    private let session: NetworkSessionProtocol
    private let decoder: JSONDecoder

    // MARK: - Init

    public init(
        session: NetworkSessionProtocol = URLSession.shared,
        decoder: JSONDecoder = .snakeCaseDecoder
    ) {
        self.session = session
        self.decoder = decoder
    }

    // MARK: - Public Methods

    /// Executes the request and returns the raw response `Data`.
    public func perform(_ request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse

        logDebug("→ \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")", category: .network)

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logError("Network failure: \(error.localizedDescription)", category: .network)
            throw RepositoryError.unknown
        }

        guard let http = response as? HTTPURLResponse else {
            logError("Non-HTTP response for \(request.url?.absoluteString ?? "?")", category: .network)
            throw RepositoryError.unknown
        }

        logDebug("← \(http.statusCode) \(request.url?.absoluteString ?? "?")", category: .network)

        switch http.statusCode {
        case 200...299:
            return data
        case 401:
            logWarning("401 Unauthorized — \(request.url?.absoluteString ?? "?")", category: .network)
            throw RepositoryError.unauthorized
        case 404:
            logWarning("404 Not Found — \(request.url?.absoluteString ?? "?")", category: .network)
            throw RepositoryError.notFound
        default:
            let repositoryError = parseError(from: data, statusCode: http.statusCode)
            let url = request.url?.absoluteString ?? "?"
            logError("HTTP \(http.statusCode) — \(url): \(repositoryError)", category: .network)
            throw repositoryError
        }
    }

    // MARK: - Private Methods

    private func parseError(from data: Data, statusCode: Int) -> RepositoryError {
        if let rule = try? decoder.decode(BusinessRuleErrorResponse.self, from: data),
           let code = rule.code {
            return .businessRule(code: code, message: rule.message)
        }
        if let nest = try? decoder.decode(NestErrorResponse.self, from: data) {
            return .network(statusCode: statusCode, message: nest.message)
        }
        return .network(statusCode: statusCode, message: String(localized: "error.unknown"))
    }
}

// MARK: - Private Error Response Models

private struct NestErrorResponse: Decodable {
    let message: String
    let statusCode: Int
}

private struct BusinessRuleErrorResponse: Decodable {
    let code: String?
    let message: String
}

// MARK: - JSONDecoder Extension

extension JSONDecoder {
    public static let snakeCaseDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
