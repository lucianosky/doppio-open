// BaristaDetailView.swift
// App/View/Barista

import SwiftUI

struct BaristaDetailView: View {
    @ObservedObject var viewModel: BaristaDetailViewModel
    @Environment(BrewTheme.self) private var theme
    let id: Int

    var body: some View {
        Group {
            switch viewModel.viewLoadState {
            case .preload, .loading:
                LoadingView(message: "Carregando detalhes…")

            case .error(let message, let canRetry):
                ErrorView(
                    errorMessage: message,
                    retryAction: canRetry ? { Task { await viewModel.loadData(id: id) } } : nil
                )

            case .content:
                if let barista = viewModel.barista {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(barista.name)
                                    .font(.system(size: 19, weight: .heavy))
                                    .foregroundColor(theme.tokens.colors.primaryMain)

                                if let shopName = barista.shopName {
                                    Text("\(barista.title) · \(shopName)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(theme.tokens.colors.primaryMain)
                                } else {
                                    Text(barista.title)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(theme.tokens.colors.primaryMain)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(theme.tokens.colors.backgroundCard)
                            .cornerRadius(14)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("\(barista.name). \(barista.title)")
                            .accessibilityIdentifier("barista_detail_header")

                            if let asset = barista.imageAsset {
                                DoppioAsyncImage(url: asset)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 250)
                                    .clipped()
                                    .cornerRadius(15)
                                    .accessibilityLabel("Foto de \(barista.name)")
                            }

                            if let about = barista.about {
                                Text(about)
                                    .font(.body)
                                    .foregroundColor(theme.tokens.colors.textPrimary)
                                    .multilineTextAlignment(.leading)
                                    .padding()
                                    .background(theme.tokens.colors.backgroundCard)
                                    .cornerRadius(15)
                            }

                            if let instagram = barista.instagram, !instagram.isEmpty,
                               let url = URL(string: "https://instagram.com/\(instagram)") {
                                Link(destination: url) {
                                    HStack {
                                        Image(systemName: "camera")
                                            .foregroundColor(theme.tokens.colors.primaryMain)
                                        Text("@\(instagram)")
                                            .font(.subheadline)
                                            .foregroundColor(theme.tokens.colors.primaryMain)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                            .foregroundColor(theme.tokens.colors.textSecondary)
                                    }
                                    .padding()
                                    .background(theme.tokens.colors.backgroundCard)
                                    .cornerRadius(12)
                                }
                                .accessibilityLabel("Instagram de \(barista.name)")
                            }

                            if let email = barista.email, !email.isEmpty,
                               let url = URL(string: "mailto:\(email)") {
                                Link(destination: url) {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                            .foregroundColor(theme.tokens.colors.textSecondary)
                                        Text(email)
                                            .font(.subheadline)
                                            .foregroundColor(theme.tokens.colors.textPrimary)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                            .foregroundColor(theme.tokens.colors.textSecondary)
                                    }
                                    .padding()
                                    .background(theme.tokens.colors.backgroundCard)
                                    .cornerRadius(12)
                                }
                                .accessibilityLabel("Email de \(barista.name)")
                            }
                        }
                        .padding()
                    }
                    .background(theme.tokens.colors.backgroundPrimary)
                    .scrollContentBackground(.hidden)
                } else {
                    ErrorView(
                        errorMessage: "Dados não encontrados",
                        retryAction: { Task { await viewModel.loadData(id: id) } }
                    )
                }
            }
        }
        .navigationBarTitle(viewModel.barista?.name ?? "Barista", displayMode: .inline)
        .doppioBackButton()
        .task {
            if viewModel.viewLoadState == .preload {
                await viewModel.loadData(id: id)
            }
        }
    }
}
