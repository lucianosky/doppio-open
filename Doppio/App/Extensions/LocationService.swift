// LocationService.swift
// App/Extensions
//
// Wraps CLLocationManager to provide the user's current location reactively.
// Used by CityViewModel to sort shops by distance.
// Requests "when in use" authorization on demand (called before sort).

import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject {

    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var isAuthorized: Bool = false

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            manager.startUpdatingLocation()
        default:
            isAuthorized = false
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        let authorized = status == .authorizedWhenInUse || status == .authorizedAlways
        Task { @MainActor in
            self.isAuthorized = authorized
            if authorized { self.manager.startUpdatingLocation() }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = latest
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            logError("LocationService: \(error.localizedDescription)", category: .network)
        }
    }
}
