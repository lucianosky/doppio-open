// ShopCarrouselView.swift
// App/View/Shop

import SwiftUI

private struct PhotoViewerIndex: Identifiable {
    let value: Int
    var id: Int { value }
}

struct ShopCarrouselView: View {
    let shop: ShopEntity
    @Environment(BrewTheme.self) private var theme

    // Carousel shows all assets except the first (main photo)
    private var carouselAssets: [String] {
        shop.imageAssets.count > 1 ? Array(shop.imageAssets.dropFirst()) : []
    }

    @State private var viewerStartIndex: Int?

    var body: some View {
        if !carouselAssets.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(carouselAssets.enumerated()), id: \.offset) { offset, asset in
                        Button(action: { viewerStartIndex = offset + 1 }, label: {
                            DoppioAsyncImage(url: asset)
                                .frame(width: 160, height: 110)
                                .clipped()
                                .cornerRadius(theme.tokens.radius.radiusCard)
                        })
                        .buttonStyle(.plain)
                        .accessibilityLabel("Foto \(offset + 2) de \(shop.longName)")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .accessibilityElement(children: .contain)
            .fullScreenCover(item: Binding(
                get: { viewerStartIndex.map { PhotoViewerIndex(value: $0) } },
                set: { viewerStartIndex = $0?.value }
            ), content: { target in
                ShopPhotoViewerView(
                    assets: shop.imageAssets,
                    startIndex: target.value,
                    onDismiss: { viewerStartIndex = nil }
                )
            })
        }
    }
}
