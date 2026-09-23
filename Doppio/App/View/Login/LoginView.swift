// LoginView.swift
// App/View/Login

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(BrewTheme.self) private var theme
    @EnvironmentObject private var appState: AppState

    @StateObject private var vm: LoginViewModel

    init(vm: LoginViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "v\(version) (\(build))"
    }

    var body: some View {
        ZStack {
            theme.tokens.colors.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                Image("icon-cup")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .foregroundColor(theme.tokens.colors.primaryMain)
                    .padding(.bottom, 8)

                Text("Doppio")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(theme.tokens.colors.textPrimary)
                    .padding(.bottom, 8)

                Text("Guia de cafés especiais")
                    .font(.system(size: 14))
                    .foregroundColor(theme.tokens.colors.textSecondary)
                    .padding(.bottom, 48)

                // Apple Sign In
                ZStack {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.email]
                    } onCompletion: { _ in }
                        .signInWithAppleButtonStyle(.white)
                        .opacity(vm.isLoading ? 0.5 : 1)
                        .allowsHitTesting(!vm.isLoading)
                        .onTapGesture {
                            Task { await vm.signInWithApple() }
                        }

                    if vm.isLoading {
                        ProgressView()
                            .tint(theme.tokens.colors.primaryMain)
                    }
                }
                .frame(height: 50)
                .padding(.horizontal, 24)

                // Contexto do login
                Text("Entre para registrar check-ins e avaliações")
                    .font(.system(size: 12))
                    .foregroundColor(theme.tokens.colors.textSecondary.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 6)
                    .padding(.bottom, 24)

                // Explorar sem login
                Button {
                    vm.continueAnonymously()
                } label: {
                    Text("Explorar cafés")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(theme.tokens.colors.textPrimary.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(theme.tokens.colors.textPrimary.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
                .accessibilityIdentifier("login_explore_button")

                Spacer()

                Text(appVersion)
                    .font(.system(size: 9))
                    .foregroundColor(theme.tokens.colors.textSecondary.opacity(0.15))
                    .padding(.bottom, 12)
            }
        }
        .alert("Não foi possível entrar", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}
