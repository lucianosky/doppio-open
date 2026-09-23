// ShopDetailView.swift
// App/View/Shop

import SwiftUI
import AuthenticationServices

struct ShopDetailView: View {
    @EnvironmentObject private var coordinator: CityCoordinator
    @EnvironmentObject private var appState: AppState
    @ObservedObject var viewModel: ShopDetailViewModel
    @Environment(BrewTheme.self) private var theme
    @State private var activeAuthAction: AuthPromptAction?
    @State private var pendingRoute: CityCoordinator.Route?
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
                if let shop = viewModel.shop, let branch = viewModel.selectedBranch {
                    ZStack {
                        theme.tokens.colors.backgroundSecondary.edgesIgnoringSafeArea(.all)
                        theme.tokens.colors.backgroundPrimary

                        ScrollView {
                            VStack(spacing: 10) {
                                if shop.branches.count > 1 {
                                    Picker("Filial", selection: Binding(
                                        get: { viewModel.selectedBranch?.id ?? 0 },
                                        set: { branchId in
                                            if let branch = shop.branches.first(where: { $0.id == branchId }) {
                                                viewModel.selectBranch(branch)
                                            }
                                        }
                                    )) {
                                        ForEach(shop.branches) { branch in
                                            Text(branch.label ?? "Filial \(branch.id)").tag(branch.id)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .padding(.horizontal)
                                }

                                ShopAddressView(shop: shop, branch: branch, fullAddress: viewModel.fullAddress)

                                if viewModel.hasScheduleView {
                                    ShopScheduleView(branch: branch)
                                }

                                ShopAboutView(shop: shop)

                                ShopMainPhotoView(shop: shop)

                                if viewModel.hasCarrouselView {
                                    ShopCarrouselView(shop: shop)
                                }

                                if !shop.baristas.isEmpty {
                                    ShopDetailSectionHeader(title: "Equipe")
                                    ShopBaristaCarouselView(shop: shop) { baristaId in
                                        coordinator.push(.baristaDetail(id: baristaId))
                                    }
                                }

                                if viewModel.hasCoffeeView {
                                    ShopDetailSectionHeader(title: "Especialidades")
                                    ShopCoffeeView(shop: shop)
                                }

                                if viewModel.hasTagsView {
                                    ShopTagsView(shop: shop)
                                }

                                ShopDetailSectionHeader(title: "Localização")
                                ShopMapView(branch: branch)
                                    .frame(height: 180)
                                    .accessibilityIdentifier("shop_map_view")

                                // Check-in + Rating actions
                                HStack(spacing: 10) {
                                    Button {
                                        let route = CityCoordinator.Route.checkin(
                                            shopId: shop.id,
                                            branchId: branch.id,
                                            shopName: shop.longName,
                                            district: branch.address.district
                                        )
                                        if appState.sessionStore.isAuthenticated {
                                            coordinator.push(route)
                                        } else {
                                            pendingRoute     = route
                                            activeAuthAction = .checkin(shopName: shop.longName)
                                        }
                                    } label: {
                                        Label("Check-in", systemImage: "mappin.circle")
                                            .font(.system(size: 14, weight: .semibold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(theme.tokens.colors.primaryMain)
                                            .foregroundColor(theme.tokens.colors.backgroundPrimary)
                                            .cornerRadius(theme.tokens.radius.radiusControl)
                                    }
                                    .accessibilityIdentifier("shop_checkin_button")

                                    Button {
                                        let route = CityCoordinator.Route.rating(
                                            shopId: shop.id,
                                            branchId: branch.id,
                                            shopName: shop.longName,
                                            checkinId: nil
                                        )
                                        if appState.sessionStore.isAuthenticated {
                                            coordinator.push(route)
                                        } else {
                                            pendingRoute     = route
                                            activeAuthAction = .rating(shopName: shop.longName)
                                        }
                                    } label: {
                                        Label("Avaliar", systemImage: "star")
                                            .accessibilityIdentifier("shop_rating_button")
                                            .font(.system(size: 14, weight: .semibold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(theme.tokens.colors.backgroundCard)
                                            .foregroundColor(theme.tokens.colors.textPrimary)
                                            .cornerRadius(theme.tokens.radius.radiusControl)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: theme.tokens.radius.radiusControl)
                                                    .stroke(theme.tokens.colors.primaryMain.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                }

                                ShopSocialNetView(shop: shop, branch: branch)

                                if let reservationURL = branch.reservation.flatMap({ URL(string: $0) }) {
                                    Link(destination: reservationURL) {
                                        Text("Reservar mesa")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(theme.tokens.colors.primaryMain)
                                            .cornerRadius(theme.tokens.radius.radiusCard)
                                    }
                                    .accessibilityLabel("Reservar mesa")
                                }
                            }
                            .padding(10)
                        }
                    }
                } else {
                    ErrorView(
                        errorMessage: "Dados não encontrados",
                        retryAction: { Task { await viewModel.loadData(id: id) } }
                    )
                }
            }
        }
        .navigationBarTitle(viewModel.shop?.longName ?? "", displayMode: .inline)
        .doppioBackButton()
        .task {
            if viewModel.viewLoadState == .preload {
                await viewModel.loadData(id: id)
            }
        }
        .sheet(item: $activeAuthAction, onDismiss: {
            guard appState.sessionStore.isAuthenticated, let route = pendingRoute else {
                pendingRoute = nil
                return
            }
            pendingRoute = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                coordinator.push(route)
            }
        }, content: { action in
            AuthPromptSheet(
                loginViewModel: appState.container.loginViewModel,
                action: action,
                onDismiss: { activeAuthAction = nil }
            )
            .presentationDetents([.height(460)])
        })
        .onChange(of: appState.sessionStore.isAuthenticated) { _, isAuthenticated in
            guard isAuthenticated else { return }
            activeAuthAction = nil  // fecha o sheet; onDismiss cuida do push
        }
    }
}

// MARK: - ShopDetailSectionHeader

private struct ShopDetailSectionHeader: View {
    let title: String
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(theme.tokens.colors.textSecondary.opacity(0.6))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.top, 4)
    }
}
