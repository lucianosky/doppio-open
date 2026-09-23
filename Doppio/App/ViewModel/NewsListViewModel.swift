// NewsListViewModel.swift
// App/ViewModel — Ring 3

import Foundation
import Combine

// MARK: - NewsListViewModel

@MainActor
final class NewsListViewModel: ObservableObject {

    // MARK: - Dependencies
    private let newsRepository: NewsRepository

    // MARK: - State
    @Published private(set) var viewLoadState: ViewLoadState = .preload
    @Published private(set) var news: [NewsListItemEntity] = []

    // MARK: - Init

    init(newsRepository: NewsRepository) {
        self.newsRepository = newsRepository
    }

    // MARK: - Load

    func loadData() async {
        guard viewLoadState != .loading else { return }
        viewLoadState = .loading

        do {
            try await newsRepository.fetch()
            news = newsRepository.items
            viewLoadState = .content
        } catch {
            viewLoadState = .error(message: error.doppioMessage, canRetry: true)
            logError("NewsListViewModel.loadData: \(error)", category: .viewmodel)
        }
    }
}
