// ShopDetailViewModel.swift
// App/ViewModel — Ring 3

import Foundation
import Combine

// MARK: - ShopDetailViewModel

@MainActor
final class ShopDetailViewModel: ObservableObject {

    // MARK: - Dependencies
    private let shopRepository: ShopRepository

    // MARK: - State
    @Published private(set) var viewLoadState: ViewLoadState = .preload
    @Published private(set) var shop: ShopEntity?
    @Published private(set) var selectedBranch: BranchEntity?

    // MARK: - Computed Properties (for View rendering)

    var hasCarrouselView: Bool { !(shop?.imageAssets.isEmpty ?? true) }
    var hasScheduleView: Bool { selectedBranch?.openingHours != nil }
    var hasTagsView: Bool { !(shop?.tags.isEmpty ?? true) }
    var hasCoffeeView: Bool {
        guard let shop = shop else { return false }
        return shop.coffee?.machine != nil
            || !(shop.coffee?.methods.isEmpty ?? true)
            || !(shop.coffee?.beans.isEmpty ?? true)
            || !shop.baristas.isEmpty
            || shop.openingDate != nil
    }

    /// Formatted address string for display.
    var fullAddress: String {
        guard let addr = selectedBranch?.address else { return "" }
        var parts = [addr.street]
        if let number = addr.number { parts.append(number) }
        if let complement = addr.complement { parts.append(complement) }
        return parts.joined(separator: ", ")
    }

    // MARK: - Init

    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }

    // MARK: - Load

    func loadData(id: Int) async {
        guard viewLoadState != .loading else { return }
        viewLoadState = .loading

        do {
            let fetched = try await shopRepository.fetchDetail(id: id)
            shop = fetched
            selectedBranch = fetched.primaryBranch
            viewLoadState = .content
        } catch {
            viewLoadState = .error(message: error.doppioMessage, canRetry: true)
            logError("ShopDetailViewModel.loadData: \(error)", category: .viewmodel)
        }
    }

    // MARK: - Branch Selection

    func selectBranch(_ branch: BranchEntity) {
        selectedBranch = branch
    }
}
