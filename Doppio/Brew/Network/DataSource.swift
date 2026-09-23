// DataSource.swift
// Brew/Network

import Foundation

// MARK: - DataSource

/// Abstracts the origin of data for all Repository operations.
public protocol DataSource: Sendable {
    func fetchList<T: Decodable>(path: any APIPathProvider) async throws -> [T]
    func fetchOne<T: Decodable>(path: any APIPathProvider) async throws -> T
    func post<T: Decodable>(path: any APIPathProvider, body: (any Encodable)?) async throws -> T
    func patch<T: Decodable>(path: any APIPathProvider, body: (any Encodable)?) async throws -> T
    func delete<T: Decodable>(path: any APIPathProvider) async throws -> T
    func delete<T: Decodable>(path: any APIPathProvider, body: (any Encodable)?) async throws -> T

    /// POST for auth endpoints that return the payload at the root level,
    /// without the standard `{ "data": ... }` envelope.
    /// Used by POST /auth/login and POST /auth/register/complete.
    func postUnwrapped<T: Decodable>(path: any APIPathProvider, body: (any Encodable)?) async throws -> T
}
