// MockDataSource.swift
// Brew/Network
//
// Test and SwiftUI Preview implementation of DataSource.
// Reads JSON fixtures from App/Fixtures/ in the app bundle.
//
// Fixture naming: /home → home.json, /titles/a-ultima-carta → titles_a-ultima-carta.json

import Foundation

// MARK: - MockDataSource

/// Test and SwiftUI Preview `DataSource` that reads from bundle JSON fixtures.
public final class MockDataSource: DataSource, @unchecked Sendable {

    // MARK: - Properties

    /// Maps path strings to errors to throw for that path. Useful for testing error states.
    public var errorStubs: [String: RepositoryError] = [:]

    private let decoder: JSONDecoder
    private let bundle: Bundle

    // MARK: - Init

    public init(bundle: Bundle = .main, decoder: JSONDecoder = .snakeCaseDecoder) {
        self.bundle = bundle
        self.decoder = decoder
    }

    // MARK: - DataSource

    public func fetchList<T: Decodable>(path: any APIPathProvider) async throws -> [T] {
        try checkErrorStub(for: path)
        let data = try loadFixture(for: path)
        return try decodeWrapped([T].self, from: data)
    }

    public func fetchOne<T: Decodable>(path: any APIPathProvider) async throws -> T {
        try checkErrorStub(for: path)
        let data = try loadFixture(for: path)
        return try decodeWrapped(T.self, from: data)
    }

    public func post<T: Decodable>(
        path: any APIPathProvider,
        body: (any Encodable)?
    ) async throws -> T {
        try checkErrorStub(for: path)
        let data = try loadFixture(for: path)
        return try decodeWrapped(T.self, from: data)
    }

    public func patch<T: Decodable>(
        path: any APIPathProvider,
        body: (any Encodable)?
    ) async throws -> T {
        try checkErrorStub(for: path)
        let data = try loadFixture(for: path)
        return try decodeWrapped(T.self, from: data)
    }

    public func delete<T: Decodable>(path: any APIPathProvider) async throws -> T {
        try checkErrorStub(for: path)
        let data = try loadFixture(for: path)
        return try decodeWrapped(T.self, from: data)
    }

    public func delete<T: Decodable>(path: any APIPathProvider, body: (any Encodable)?) async throws -> T {
        try checkErrorStub(for: path)
        let data = try loadFixture(for: path)
        return try decodeWrapped(T.self, from: data)
    }

    public func postUnwrapped<T: Decodable>(
        path: any APIPathProvider,
        body: (any Encodable)?
    ) async throws -> T {
        try checkErrorStub(for: path)
        let data = try loadFixture(for: path)
        return try decodeDirect(T.self, from: data)
    }

    // MARK: - Private Helpers

    private func checkErrorStub(for path: any APIPathProvider) throws {
        if let error = errorStubs[path.path] { throw error }
    }

    private func loadFixture(for path: any APIPathProvider) throws -> Data {
        let fileName = fixtureFileName(for: path.path)
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            assertionFailure("MockDataSource: missing fixture '\(fileName).json' for path '\(path.path)'")
            throw RepositoryError.notFound
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            throw RepositoryError.decoding("Failed to read fixture '\(fileName).json': \(error)")
        }
    }

    private func fixtureFileName(for path: String) -> String {
        path
            .replacingOccurrences(of: "/", with: "_")
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }

    private func decodeWrapped<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(APIResponse<T>.self, from: data).data
        } catch {
            throw RepositoryError.decoding(String(describing: error))
        }
    }

    private func decodeDirect<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw RepositoryError.decoding(String(describing: error))
        }
    }
}
