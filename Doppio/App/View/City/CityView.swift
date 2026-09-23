// CityView.swift
// App/View/City

import SwiftUI

struct CityView: View {
    @ObservedObject var viewModel: CityViewModel
    @EnvironmentObject private var coordinator: CityCoordinator
    @Environment(BrewTheme.self) private var theme
    @State private var showingFilterSheet = false
    @State private var filterBadgeCount: Int = 0

    var body: some View {
        ZStack {
            switch viewModel.viewLoadState {
            case .preload, .loading:
                LoadingView(message: "Carregando cafeterias…")

            case .error(let message, let canRetry):
                ErrorView(
                    errorMessage: message,
                    retryAction: canRetry ? { Task { await viewModel.loadData() } } : nil
                )

            case .content:
                Group {
                    switch viewModel.viewMode {
                    case .map:
                        CityMapView(
                            cityViewModel: viewModel,
                            onSelectShop: { id in coordinator.push(.shopDetail(id: id)) }
                        )
                    case .list:
                        CityListView(
                            viewModel: viewModel,
                            onSelectShop: { id in coordinator.push(.shopDetail(id: id)) }
                        )
                        .refreshable {
                            Task { await viewModel.loadData() }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            ShopFilterView(viewModel: viewModel, isPresented: $showingFilterSheet)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .navigationTitle(viewModel.city?.name ?? "Doppio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.viewMode = viewModel.viewMode == .map ? .list : .map
                } label: {
                    Image(systemName: viewModel.viewMode == .map ? "list.bullet" : "map")
                }
                .tint(theme.tokens.colors.primaryMain)
                .accessibilityLabel(viewModel.viewMode == .map ? "Mudar para Lista" : "Mudar para Mapa")
                .accessibilityIdentifier("city_view_mode_toggle")
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingFilterSheet.toggle() }, label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .padding(.top, 6)
                            .padding(.trailing, 10)
                        if filterBadgeCount > 0 {
                            Text("\(filterBadgeCount)")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(theme.tokens.colors.backgroundPrimary)
                                .padding(.horizontal, 3)
                                .frame(minWidth: 13, minHeight: 13)
                                .background(theme.tokens.colors.primaryMain)
                                .clipShape(Capsule())
                        }
                    }
                })
                .tint(theme.tokens.colors.primaryMain)
                .accessibilityLabel(
                    filterBadgeCount > 0
                        ? "Filtro ativo (\(filterBadgeCount))"
                        : "Filtro"
                )
                .accessibilityHint("Toque para filtrar as cafeterias")
                .accessibilityIdentifier("city_filter_button")
                .id(filterBadgeCount)
            }
        }
        .onAppear {
            filterBadgeCount = viewModel.activeFiltersCount
        }
        .onChange(of: viewModel.activeFiltersCount) { _, newCount in
            filterBadgeCount = newCount
        }
        .task {
            if viewModel.viewLoadState == .preload {
                await viewModel.loadData()
            }
        }
    }
}
