// ProfileSheetView.swift
// App/View/Home

import SwiftUI

struct ProfileSheetView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(BrewTheme.self) private var theme
    @Environment(\.dismiss) private var dismiss

    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }
    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    var body: some View {
        NavigationStack {
            List {
                if appState.sessionStore.isAuthenticated {
                    Section("Perfil") {
                        if let userId = appState.sessionStore.userId {
                            LabeledContent("ID do usuário") {
                                Text(userId)
                                    .font(.caption)
                                    .foregroundColor(theme.tokens.colors.textSecondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                    }
                    .listRowBackground(theme.tokens.colors.backgroundCard)
                }

                Section("Sobre o app") {
                    LabeledContent("Versão", value: "v\(version) (\(build))")
                    LabeledContent("App", value: "Doppio — Guia de Cafeterias")
                }
                .listRowBackground(theme.tokens.colors.backgroundCard)

                if appState.sessionStore.isAuthenticated {
                    Section {
                        Button(role: .destructive) {
                            appState.sessionStore.signOut()
                            dismiss()
                        } label: {
                            Text("Sair da conta")
                        }
                        .accessibilityIdentifier("profile_logout_button")
                    }
                    .listRowBackground(theme.tokens.colors.backgroundCard)
                }
            }
            .scrollContentBackground(.hidden)
            .background(theme.tokens.colors.backgroundPrimary)
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }
}
