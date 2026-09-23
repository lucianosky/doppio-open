// ViewLoadState.swift
// Brew/Shared
//
// Represents the async loading lifecycle of any screen that fetches data.
// All ViewModels that load async data must use this enum.

/// The four states of an asynchronous UI load cycle.
///
/// Usage in a ViewModel:
/// ```swift
/// @Published var viewLoadState: ViewLoadState = .preload
/// ```
///
/// Usage in a View:
/// ```swift
/// switch viewModel.viewLoadState {
/// case .preload, .loading:
///     LoadingView()
/// case .content:
///     ContentView()
/// case .error(let message, let canRetry):
///     ErrorView(message: message, canRetry: canRetry) {
///         Task { await viewModel.loadData() }
///     }
/// }
/// ```
public enum ViewLoadState: Equatable {

    // MARK: - Cases

    /// Initial state before any load has been triggered.
    case preload

    /// A load is currently in progress.
    case loading

    /// Data has been loaded successfully and is ready to display.
    case content

    /// The load failed.
    ///
    /// - Parameters:
    ///   - message: A human-readable description of the failure, suitable for display.
    ///   - canRetry: Whether the UI should offer a retry action to the user.
    case error(message: String, canRetry: Bool)

    // MARK: - Helpers

    /// Returns `true` while a load is in progress.
    public var isLoading: Bool { self == .loading }

    /// Returns `true` when data is ready to display.
    public var isContent: Bool { self == .content }
}
