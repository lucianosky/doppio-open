// BaristaDetailViewModel.swift
// App/ViewModel — Ring 3

import Foundation
import Combine

// MARK: - BaristaDetailViewModel

@MainActor
final class BaristaDetailViewModel: ObservableObject {

    // MARK: - Dependencies
    private let baristaRepository: BaristaRepository

    // MARK: - State
    @Published private(set) var viewLoadState: ViewLoadState = .preload
    @Published private(set) var barista: BaristaEntity?

    // MARK: - Init

    init(baristaRepository: BaristaRepository) {
        self.baristaRepository = baristaRepository
    }

    // MARK: - Load

    func loadData(id: Int) async {
        guard viewLoadState != .loading else { return }
        viewLoadState = .loading

        do {
            barista = try await baristaRepository.fetchDetail(id: id)
            viewLoadState = .content
        } catch {
            viewLoadState = .error(message: error.doppioMessage, canRetry: true)
            logError("BaristaDetailViewModel.loadData: \(error)", category: .viewmodel)
        }
    }
}
