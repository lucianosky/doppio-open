// APIEnvironment.swift
// Brew/Network
//
// Defines the available API environments and their base URLs.
// Production must always use HTTPS.

import Foundation

/// The target API environment for all network requests.
///
/// Injected into `URLBuilder` and `RemoteDataSource` via `AppContainer`.
/// Switch environments at the `AppContainer` level — never inside individual
/// repositories or data sources.
public enum APIEnvironment {

    // MARK: - Cases

    /// No network calls. `MockDataSource` reads from bundle JSON fixtures.
    case mock

    /// Production environment (HTTPS).
    case production(baseURL: String)

    // MARK: - Base URL

    /// The base URL for the environment, without a trailing slash.
    ///
    /// `mock` returns an empty string — `URLBuilder` is not used by `MockDataSource`.
    public var baseURL: String {
        switch self {
        case .mock:
            return ""
        case .production(let url):
            return url
        }
    }

    // MARK: - Client Headers

    /// Extra headers identifying the client channel.
    /// Populated when the backend is live. Empty for mock.
    public var clientHeaders: [String: String] {
        switch self {
        case .mock:
            return [:]
        case .production:
            return [
                "X-App-Version": appVersion
            ]
        }
    }

    // MARK: - Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}
