// MainCoordinator.swift
// App/Coordinator

import SwiftUI
import Combine

// MARK: - MainTab

enum MainTab: Hashable {
    case city
    case news
    case barista
}

// MARK: - MainCoordinator

@MainActor
final class MainCoordinator: ObservableObject {
    @Published var selectedTab: MainTab = .city
}
