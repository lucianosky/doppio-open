// ShopBaristaCarouselView.swift
// App/View/Shop

import SwiftUI

struct ShopBaristaCarouselView: View {
    let shop: ShopEntity
    var onBaristaTap: ((Int) -> Void)?
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Baristas")
                .font(.caption.weight(.semibold))
                .foregroundColor(theme.tokens.colors.textSecondary)
                .padding(.horizontal, 16)

            if shop.baristas.count == 1, let barista = shop.baristas.first {
                BaristaChipView(barista: barista, theme: theme) {
                    onBaristaTap?(barista.id)
                }
                .padding(.horizontal, 16)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(shop.baristas) { barista in
                            BaristaAvatarView(barista: barista, theme: theme) {
                                onBaristaTap?(barista.id)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.vertical, 8)
        .background(theme.tokens.colors.backgroundCard)
        .cornerRadius(theme.tokens.radius.radiusCard)
    }
}

// MARK: - BaristaAvatarView (carousel item)

private struct BaristaAvatarView: View {
    let barista: BaristaSummaryEntity
    let theme: BrewTheme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                AvatarCircle(barista: barista, theme: theme, size: 52)
                Text(barista.nickname)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(theme.tokens.colors.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 56)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(barista.name)
        .accessibilityHint("Ver perfil do barista")
    }
}

// MARK: - BaristaChipView (single barista)

private struct BaristaChipView: View {
    let barista: BaristaSummaryEntity
    let theme: BrewTheme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                AvatarCircle(barista: barista, theme: theme, size: 40)
                Text(barista.nickname)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.tokens.colors.textPrimary)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(theme.tokens.colors.textSecondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(barista.name)
        .accessibilityHint("Ver perfil do barista")
    }
}

// MARK: - AvatarCircle

private struct AvatarCircle: View {
    let barista: BaristaSummaryEntity
    let theme: BrewTheme
    let size: CGFloat

    var body: some View {
        Group {
            if let asset = barista.thumbnailAsset {
                DoppioAsyncImage(url: asset)
            } else {
                theme.tokens.colors.primaryMain.opacity(0.15)
                    .overlay(
                        Text(String(barista.nickname.prefix(1)).uppercased())
                            .font(.system(size: size * 0.4, weight: .semibold))
                            .foregroundColor(theme.tokens.colors.primaryMain)
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
