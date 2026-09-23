// AuthPromptSheet.swift
// App/View/Shared
//
// Bottom sheet presented when an anonymous user taps an action that requires
// authentication (check-in, rating). Personalizes copy based on the action
// and shop name.

import SwiftUI
import AuthenticationServices

// MARK: - AuthPromptAction

enum AuthPromptAction: Identifiable {
    case checkin(shopName: String)
    case rating(shopName: String)

    var id: String {
        switch self {
        case .checkin(let name): return "checkin-\(name)"
        case .rating(let name):  return "rating-\(name)"
        }
    }

    var icon: String {
        switch self {
        case .checkin: return "mappin.fill"
        case .rating:  return "star.fill"
        }
    }

    var title: String {
        switch self {
        case .checkin(let name): return "Faça check-in no \(name)"
        case .rating(let name):  return "Avalie o \(name)"
        }
    }

    var subtitle: String {
        switch self {
        case .checkin:
            return "Registre suas visitas, acompanhe seu histórico e descubra cafés que você ainda não conhece."
        case .rating:
            return "Sua avaliação ajuda outros amantes de café a encontrar os melhores lugares da cidade."
        }
    }
}

// MARK: - AuthPromptSheet

struct AuthPromptSheet: View {
    @Environment(BrewTheme.self) private var theme
    @ObservedObject var loginViewModel: LoginViewModel
    let action: AuthPromptAction
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(theme.tokens.colors.textSecondary.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)

            // Icon
            Image(systemName: action.icon)
                .font(.system(size: 36))
                .foregroundColor(theme.tokens.colors.primaryMain)
                .padding(.bottom, 12)

            // Title
            Text(action.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(theme.tokens.colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 6)

            // Subtitle
            Text(action.subtitle)
                .font(.system(size: 14))
                .foregroundColor(theme.tokens.colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)

            // Sign in with Apple
            ZStack {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.email]
                } onCompletion: { _ in }
                    .signInWithAppleButtonStyle(.white)
                    .opacity(loginViewModel.isLoading ? 0.5 : 1)
                    .allowsHitTesting(!loginViewModel.isLoading)
                    .onTapGesture {
                        Task { await loginViewModel.signInWithApple() }
                    }

                if loginViewModel.isLoading {
                    ProgressView()
                        .tint(theme.tokens.colors.primaryMain)
                }
            }
            .frame(height: 50)
            .padding(.horizontal, 24)

            if let error = loginViewModel.errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundColor(theme.tokens.colors.errorMain)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
            }

            // Dismiss
            Button(action: onDismiss) {
                Text("Agora não")
                    .font(.system(size: 15))
                    .foregroundColor(theme.tokens.colors.textSecondary)
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background(theme.tokens.colors.backgroundPrimary)
    }
}
