// ShopDetailContainerView.swift
// App/View/Shop

import SwiftUI

struct ShopDetailContainerView: View {
    @StateObject private var viewModel: ShopDetailViewModel
    let id: Int

    init(shopRepository: ShopRepository, id: Int) {
        _viewModel = StateObject(wrappedValue: ShopDetailViewModel(shopRepository: shopRepository))
        self.id = id
    }

    var body: some View {
        ShopDetailView(viewModel: viewModel, id: id)
    }
}
