// CheckinViewModel.swift
// App/ViewModel

import Foundation
import Combine

// MARK: - CheckinViewModel

@MainActor
final class CheckinViewModel: ObservableObject {

    // MARK: - Form State

    @Published var isFirstVisit: Bool?
    @Published var groupSize: CheckinGroupSize = .solo
    @Published var billAmountText = "" {
        didSet {
            guard !billAmountText.isEmpty else { billAmountError = nil; return }
            let normalized = billAmountText.replacingOccurrences(of: ",", with: ".")
            billAmountError = Decimal(string: normalized) == nil ? "Use apenas números e vírgula (ex: 15,90)" : nil
        }
    }
    @Published var billAmountError: String?
    @Published var note = "" {
        didSet { if note.count > 140 { note = String(note.prefix(140)) } }
    }

    // MARK: - UI State

    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?

    /// Id of the created check-in record. Set after a successful submit.
    /// Passed to RatingView so the rating can be linked to this visit.
    @Published private(set) var checkinId: Int?

    // MARK: - Context

    let shopId: Int
    let branchId: Int?
    let shopName: String
    let district: String

    // MARK: - Dependencies

    private let repository: CheckinRepository

    // MARK: - Init

    init(repository: CheckinRepository, shopId: Int, branchId: Int?, shopName: String, district: String) {
        self.repository = repository
        self.shopId     = shopId
        self.branchId   = branchId
        self.shopName   = shopName
        self.district   = district
    }

    // MARK: - Actions

    func submit() async {
        isLoading    = true
        errorMessage = nil
        defer { isLoading = false }

        let amount: Decimal? = {
            let normalized = billAmountText.replacingOccurrences(of: ",", with: ".")
            return Decimal(string: normalized)
        }()

        do {
            checkinId = try await repository.submitCheckin(
                shopId: shopId,
                branchId: branchId,
                isFirstVisit: isFirstVisit,
                companion: groupSize.rawValue,
                billAmount: amount,
                comment: note.isEmpty ? nil : note
            )
            isSuccess = true
        } catch let error as CheckinError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Não foi possível registrar o check-in. Tente novamente."
        }
    }

    func reset() {
        isFirstVisit    = nil
        groupSize       = .solo
        billAmountText  = ""
        note            = ""
        isSuccess       = false
        errorMessage    = nil
    }
}
