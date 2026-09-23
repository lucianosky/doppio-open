// ShopFilterView.swift
// App/View/City

import SwiftUI

// Color mapping for social tags (view-layer display info)
private func socialTagColor(_ id: SocialTagID) -> Color {
    switch id {
    case .lgbtq:         return Color(hex: "#FF6B35")
    case .womenOwned:    return Color(hex: "#9B59B6")
    case .womenOnly:     return Color(hex: "#8E44AD")
    case .transSafe:     return Color(hex: "#55A3D5")
    case .genderNeutral: return Color(hex: "#5D6D7E")
    }
}

struct ShopFilterView: View {
    @ObservedObject var viewModel: CityViewModel
    @Binding var isPresented: Bool
    @Environment(BrewTheme.self) private var theme

    @State private var localSelectedDistricts: [String] = []
    @State private var localFilterOpenNow: Bool = false
    @State private var localSelectedTags: Set<String> = []
    @State private var localSort: CitySort = .alphabetical

    private var hasActiveFilters: Bool {
        !localSelectedDistricts.isEmpty || localFilterOpenNow || !localSelectedTags.isEmpty
    }

    private var hasChanges: Bool {
        Set(localSelectedDistricts) != Set(viewModel.selectedDistricts) ||
        localFilterOpenNow != viewModel.filterOpenNow ||
        localSelectedTags != viewModel.selectedTags ||
        localSort != viewModel.sort
    }

    private var previewCount: Int {
        var base = localSelectedDistricts.isEmpty || localSelectedDistricts.count == viewModel.districts.count
            ? viewModel.allShops
            : viewModel.allShops.filter { shop in
                shop.branches.contains { localSelectedDistricts.contains($0.address.district) }
            }
        if localFilterOpenNow {
            base = base.filter { shop in
                shop.branches.contains { OpeningHoursParser.isOpenNow(hours: $0.openingHours) == true }
            }
        }
        if !localSelectedTags.isEmpty {
            base = base.filter { shop in
                let normalized = Set(shop.tags.compactMap { TagNormalizer.normalize($0) })
                return !localSelectedTags.isDisjoint(with: normalized)
            }
        }
        return base.count
    }

    private var previewDistrictsLabel: String {
        let selection = localSelectedDistricts
        if selection.isEmpty || selection.count == viewModel.districts.count { return "Todos" }
        return selection.sorted().joined(separator: ", ")
    }

    var body: some View {
        NavigationStack {
            Form {
                // Ordenar
                Section(header: Text("Ordenar")) {
                    Picker("Ordenação", selection: $localSort) {
                        ForEach(CitySort.allCases, id: \.self) { sort in
                            Text(sort.title).tag(sort)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Aberto agora + preview count
                Section(footer: Text(previewCount == 0 ? "Nenhuma cafeteria encontrada" : "\(previewCount) cafeterias")
                    .foregroundColor(previewCount == 0
                        ? theme.tokens.colors.errorMain
                        : theme.tokens.colors.textSecondary)
                ) {
                    Toggle("Aberto agora", isOn: $localFilterOpenNow)
                        .tint(theme.tokens.colors.primaryMain)
                }

                // Bairros
                Section(footer: Text(previewDistrictsLabel)) {
                    NavigationLink {
                        SelectDistrictView(
                            allDistricts: viewModel.districts,
                            selectedDistricts: $localSelectedDistricts
                        )
                    } label: {
                        Text("Bairros")
                    }
                }

                // Tags sociais — topo da seção de tags
                let socialIDs = viewModel.availableSocialTagIDs
                if !socialIDs.isEmpty {
                    Section(header: Text("Inclusão & Diversidade")) {
                        FlowLayout(spacing: 6) {
                            ForEach(socialIDs, id: \.self) { socialID in
                                let color = socialTagColor(socialID)
                                let isSelected = localSelectedTags.contains(socialID.rawValue)
                                Button {
                                    if isSelected {
                                        localSelectedTags.remove(socialID.rawValue)
                                    } else {
                                        localSelectedTags.insert(socialID.rawValue); ()
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "heart.fill")
                                            .font(.caption2)
                                        Text(socialID.rawValue)
                                            .font(.caption.weight(.semibold))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(isSelected ? color : color.opacity(0.15))
                                    .foregroundColor(isSelected ? Color.white : color)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(color.opacity(isSelected ? 0 : 0.5), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Tags por categoria com toggle de categoria
                if !viewModel.availableTags.isEmpty {
                    Section(header: Text("Filtrar por tag")) {
                        ForEach(viewModel.availableTags, id: \.category) { item in
                            tagCategoryRow(item.category, tags: item.tags)
                        }
                    }
                }
            }
            .interactiveDismissDisabled(hasChanges)
            .scrollContentBackground(.hidden)
            .background(theme.tokens.colors.backgroundPrimary)
            .navigationTitle("Filtrar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Limpar") {
                        localSelectedDistricts = []
                        localFilterOpenNow = false
                        localSelectedTags = []
                    }
                    .foregroundColor(theme.tokens.colors.primaryMain)
                    .disabled(!hasActiveFilters)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Aplicar") {
                        viewModel.applyFilters(
                            districts: localSelectedDistricts,
                            openNow: localFilterOpenNow,
                            tags: localSelectedTags,
                            sort: localSort
                        )
                        isPresented = false
                    }
                    .foregroundColor(theme.tokens.colors.primaryMain)
                }
            }
        }
        .background(theme.tokens.colors.backgroundPrimary.ignoresSafeArea())
        .onAppear {
            localSelectedDistricts = viewModel.selectedDistricts
            localFilterOpenNow = viewModel.filterOpenNow
            localSelectedTags = viewModel.selectedTags
            localSort = viewModel.sort
        }
    }

    // MARK: - Tag category row

    // swiftlint:disable:next function_body_length
    private func tagCategoryRow(_ category: ShopTagCategory, tags: [String]) -> some View {
        let allSelected = tags.allSatisfy { localSelectedTags.contains($0) }

        return VStack(alignment: .leading, spacing: 8) {
            // Category header — toque seleciona/deseleciona todos
            Button {
                if allSelected {
                    tags.forEach { localSelectedTags.remove($0) }
                } else {
                    tags.forEach { localSelectedTags.insert($0); () }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: category.icon)
                        .font(.caption)
                        .foregroundColor(allSelected
                            ? theme.tokens.colors.primaryMain
                            : theme.tokens.colors.successMain)
                    Text(category.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(allSelected
                            ? theme.tokens.colors.primaryMain
                            : theme.tokens.colors.textSecondary)
                    Spacer()
                    if allSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(theme.tokens.colors.primaryMain)
                    }
                }
            }
            .buttonStyle(.plain)

            // Tag chips
            FlowLayout(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    let isSelected = localSelectedTags.contains(tag)
                    Button {
                        if isSelected {
                            localSelectedTags.remove(tag)
                        } else {
                            localSelectedTags.insert(tag); ()
                        }
                    } label: {
                        Text(tag)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(isSelected
                                ? theme.tokens.colors.primaryMain
                                : theme.tokens.colors.primaryMain.opacity(0.12))
                            .foregroundColor(isSelected
                                ? theme.tokens.colors.textOnDark
                                : theme.tokens.colors.primaryMain)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(theme.tokens.colors.primaryMain.opacity(isSelected ? 0 : 0.4), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
