// BaristaDetailContainerView.swift
// App/View/Barista

import SwiftUI

struct BaristaDetailContainerView: View {
    @StateObject private var viewModel: BaristaDetailViewModel
    let id: Int

    init(baristaRepository: BaristaRepository, id: Int) {
        _viewModel = StateObject(wrappedValue: BaristaDetailViewModel(baristaRepository: baristaRepository))
        self.id = id
    }

    var body: some View {
        BaristaDetailView(viewModel: viewModel, id: id)
    }
}
