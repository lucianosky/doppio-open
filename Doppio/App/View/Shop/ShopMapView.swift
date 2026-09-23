// ShopMapView.swift
// App/View/Shop

import GoogleMaps
import SwiftUI

struct ShopMapView: View {
    let branch: BranchEntity
    @Environment(BrewTheme.self) private var theme

    private var mapsURL: URL? {
        guard let lat = branch.address.latitude, let lng = branch.address.longitude else { return nil }
        let name = (branch.label ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "maps://?ll=\(lat),\(lng)&q=\(name)")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Localização")
                .font(.headline)
                .foregroundColor(theme.tokens.colors.textPrimary)
                .padding(.horizontal, 2)

            if let lat = branch.address.latitude, let lng = branch.address.longitude {
                ShopMapInnerView(
                    latitude: lat,
                    longitude: lng
                )
                .cornerRadius(theme.tokens.radius.radiusCard)

                if let url = mapsURL {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Obter direções")
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundColor(theme.tokens.colors.primaryMain)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .accessibilityLabel("Abrir no Maps")
                }
            } else {
                Text("Localização não disponível")
                    .font(.subheadline)
                    .foregroundColor(theme.tokens.colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
        .background(theme.tokens.colors.backgroundCard)
        .cornerRadius(theme.tokens.radius.radiusCard)
    }
}

struct ShopMapInnerView: UIViewRepresentable {
    let latitude: Double
    let longitude: Double

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(
            withLatitude: latitude,
            longitude: longitude,
            zoom: 15
        )
        let options = GMSMapViewOptions()
        options.camera = camera
        let mapView = GMSMapView(options: options)
        mapView.isUserInteractionEnabled = false

        if let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json"),
           let style = try? GMSMapStyle(contentsOfFileURL: styleURL) {
            mapView.mapStyle = style
        }

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.map = mapView
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        uiView.camera = GMSCameraPosition.camera(
            withLatitude: coordinate.latitude,
            longitude: coordinate.longitude,
            zoom: 15
        )
    }
}
