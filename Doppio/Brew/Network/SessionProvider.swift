// SessionProvider.swift
// Brew/Network
//
// Unified protocol for session management in the network layer.
// Combines token reading and session invalidation into a single abstraction,
// replacing the separate AuthTokenProvider and SessionInvalidationHandler protocols.

import Foundation

// MARK: - SessionProvider

/// Unified session abstraction used by RemoteDataSource.
///
/// Provides the current Bearer token for authenticated requests and receives
/// notification when a 401 response is detected, so the session can be cleared.
///
/// The reference in RemoteDataSource is `weak` — conformers must be classes.
public protocol SessionProvider: AnyObject, Sendable {

    /// The current Bearer token, or nil if the user is not authenticated.
    var accessToken: String? { get }

    /// Called by RemoteDataSource when any request receives a 401 response.
    /// Implementations should clear the token and update authentication state.
    @MainActor func invalidateSession()
}
