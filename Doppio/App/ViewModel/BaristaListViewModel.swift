// BaristaListViewModel.swift
// App/ViewModel — Ring 3

import Foundation
import Combine

// MARK: - BaristaListViewModel

@MainActor
final class BaristaListViewModel: ObservableObject {

    // MARK: - Dependencies
    private let baristaRepository: BaristaRepository

    // MARK: - State
    @Published private(set) var viewLoadState: ViewLoadState = .preload
    @Published private(set) var baristas: [BaristaSummaryEntity] = []

    // MARK: - Init

    init(baristaRepository: BaristaRepository) {
        self.baristaRepository = baristaRepository
    }

    // MARK: - Load

    func loadData() async {
        guard viewLoadState != .loading else { return }
        viewLoadState = .loading

        do {
            try await baristaRepository.fetch()
            baristas = baristaRepository.items
            viewLoadState = .content
        } catch {
            viewLoadState = .error(message: error.doppioMessage, canRetry: true)
            logError("BaristaListViewModel.loadData: \(error)", category: .viewmodel)
        }
    }
}
