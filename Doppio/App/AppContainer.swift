// AppContainer.swift
// App

import Foundation
import Kingfisher

// MARK: - AppContainer

/// Dependency injection root for the Doppio app.
///
/// Lazy-initializes all repositories and list-level ViewModels from a single DataSource.
/// V1 always uses MockDataSource (embedded fixtures, no backend).
final class AppContainer {

    // MARK: - Init

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
        configureImageCache()
    }

    // MARK: - Auth

    let sessionStore: SessionStore

    @MainActor lazy var authRepository    = SupabaseAuthRepository(sessionStore: sessionStore)
    @MainActor lazy var loginViewModel    = LoginViewModel(authRepository: authRepository, sessionStore: sessionStore)
              lazy var checkinRepository  = CheckinRepository(sessionStore: sessionStore)

    // MARK: - Environment

    let environment: APIEnvironment = .production(baseURL: SupabaseConfig.restURL)

    // MARK: - Data Source

    private lazy var dataSource: any DataSource = DoppioDataSource.make(environment: environment)

    // MARK: - Repositories

    lazy var cityRepository    = CityRepository(dataSource: dataSource)
    lazy var shopRepository    = ShopRepository(dataSource: dataSource)
    lazy var newsRepository    = NewsRepository(dataSource: dataSource)
    lazy var baristaRepository = BaristaRepository(dataSource: dataSource)

    // MARK: - List ViewModels (owned here, observed by FlowViews)

    @MainActor lazy var cityViewModel = CityViewModel(
        cityRepository: cityRepository,
        shopRepository: shopRepository
    )

    @MainActor lazy var newsListViewModel = NewsListViewModel(newsRepository: newsRepository)
    @MainActor lazy var baristaListViewModel = BaristaListViewModel(baristaRepository: baristaRepository)

    // MARK: - Private

    private func configureImageCache() {
        let cache = ImageCache.default
        cache.diskStorage.config.sizeLimit = 200 * 1024 * 1024  // 200 MB
        cache.diskStorage.config.expiration = .days(30)
    }
}
