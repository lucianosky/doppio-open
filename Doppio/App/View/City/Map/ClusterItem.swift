// ClusterItem.swift
// App/View/City/Map

import CoreLocation
import GoogleMapsUtils

// MARK: - ShopMapCandidate

struct ShopMapCandidate: Identifiable {
    let id: Int
    let name: String
}

// MARK: - ClusterItem

class ClusterItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    let shopId: Int
    let shortName: String
    let branch: BranchEntity

    init(position: CLLocationCoordinate2D, shopId: Int, shortName: String, branch: BranchEntity) {
        self.position = position
        self.shopId = shopId
        self.shortName = shortName
        self.branch = branch
    }
}
