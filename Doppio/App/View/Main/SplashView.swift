// SplashView.swift
// App/View/Main

import SwiftUI

struct SplashView: View {
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        ZStack {
            theme.tokens.colors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image("icon-cup")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .foregroundColor(theme.tokens.colors.primaryMain)

                Text("Doppio")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(theme.tokens.colors.textPrimary)

                Text("Os melhores cafés de Porto Alegre")
                    .font(.system(size: 14))
                    .foregroundColor(theme.tokens.colors.textSecondary)
            }

            VStack {
                Spacer()
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { idx in
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundColor(idx == 0
                                ? theme.tokens.colors.primaryMain
                                : theme.tokens.colors.textSecondary.opacity(0.4))
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }
}
