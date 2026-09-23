// NewsDetailContainerView.swift
// App/View/News

import SwiftUI

struct NewsDetailContainerView: View {
    @StateObject private var viewModel: NewsDetailViewModel
    let id: Int

    init(newsRepository: NewsRepository, id: Int) {
        _viewModel = StateObject(wrappedValue: NewsDetailViewModel(newsRepository: newsRepository))
        self.id = id
    }

    var body: some View {
        NewsDetailView(viewModel: viewModel, id: id)
    }
}
