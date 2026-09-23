// AuthRepository.swift
// App/Auth

import Foundation

// MARK: - AuthRepository

protocol AuthRepository {
    /// Sign in with Apple identity token obtained from ASAuthorizationAppleIDProvider.
    func signInWithApple(identityToken: String, nonce: String?) async throws
}
