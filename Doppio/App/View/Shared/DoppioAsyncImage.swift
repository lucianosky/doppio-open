// DoppioAsyncImage.swift
// App/View/Shared
//
// Async image with Kingfisher — drop-in for Image(assetName).
// Takes a URL string, decodes with cache, fades in.
// Returns Color.clear for nil/invalid URLs — callers keep their own fallback.

import SwiftUI
import Kingfisher

// MARK: - DoppioAsyncImage

struct DoppioAsyncImage: View {
    let url: String?
    var contentMode: SwiftUI.ContentMode = .fill
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        if let urlString = url, let resolved = URL(string: urlString) {
            KFImage(resolved)
                .placeholder {
                    theme.tokens.colors.backgroundSecondary
                        .overlay(
                            ProgressView()
                                .tint(theme.tokens.colors.textSecondary)
                        )
                }
                .fade(duration: 0.2)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            Color.clear
        }
    }
}
