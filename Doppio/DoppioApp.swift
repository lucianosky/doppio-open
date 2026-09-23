//
//  DoppioApp.swift
//  Doppio
//
//  Created by Luciano Sclovsky on 15/07/26.
//

import GoogleMaps
import SwiftUI

@main
struct DoppioApp: App {
    let theme = BrewTheme(DoppioTokens())
    @StateObject private var appState = AppState()

    init() {
        GMSServices.provideAPIKey("AIzaSyDJ2k-mv_VWKrwSk5rW9n9wWibuWXFaN6Q")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(theme)
                .environmentObject(appState)
                .environmentObject(appState.sessionStore)
        }
    }
}
