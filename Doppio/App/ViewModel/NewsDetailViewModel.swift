// NewsDetailViewModel.swift
// App/ViewModel — Ring 3

import Foundation
import Combine

// MARK: - NewsDetailViewModel

@MainActor
final class NewsDetailViewModel: ObservableObject {

    // MARK: - Dependencies
    private let newsRepository: NewsRepository

    // MARK: - State
    @Published private(set) var viewLoadState: ViewLoadState = .preload
    @Published private(set) var newsItem: NewsEntity?

    // MARK: - Init

    init(newsRepository: NewsRepository) {
        self.newsRepository = newsRepository
    }

    // MARK: - Load

    func loadData(id: Int) async {
        guard viewLoadState != .loading else { return }
        viewLoadState = .loading

        do {
            newsItem = try await newsRepository.fetchDetail(id: id)
            viewLoadState = .content
        } catch {
            viewLoadState = .error(message: error.doppioMessage, canRetry: true)
            logError("NewsDetailViewModel.loadData: \(error)", category: .viewmodel)
        }
    }
}
