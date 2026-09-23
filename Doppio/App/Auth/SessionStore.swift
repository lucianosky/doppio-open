// SessionStore.swift
// App/Auth
//
// Single source of truth for authentication state.
// Conforms to SessionProvider (Brew) so the network layer can inject the Bearer token.
// JWT persisted in Keychain; "has passed login screen" flag in UserDefaults.
//
// Concurrency note: accessToken is declared nonisolated (required by SessionProvider/Sendable).
// The token is cached in a nonisolated(unsafe) stored property so Keychain is only
// accessed from @MainActor context (init + setSession + signOut), avoiding Swift 6
// actor-isolation errors on static Security APIs.

import Foundation
import Combine

private let jwtKey          = "doppio.auth.jwt"
private let refreshTokenKey = "doppio.auth.refreshToken"
private let userIdKey       = "doppio.auth.userId"
private let launchedKey     = "doppio.auth.hasLaunched"

// MARK: - SessionStore

@MainActor
final class SessionStore: ObservableObject, SessionProvider {

    // MARK: - Published

    @Published private(set) var isAuthenticated = false

    /// True after the user either logged in or chose "Continuar sem login".
    /// Prevents showing the login screen on every cold start.
    @Published private(set) var hasPassedLogin = false

    // MARK: - SessionProvider

    /// Cached JWT for nonisolated access. Updated on main actor in setSession/signOut/restoreSession.
    nonisolated(unsafe) private var _accessToken: String?
    nonisolated(unsafe) private var _refreshToken: String?

    nonisolated var accessToken: String? { _accessToken }
    nonisolated var refreshToken: String? { _refreshToken }

    func invalidateSession() {
        signOut()
    }

    // MARK: - Public

    var userId: String? {
        KeychainHelper.read(key: userIdKey)
    }

    // MARK: - Init

    init() {
        if ProcessInfo.processInfo.arguments.contains("-uitest_authenticated") {
            injectMockSession()
        } else if ProcessInfo.processInfo.arguments.contains("-uitest_clear_session") {
            clearSession()
        } else {
            restoreSession()
        }
    }

    // MARK: - Actions

    func setSession(token: String, refreshToken: String, userId: String) {
        KeychainHelper.write(key: jwtKey, value: token)
        KeychainHelper.write(key: refreshTokenKey, value: refreshToken)
        KeychainHelper.write(key: userIdKey, value: userId)
        _accessToken    = token
        _refreshToken   = refreshToken
        isAuthenticated = true
        hasPassedLogin  = true
        UserDefaults.standard.set(true, forKey: launchedKey)
    }

    /// Usa o refresh token para obter um novo access token.
    /// Retorna `true` se bem-sucedido.
    func refreshSession() async -> Bool {
        // In UI test mode the token is a mock — skip refresh and let the
        // caller handle the error as an alert, without signing the user out.
        if ProcessInfo.processInfo.arguments.contains("-uitest_authenticated") { return false }
        guard let rt = _refreshToken else {
            signOut()   // sem refresh token — força re-login
            return false
        }
        let refreshURL = SupabaseConfig.projectURL + "/auth/v1/token?grant_type=refresh_token"
        guard let url = URL(string: refreshURL) else { return false }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(["refresh_token": rt])

        guard let (data, response) = try? await URLSession.shared.data(for: req),
              let http = response as? HTTPURLResponse, http.statusCode < 400 else {
            signOut()
            return false
        }

        struct RefreshResponse: Decodable {
            let accessToken: String
            let refreshToken: String
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let resp = try? decoder.decode(RefreshResponse.self, from: data) else {
            signOut()
            return false
        }

        KeychainHelper.write(key: jwtKey, value: resp.accessToken)
        KeychainHelper.write(key: refreshTokenKey, value: resp.refreshToken)
        _accessToken  = resp.accessToken
        _refreshToken = resp.refreshToken
        return true
    }

    func continueAnonymously() {
        hasPassedLogin = true
        UserDefaults.standard.set(true, forKey: launchedKey)
    }

    func signOut() {
        KeychainHelper.delete(key: jwtKey)
        KeychainHelper.delete(key: userIdKey)
        _accessToken    = nil
        isAuthenticated = false
        hasPassedLogin  = false
        UserDefaults.standard.removeObject(forKey: launchedKey)
    }

    // MARK: - Private

    private func clearSession() {
        KeychainHelper.delete(key: jwtKey)
        KeychainHelper.delete(key: refreshTokenKey)
        KeychainHelper.delete(key: userIdKey)
        UserDefaults.standard.removeObject(forKey: launchedKey)
    }

    private func injectMockSession() {
        _accessToken    = "uitest-mock-token"
        isAuthenticated = true
        hasPassedLogin  = true
    }

    private func restoreSession() {
        hasPassedLogin = UserDefaults.standard.bool(forKey: launchedKey)
        if let token = KeychainHelper.read(key: jwtKey) {
            _accessToken    = token
            _refreshToken   = KeychainHelper.read(key: refreshTokenKey)
            isAuthenticated = true
        }
    }
}
