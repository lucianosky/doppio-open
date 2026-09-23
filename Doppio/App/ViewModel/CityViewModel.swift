// CityViewModel.swift
// App/ViewModel — Ring 3

import CoreLocation
import Foundation
import Combine

// MARK: - CityViewMode

enum CityViewMode: String, CaseIterable, Identifiable {
    case map  = "Mapa"
    case list = "Lista"

    var id: String { rawValue }
}

// MARK: - CitySort

enum CitySort: CaseIterable {
    case alphabetical
    case distance

    var title: String {
        switch self {
        case .alphabetical: return "Alfabética"
        case .distance:     return "Distância"
        }
    }

    var toggled: CitySort {
        self == .alphabetical ? .distance : .alphabetical
    }
}

// MARK: - CityViewModel

@MainActor
final class CityViewModel: ObservableObject {

    // MARK: - Dependencies
    private let cityRepository: CityRepository
    private let shopRepository: ShopRepository
    let locationService: LocationService

    // MARK: - State
    @Published private(set) var viewLoadState: ViewLoadState = .preload
    @Published private(set) var city: CityEntity?
    @Published var allShops: [ShopEntity] = []
    @Published var viewMode: CityViewMode = .map
    @Published var sort: CitySort = .alphabetical
    @Published var districts: [String] = []
    @Published var selectedDistricts: [String] = []
    @Published var filterOpenNow: Bool = false
    @Published var selectedTags: Set<String> = []
    @Published var searchText: String = ""
    @Published private(set) var activeFiltersCount: Int = 0

    // MARK: - Computed

    var filteredShops: [ShopEntity] {
        var base = selectedDistricts.isEmpty || selectedDistricts.count == districts.count
            ? allShops
            : allShops.filter { shop in
                shop.branches.contains { selectedDistricts.contains($0.address.district) }
            }
        if filterOpenNow {
            base = base.filter { shop in
                shop.branches.contains { OpeningHoursParser.isOpenNow(hours: $0.openingHours) == true }
            }
        }
        if !selectedTags.isEmpty {
            base = base.filter { shop in
                let normalized = Set(shop.tags.compactMap { TagNormalizer.normalize($0) })
                return !selectedTags.isDisjoint(with: normalized)
            }
        }
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            base = base.filter { shop in
                shop.longName.lowercased().contains(query) ||
                shop.branches.contains { $0.address.district.lowercased().contains(query) }
            }
        }
        switch sort {
        case .alphabetical:
            return base.sorted { $0.longName < $1.longName }
        case .distance:
            guard let userLocation = locationService.currentLocation else {
                return base.sorted { $0.longName < $1.longName }
            }
            return base.sorted {
                let latA = $0.primaryBranch?.address.latitude ?? 0
                let lngA = $0.primaryBranch?.address.longitude ?? 0
                let latB = $1.primaryBranch?.address.latitude ?? 0
                let lngB = $1.primaryBranch?.address.longitude ?? 0
                let locA = CLLocation(latitude: latA, longitude: lngA)
                let locB = CLLocation(latitude: latB, longitude: lngB)
                return locA.distance(from: userLocation) < locB.distance(from: userLocation)
            }
        }
    }

    var selectedDistrictsLabel: String {
        selectedDistricts.isEmpty || selectedDistricts.count == districts.count
            ? "Todos"
            : selectedDistricts.joined(separator: ", ")
    }

    var availableSocialTagIDs: [SocialTagID] {
        var found: [SocialTagID] = []
        for shop in allShops {
            for raw in shop.tags {
                guard let normalized = TagNormalizer.normalize(raw),
                      let socialID = SocialTagID.find(normalized),
                      !found.contains(socialID) else { continue }
                found.append(socialID)
            }
        }
        return SocialTagID.allCases.filter { found.contains($0) }
    }

    var availableTags: [(category: ShopTagCategory, tags: [String])] {
        var map: [ShopTagCategory: Set<String>] = [:]
        for shop in allShops {
            for raw in shop.tags {
                guard let normalized = TagNormalizer.normalize(raw),
                      let cat = ShopTagCategory.category(for: normalized) else { continue }
                map[cat, default: []].insert(normalized)
            }
        }
        return ShopTagCategory.allCases.compactMap { cat in
            guard let tags = map[cat], !tags.isEmpty else { return nil }
            return (cat, tags.sorted())
        }
    }

    // MARK: - Init

    init(
        cityRepository: CityRepository,
        shopRepository: ShopRepository,
        locationService: LocationService = LocationService()
    ) {
        self.cityRepository = cityRepository
        self.shopRepository = shopRepository
        self.locationService = locationService
    }

    // MARK: - Load

    func loadData() async {
        guard viewLoadState != .loading else { return }
        viewLoadState = .loading

        do {
            async let cityFetch: () = cityRepository.fetch()
            async let shopFetch: () = shopRepository.fetch()
            _ = try await (cityFetch, shopFetch)

            city = cityRepository.items.first
            allShops = shopRepository.items
            districts = Array(Set(allShops.flatMap { $0.branches.map { $0.address.district } })).sorted()
            viewLoadState = .content
        } catch {
            viewLoadState = .error(message: error.doppioMessage, canRetry: true)
            logError("CityViewModel.loadData: \(error)", category: .viewmodel)
        }
    }

    // MARK: - Actions

    func applyFilters(districts newDistricts: [String], openNow: Bool, tags: Set<String>, sort newSort: CitySort) {
        selectedDistricts = newDistricts.sorted()
        filterOpenNow = openNow
        selectedTags = tags
        sort = newSort
        if newSort == .distance {
            locationService.requestAuthorization()
        }
        recalculateFilterCount()
    }

    // MARK: - Private

    private func recalculateFilterCount() {
        let districtFilter = (!selectedDistricts.isEmpty && selectedDistricts.count != districts.count) ? 1 : 0
        let openNowFilter = filterOpenNow ? 1 : 0
        let tagFilter = selectedTags.isEmpty ? 0 : 1
        activeFiltersCount = districtFilter + openNowFilter + tagFilter
    }
}
