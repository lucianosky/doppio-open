// ShopMainPhotoView.swift
// App/View/Shop

import SwiftUI

struct ShopMainPhotoView: View {
    let shop: ShopEntity
    @Environment(BrewTheme.self) private var theme
    @State private var viewerOpen = false

    var body: some View {
        if shop.imageAssets.first != nil {
            Button(action: { viewerOpen = true }, label: {
                DoppioAsyncImage(url: shop.imageAssets[0])
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .clipped()
                    .cornerRadius(theme.tokens.radius.radiusCard)
            })
            .buttonStyle(.plain)
            .accessibilityLabel("Foto principal de \(shop.longName)")
            .fullScreenCover(isPresented: $viewerOpen) {
                ShopPhotoViewerView(
                    assets: shop.imageAssets,
                    startIndex: 0,
                    onDismiss: { viewerOpen = false }
                )
            }
        }
    }
}
