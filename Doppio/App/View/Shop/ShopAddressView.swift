// ShopAddressView.swift
// App/View/Shop

import SwiftUI

struct ShopAddressView: View {
    let shop: ShopEntity
    let branch: BranchEntity
    let fullAddress: String
    @Environment(BrewTheme.self) private var theme
    @State private var plusCodeCopied = false

    var body: some View {
        HStack {
            Group {
                if let asset = shop.logoAsset {
                    DoppioAsyncImage(url: asset)
                } else {
                    theme.tokens.colors.textSecondary.opacity(0.3)
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: theme.tokens.radius.radiusCard))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(shop.longName)
                        .font(.body.bold())
                        .foregroundColor(theme.tokens.colors.textPrimary)
                    if let price = branch.priceRange {
                        Text(price)
                            .font(.caption.weight(.medium))
                            .foregroundColor(theme.tokens.colors.textSecondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(theme.tokens.colors.backgroundSecondary)
                            .cornerRadius(6)
                    }
                }

                Text(fullAddress)
                    .font(.caption)
                    .foregroundColor(theme.tokens.colors.textSecondary)

                HStack(spacing: 4) {
                    Text(branch.address.district)
                        .font(.caption)
                        .foregroundColor(theme.tokens.colors.textSecondary)
                    if let plusCode = branch.plusCode {
                        Button {
                            UIPasteboard.general.string = plusCode
                            plusCodeCopied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                plusCodeCopied = false
                            }
                        } label: {
                            Image(systemName: plusCodeCopied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 10))
                                .foregroundColor(plusCodeCopied ? .green : theme.tokens.colors.textSecondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(plusCodeCopied ? "Plus Code copiado" : "Copiar Plus Code \(plusCode)")
                    }
                }
            }
            .padding(.leading, 10)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(shop.longName). \(fullAddress). \(branch.address.district).")

            Spacer()
        }
        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 10))
        .background(theme.tokens.colors.backgroundCard)
        .cornerRadius(theme.tokens.radius.radiusCard)
        .accessibilityIdentifier("shop_address_view")
    }
}
