// MainView.swift
// App/View/Main

import SwiftUI

private enum AppTab: Int, CaseIterable {
    case home, city, barista
}

struct MainView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(BrewTheme.self) private var theme
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content — TabView with system tab bar hidden
            TabView(selection: $selectedTab) {
                HomeFlowView(viewModel: appState.container.newsListViewModel)
                    .tag(AppTab.home)
                    .accessibilityIdentifier("tab_home")

                CityFlowView(viewModel: appState.container.cityViewModel)
                    .tag(AppTab.city)
                    .accessibilityIdentifier("tab_city")

                BaristaFlowView(viewModel: appState.container.baristaListViewModel)
                    .tag(AppTab.barista)
                    .accessibilityIdentifier("tab_barista")

            }
            .toolbar(.hidden, for: .tabBar)

            // Floating pill tab bar
            FloatingTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - FloatingTabBar

private struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        HStack(spacing: 0) {
            TabPill(
                tab: .home,
                selectedTab: $selectedTab,
                iconName: "house.fill",
                isCustom: false,
                label: "Home"
            )
            TabPill(
                tab: .city,
                selectedTab: $selectedTab,
                iconName: "icon-cup",
                isCustom: true,
                label: "Cafés"
            )
            TabPill(
                tab: .barista,
                selectedTab: $selectedTab,
                iconName: "person",
                isCustom: false,
                label: "Baristas"
            )
        }
        .frame(height: 60)
        .background(theme.tokens.colors.backgroundSecondary)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 8)
    }
}

// MARK: - TabPill

private struct TabPill: View {
    let tab: AppTab
    @Binding var selectedTab: AppTab
    let iconName: String
    let isCustom: Bool
    let label: String
    @Environment(BrewTheme.self) private var theme

    private var isActive: Bool { selectedTab == tab }
    private var color: Color {
        isActive ? theme.tokens.colors.primaryMain : theme.tokens.colors.textSecondary
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        }, label: {
            VStack(spacing: 2) {
                if isCustom {
                    Image(iconName)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(color)
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.system(size: 10, weight: isActive ? .bold : .semibold))
                    .dynamicTypeSize(.small ... .accessibility1)
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        })
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
    }
}
