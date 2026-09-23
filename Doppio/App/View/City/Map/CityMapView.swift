// CityMapView.swift
// App/View/City/Map

import SwiftUI

struct CityMapView: View {
    @ObservedObject var cityViewModel: CityViewModel
    let onSelectShop: (Int) -> Void

    @State private var selectedShopId: Int?
    @State private var sameLocationCandidates: [ShopMapCandidate]?

    var body: some View {
        UIMapView(
            city: cityViewModel.city,
            filteredShops: cityViewModel.filteredShops,
            selectedShopId: Binding(
                get: { selectedShopId },
                set: {
                    selectedShopId = $0
                    if let id = $0 {
                        onSelectShop(id)
                    }
                }
            ),
            sameLocationCandidates: Binding(
                get: { sameLocationCandidates },
                set: { sameLocationCandidates = $0 }
            )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Mapa navegável")
        .accessibilityHint("Selecione o botão lista para listar as cafeterias")
        .accessibilityAddTraits(.isImage)
        .sheet(isPresented: Binding(
            get: { sameLocationCandidates != nil },
            set: { if !$0 { sameLocationCandidates = nil } }
        ), content: {
            if let candidates = sameLocationCandidates {
                ShopSelectionView(
                    candidates: candidates,
                    onSelect: { candidate in
                        sameLocationCandidates = nil
                        onSelectShop(candidate.id)
                    },
                    isPresented: Binding(
                        get: { sameLocationCandidates != nil },
                        set: { if !$0 { sameLocationCandidates = nil } }
                    )
                )
            }
        })
    }
}

private struct ShopSelectionView: View {
    let candidates: [ShopMapCandidate]
    let onSelect: (ShopMapCandidate) -> Void
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            List(candidates) { candidate in
                Button(action: {
                    onSelect(candidate)
                    isPresented = false
                }, label: {
                    Text(candidate.name)
                        .padding(.vertical, 8)
                })
            }
            .navigationTitle("Escolha a cafeteria")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
