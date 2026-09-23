// MapCoordinator.swift
// App/View/City/Map

import CoreLocation
import GoogleMaps
import GoogleMapsUtils
import SwiftUI

class MapCoordinator: NSObject, GMSMapViewDelegate, GMUClusterManagerDelegate, GMUClusterRendererDelegate {
    private var clusterManager: GMUClusterManager?
    private weak var mapView: GMSMapView?

    @Binding private var selectedShopId: Int?
    @Binding private var sameLocationCandidates: [ShopMapCandidate]?

    private var allClusterItems = [ClusterItem]()
    private var lastShopIDs: [Int] = []

    init(selectedShopId: Binding<Int?>, sameLocationCandidates: Binding<[ShopMapCandidate]?>) {
        self._selectedShopId = selectedShopId
        self._sameLocationCandidates = sameLocationCandidates
    }

    // MARK: - Cluster Manager Setup

    func setupClusterManager(mapView: GMSMapView) {
        self.mapView = mapView
        guard let icon = UIImage(systemName: "cup.and.saucer.fill") else { return }

        let iconGenerator = GMUDefaultClusterIconGenerator(
            buckets: [2, 10, 100],
            backgroundImages: Array(repeating: icon, count: 3)
        )
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self

        let manager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        manager.setDelegate(self, mapDelegate: self)
        manager.cluster()
        self.clusterManager = manager
    }

    func reloadShops(shops: [ShopEntity]) {
        let newIDs = shops.map { $0.id }.sorted()
        guard newIDs != lastShopIDs else { return }
        lastShopIDs = newIDs

        guard let clusterManager else { return }
        clusterManager.clearItems()
        allClusterItems.removeAll()
        for shop in shops {
            for branch in shop.branches {
                guard let lat = branch.address.latitude, let lng = branch.address.longitude else { continue }
                let position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                let item = ClusterItem(position: position, shopId: shop.id, shortName: shop.shortName, branch: branch)
                clusterManager.add(item)
                allClusterItems.append(item)
            }
        }
        clusterManager.cluster()
    }

    // MARK: - Marker Rendering

    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        marker.iconView = markerIconView(for: marker.userData)
    }

    private func markerIconView(for userData: Any?) -> UIView? {
        switch userData {
        case let item as ClusterItem:
            let samePositionCount = allClusterItems.filter {
                $0.position.distance(to: item.position) < 0.00001
            }.count
            let text = samePositionCount > 1 ? "Vários" : item.shortName
            return UIImageView(image: MapMarkerHelper.createMarkerImage(with: text))

        case let cluster as GMUStaticCluster:
            return UIImageView(image: MapMarkerHelper.createClusterImage(count: Int(cluster.count)))

        default:
            return nil
        }
    }

    // MARK: - Marker Taps

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        switch marker.userData {
        case let tappedItem as ClusterItem:
            let tappedPosition = tappedItem.position
            let sameLocation = allClusterItems.filter {
                $0.position.distance(to: tappedPosition) < 0.00001
            }
            if sameLocation.count > 1 {
                self.sameLocationCandidates = sameLocation.map {
                    ShopMapCandidate(id: $0.shopId, name: $0.shortName)
                }
            } else {
                self.selectedShopId = tappedItem.shopId
            }

        case let cluster as GMUStaticCluster:
            let newZoom = mapView.camera.zoom + 1
            let camera = GMSCameraPosition.camera(
                withLatitude: cluster.position.latitude,
                longitude: cluster.position.longitude,
                zoom: newZoom
            )
            mapView.animate(to: camera)

        default:
            return false
        }
        return true
    }
}

extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let loc2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return loc1.distance(from: loc2)
    }
}
