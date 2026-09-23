// UIMapView.swift
// App/View/City/Map

import GoogleMaps
import GoogleMapsUtils
import SwiftUI

struct UIMapView: UIViewRepresentable {
    let city: CityEntity?
    let filteredShops: [ShopEntity]
    @Binding var selectedShopId: Int?
    @Binding var sameLocationCandidates: [ShopMapCandidate]?

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(
            selectedShopId: $selectedShopId,
            sameLocationCandidates: $sameLocationCandidates
        )
    }

    func makeUIView(context: Context) -> GMSMapView {
        let latitude = city?.latitude ?? -30.034647
        let longitude = city?.longitude ?? -51.217658

        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 14)
        let options = GMSMapViewOptions()
        options.camera = camera
        let mapView = GMSMapView(options: options)
        mapView.delegate = context.coordinator
        mapView.isMyLocationEnabled = true

        if let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json"),
           let style = try? GMSMapStyle(contentsOfFileURL: styleURL) {
            mapView.mapStyle = style
        }

        mapView.isBuildingsEnabled = false

        context.coordinator.setupClusterManager(mapView: mapView)
        context.coordinator.reloadShops(shops: filteredShops)

        mapView.isAccessibilityElement = true
        mapView.accessibilityLabel = "Mapa interativo"
        mapView.accessibilityHint = "Toque duas vezes para explorar os locais no mapa"

        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        context.coordinator.reloadShops(shops: filteredShops)
    }
}
