// UseCase.swift
// Brew/UseCase
//
// Base protocol for all UseCases in the Brew architecture.
//
// UseCases mediate between ViewModels and one or more Repositories
// when there is business logic or orchestration involved.
//
// When to use a UseCase vs calling a Repository directly:
//   - Business logic, multiple repositories, billing → UseCase
//   - Pure data fetch for display, single repository → Repository directly
//
// Current UseCases in Raipe (defined in App/UseCase/):
//   - AppBootstrapUseCase  — app init, feature flags, session restore
//   - PlaybackAccessUseCase — evaluates 6 access states, decides paywall
//   - PurchaseUseCase      — StoreKit 2 / Pix, wallet update after purchase
//   - CreditSyncUseCase    — credit balance sync on login, purchase, foreground
//
// Usage:
//
//   final class PlaybackAccessUseCase: UseCase {
//
//       private let playbackRepository: PlaybackRepository
//       private let walletRepository: WalletRepository
//
//       init(playbackRepository: PlaybackRepository,
//            walletRepository: WalletRepository) {
//           self.playbackRepository = playbackRepository
//           self.walletRepository = walletRepository
//       }
//
//       func evaluate(episodeId: String) async throws -> EpisodeAccess {
//           let access = try await playbackRepository.fetchPlayer(episodeId: episodeId)
//           if !access.allowed {
//               let wallet = try await walletRepository.fetchWallet()
//               // apply business rules using both access + wallet
//           }
//           return access
//       }
//   }

import Foundation

// MARK: - UseCase

/// Base protocol for all UseCases in the Brew architecture.
///
/// UseCases encapsulate business logic that involves orchestrating
/// multiple repositories or applying domain rules before returning
/// a result to the ViewModel.
///
/// Rules:
/// - UseCases receive repositories via `init` — never instantiate them internally.
/// - UseCases never touch UI — no `@Published`, no `@MainActor`.
/// - UseCases return results to ViewModels — never call back into ViewModels.
/// - UseCases never call other UseCases.
/// - One UseCase per business operation — keep them focused and testable.
public protocol UseCase {
    // Marker protocol.
    // Concrete UseCases define their own async methods with domain-specific signatures.
    // No shared interface is enforced here — the protocol exists for documentation,
    // discoverability, and future tooling (e.g. automated audits, sub-agent filters).
}
