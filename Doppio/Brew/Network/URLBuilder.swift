// URLBuilder.swift
// Brew/Network

import Foundation

// MARK: - APIPathProvider

/// A type that can provide a relative URL path string.
///
/// `APIPath` in `App/Network/APIPath.swift` must conform to this protocol.
public protocol APIPathProvider {

    /// The relative path for this endpoint, starting with `/`.
    var path: String { get }
}

// MARK: - URLBuilder

/// Builds fully qualified `URL` values from an `APIEnvironment` and any `APIPathProvider`.
public struct URLBuilder {

    // MARK: - Properties

    public let environment: APIEnvironment
    public let basePath: String

    // MARK: - Init

    public init(environment: APIEnvironment, basePath: String = "/api/app/v1") {
        self.environment = environment
        self.basePath = basePath
    }

    // MARK: - Public Methods

    /// Builds a fully qualified `URL` for the given path provider.
    public func url(for pathProvider: any APIPathProvider) -> URL? {
        let urlString = environment.baseURL + basePath + pathProvider.path
        guard let url = URL(string: urlString) else {
            assertionFailure("URLBuilder: failed to construct URL from '\(urlString)'")
            return nil
        }
        return url
    }

    /// Builds a fully qualified `URL` with query parameters appended.
    public func url(
        for pathProvider: any APIPathProvider,
        queryItems: [URLQueryItem]
    ) -> URL? {
        guard let base = url(for: pathProvider) else { return nil }
        guard !queryItems.isEmpty else { return base }
        var components = URLComponents(url: base, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        return components?.url
    }
}
