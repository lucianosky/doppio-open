// CityListView.swift
// App/View/City

import SwiftUI

struct CityListView: View {
    @ObservedObject var viewModel: CityViewModel
    let onSelectShop: (Int) -> Void
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        Group {
            if viewModel.filteredShops.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "cup.and.saucer")
                        .font(.system(size: 40))
                        .foregroundColor(theme.tokens.colors.textSecondary)
                    Text("Nenhuma cafeteria encontrada")
                        .font(.subheadline)
                        .foregroundColor(theme.tokens.colors.textSecondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(viewModel.filteredShops) { shop in
                        Button(action: {
                            onSelectShop(shop.id)
                        }, label: {
                            ShopCellView(shop: shop)
                                .frame(maxWidth: .infinity)
                        })
                        .buttonStyle(.plain)
                        .listRowBackground(theme.tokens.colors.backgroundPrimary)
                        .listRowInsets(EdgeInsets(top: 2, leading: 5, bottom: 5, trailing: 10))
                        .listRowSeparator(.hidden)
                        .accessibilityIdentifier("shop_cell_\(shop.id)")
                    }
                }
                .background(theme.tokens.colors.backgroundPrimary)
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Buscar cafeteria")
    }
}

struct ShopCellView: View {
    let shop: ShopEntity
    @Environment(BrewTheme.self) private var theme

    private var primaryBranch: BranchEntity? { shop.primaryBranch }

    // Open if any branch is open.
    private var isOpen: Bool? {
        let results = shop.branches.compactMap { OpeningHoursParser.isOpenNow(hours: $0.openingHours) }
        guard !results.isEmpty else { return nil }
        return results.contains(true)
    }

    // Closing soon if any open branch closes within 60 min.
    private var isClosingSoon: Bool {
        shop.branches.contains { OpeningHoursParser.isClosingSoon(hours: $0.openingHours) }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Group {
                if let asset = shop.logoAsset {
                    DoppioAsyncImage(url: asset, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: theme.tokens.radius.radiusChip))
                        .padding(6)
                } else {
                    Image(systemName: "cup.and.saucer")
                        .font(.system(size: 28))
                        .foregroundColor(theme.tokens.colors.textSecondary)
                }
            }
            .frame(width: 80, height: 80)
            .background(theme.tokens.colors.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: theme.tokens.radius.radiusCard))
            .padding(.trailing, 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(shop.longName)
                    .font(Font.system(.body).bold())
                    .foregroundColor(theme.tokens.colors.textPrimary)
                Text(primaryBranch?.address.street ?? "")
                    .font(Font.system(.caption))
                    .foregroundColor(theme.tokens.colors.textSecondary)
                Text(primaryBranch?.address.district ?? "")
                    .font(Font.system(.caption))
                    .foregroundColor(theme.tokens.colors.textSecondary)

                if let open = isOpen {
                    let closingSoon = open && isClosingSoon
                    Text(closingSoon ? "Fecha em breve" : (open ? "Aberto" : "Fechado"))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(open ? theme.tokens.colors.backgroundPrimary : theme.tokens.colors.textPrimary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            closingSoon ? theme.tokens.colors.warningMain
                                : open ? theme.tokens.colors.successMain
                                : theme.tokens.colors.errorMain
                        )
                        .cornerRadius(6)
                        .padding(.top, 2)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(theme.tokens.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(theme.tokens.colors.backgroundCard)
        .cornerRadius(theme.tokens.radius.radiusCard)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(shop.longName). \(primaryBranch?.address.street ?? ""). \(primaryBranch?.address.district ?? "")."
        )
        .accessibilityHint("Toque para ver os detalhes da cafeteria.")
        .accessibilityAddTraits(.isButton)
    }
}
