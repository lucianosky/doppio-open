// LoginViewModel.swift
// App/ViewModel

import Foundation
import Combine
import AuthenticationServices

// MARK: - LoginViewModel

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authRepository: SupabaseAuthRepository
    private let sessionStore: SessionStore

    init(authRepository: SupabaseAuthRepository, sessionStore: SessionStore) {
        self.authRepository = authRepository
        self.sessionStore   = sessionStore
    }

    // MARK: - Actions

    func signInWithApple() async {
        isLoading    = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let (token, nonce) = try await authRepository.requestAppleSignIn()
            try await authRepository.signInWithApple(identityToken: token, nonce: nonce)
        } catch {
            if (error as NSError).code == ASAuthorizationError.canceled.rawValue { return }
            errorMessage = Self.humanizedAuthError(error)
        }
    }

    // MARK: - Helpers

    private static func humanizedAuthError(_ error: Error) -> String {
        if let appleError = error as? ASAuthorizationError {
            switch appleError.code {
            case .failed:          return "Não foi possível autenticar com a Apple. Tente novamente."
            case .invalidResponse: return "Resposta inválida da Apple. Tente novamente."
            case .notHandled:      return "Autenticação não processada. Tente novamente."
            case .notInteractive:  return "Autenticação não disponível agora. Tente mais tarde."
            default:               return "Não foi possível entrar. Tente novamente."
            }
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet: return "Sem conexão com a internet. Verifique sua rede."
            case .timedOut:               return "A requisição demorou demais. Tente novamente."
            default:                      return "Não foi possível entrar. Tente novamente."
            }
        }
        return "Não foi possível entrar. Tente novamente."
    }

    func continueAnonymously() {
        sessionStore.continueAnonymously()
    }
}
