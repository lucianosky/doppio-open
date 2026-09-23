// AppState.swift
// App

import Foundation
import Combine

// MARK: - AppState

/// Observable app-level state. Holds the dependency container and session store.
/// Inject via `.environmentObject(appState)` at the app root.
final class AppState: ObservableObject {

    // MARK: - Auth

    let sessionStore: SessionStore

    // MARK: - Container

    let container: AppContainer

    // MARK: - Init

    init() {
        let store = SessionStore()
        self.sessionStore = store
        self.container    = AppContainer(sessionStore: store)
    }
}
