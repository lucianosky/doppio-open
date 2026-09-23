// DoppioDataSource.swift
// App/Network
//
// Factory that creates the correct DataSource for each environment.
// V1: always MockDataSource (no live backend).
// V2: switch to RemoteDataSource when backend is ready.

import Foundation

// MARK: - DoppioDataSource

enum DoppioDataSource {

    /// Creates the DataSource for the given environment.
    ///
    /// V1: both `.mock` and `.production` return `MockDataSource`,
    /// since the backend is not yet deployed. In V2, `.production` will
    /// return a configured `RemoteDataSource`.
    static func make(environment: APIEnvironment) -> any DataSource {
        switch environment {
        case .mock:
            return MockDataSource()
        case .production:
            return SupabaseDataSource()
        }
    }
}
