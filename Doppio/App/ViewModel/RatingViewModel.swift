// RatingViewModel.swift
// App/ViewModel

import Foundation
import Combine

// MARK: - RatingViewModel

@MainActor
final class RatingViewModel: ObservableObject {

    // MARK: - Form State

    @Published var rating  = 0
    @Published var comment = "" {
        didSet { if comment.count > 240 { comment = String(comment.prefix(240)) } }
    }

    // MARK: - UI State

    @Published var isLoading    = false
    @Published var isSuccess    = false
    @Published var errorMessage: String?

    // MARK: - Context

    let shopId: Int
    let branchId: Int?
    let shopName: String
    let checkinId: Int?

    // MARK: - Dependencies

    private let repository: CheckinRepository

    // MARK: - Init

    init(repository: CheckinRepository, shopId: Int, branchId: Int?, shopName: String, checkinId: Int? = nil) {
        self.repository = repository
        self.shopId     = shopId
        self.branchId   = branchId
        self.shopName   = shopName
        self.checkinId  = checkinId
    }

    // MARK: - Validation

    var canSubmit: Bool { rating > 0 }

    // MARK: - Actions

    func submit() async {
        guard canSubmit else { return }
        isLoading    = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await repository.submitRating(
                shopId: shopId,
                branchId: branchId,
                rating: rating,
                comment: comment.isEmpty ? nil : comment,
                checkinId: checkinId
            )
            isSuccess = true
        } catch let error as CheckinError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Não foi possível enviar a avaliação. Tente novamente."
        }
    }
}
