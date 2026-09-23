// ShopPhotoViewerView.swift
// App/View/Shop

import SwiftUI

struct ShopPhotoViewerView: View {
    let assets: [String]
    let startIndex: Int
    var onDismiss: () -> Void

    @State private var currentIndex: Int

    init(assets: [String], startIndex: Int, onDismiss: @escaping () -> Void) {
        self.assets = assets
        self.startIndex = startIndex
        self.onDismiss = onDismiss
        _currentIndex = State(initialValue: startIndex)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(assets.enumerated()), id: \.offset) { index, asset in
                    DoppioAsyncImage(url: asset, contentMode: .fit)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
            .accessibilityLabel("Fechar")
        }
    }
}
