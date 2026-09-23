// RepositoryError.swift
// Brew/Shared
//
// Unified error type for all Repository operations.
import Foundation

// Maps both API error formats: the standard Nest envelope and the
// simplified business rule format used by credit/billing endpoints.
//
// Standard Nest envelope:
//   { "message": "...", "error": "Bad Request", "statusCode": 400 }
//
// Simplified business rule format:
//   { "code": "insufficient_credits", "message": "..." }

/// Errors that can be thrown by any Repository in the Brew architecture.
///
/// Repositories catch raw network and decoding errors and rethrow them
/// as `RepositoryError` cases. ViewModels receive only this type.
public enum RepositoryError: Error, Equatable {

    // MARK: - Cases

    /// A network request completed but the server returned a non-success
    /// HTTP status code with a standard error envelope.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code (e.g. 400, 409, 500).
    ///   - message: The `message` field from the error envelope.
    case network(statusCode: Int, message: String)

    /// The server returned a business rule violation using the simplified
    /// error format (e.g. `insufficient_credits`, `negative_balance_block`).
    ///
    /// - Parameters:
    ///   - code: Machine-readable error code (e.g. `"insufficient_credits"`).
    ///   - message: Human-readable description of the violation.
    case businessRule(code: String, message: String)

    /// The response payload could not be decoded into the expected type.
    ///
    /// - Parameter reason: A description of the decoding failure, for logging only.
    ///   Not shown to the user.
    case decoding(String)

    /// The request was rejected due to missing, invalid, expired, or revoked
    /// authentication (HTTP 401).
    case unauthorized

    /// The requested resource does not exist (HTTP 404).
    case notFound

    /// An unexpected error with no specific mapping.
    case unknown
}

// MARK: - LocalizedError

extension RepositoryError: LocalizedError {

    /// A localized, user-facing description of the error.
    ///
    /// All strings are resolved via `String(localized:)` from `Localizable.xcstrings`.
    /// For `.network` and `.businessRule`, the message comes directly from the API
    /// response and is used as-is (the backend already returns Portuguese messages).
    public var errorDescription: String? {
        switch self {
        case .network(_, let message):
            return message
        case .businessRule(_, let message):
            return message
        case .decoding:
            return String(localized: "error.decoding")
        case .unauthorized:
            return String(localized: "error.unauthorized")
        case .notFound:
            return String(localized: "error.not_found")
        case .unknown:
            return String(localized: "error.unknown")
        }
    }
}
