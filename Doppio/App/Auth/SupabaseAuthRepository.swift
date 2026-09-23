// SupabaseAuthRepository.swift
// App/Auth
//
// Implements Apple Sign In via Supabase Auth REST API.
//
// Pre-requisite: Apple provider must be enabled in Supabase dashboard
//   Auth → Providers → Apple → enable + configure with Apple Developer credentials.

import Foundation
import AuthenticationServices
import CryptoKit

// MARK: - Auth response types (private)

private struct AuthUserResponse: Decodable { let id: String }
private struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: AuthUserResponse
}

// MARK: - SupabaseAuthRepository

@MainActor
final class SupabaseAuthRepository: NSObject, AuthRepository {

    private let sessionStore: SessionStore
    private let authBaseURL = SupabaseConfig.projectURL + "/auth/v1"
    private let anonKey     = SupabaseConfig.anonKey

    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?
    private var currentNonce: String?

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }

    // MARK: - AuthRepository

    func signInWithApple(identityToken: String, nonce: String?) async throws {
        let url = URL(string: "\(authBaseURL)/token?grant_type=id_token")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: String] = ["provider": "apple", "id_token": identityToken]
        if let nonce { body["nonce"] = nonce }
        req.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: req)
        if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
            let msg = String(data: data, encoding: .utf8) ?? "auth error"
            throw AuthError.supabaseFailed(msg)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resp = try decoder.decode(AuthResponse.self, from: data)
        sessionStore.setSession(token: resp.accessToken, refreshToken: resp.refreshToken, userId: resp.user.id)
    }

    // MARK: - Native Apple Sign In flow

    /// Triggers the native Apple Sign In sheet and returns the credential.
    func requestAppleSignIn() async throws -> (identityToken: String, nonce: String) {
        let nonce = randomNonce()
        currentNonce = nonce
        let hashedNonce = sha256(nonce)

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email]
        request.nonce = hashedNonce

        let credential = try await withCheckedThrowingContinuation { cont in
            continuation = cont
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }

        guard let tokenData = credential.identityToken,
              let tokenString = String(data: tokenData, encoding: .utf8) else {
            throw AuthError.missingIdentityToken
        }
        return (tokenString, nonce)
    }

    // MARK: - Crypto helpers

    private func randomNonce(length: Int = 32) -> String {
        var bytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    private func sha256(_ input: String) -> String {
        let hash = SHA256.hash(data: Data(input.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension SupabaseAuthRepository: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        continuation?.resume(returning: credential)
        continuation = nil
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension SupabaseAuthRepository: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        if let window = scenes.compactMap(\.keyWindow).first { return window }
        guard let scene = scenes.first else {
            fatalError("No UIWindowScene available when requesting presentation anchor")
        }
        return UIWindow(windowScene: scene)
    }
}

// MARK: - Errors

enum AuthError: LocalizedError {
    case missingIdentityToken
    case supabaseFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingIdentityToken:   return "Não foi possível obter o token da Apple."
        case .supabaseFailed(let msg): return "Erro de autenticação: \(msg)"
        }
    }
}
