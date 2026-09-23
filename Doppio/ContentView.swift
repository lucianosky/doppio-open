// ContentView.swift
// Doppio

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var sessionStore: SessionStore
    @State private var showSplash = !ProcessInfo.processInfo.arguments.contains("-uitest_skip_splash")

    var body: some View {
        if showSplash {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showSplash = false
                        }
                    }
                }
        } else if sessionStore.hasPassedLogin {
            MainView()
                .transition(.opacity)
        } else {
            LoginView(vm: appState.container.loginViewModel)
                .transition(.opacity)
        }
    }
}
