// ShopSocialNetView.swift
// App/View/Shop

import SwiftUI

struct ShopSocialNetView: View {
    let shop: ShopEntity
    let branch: BranchEntity
    @Environment(BrewTheme.self) private var theme
    @State private var showDirections = false
    @State private var showOpenFailAlert = false

    // MARK: - Computed URLs

    private var phoneURL: URL? {
        guard let phone = branch.phone, !phone.isEmpty else { return nil }
        let digits = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return URL(string: "tel:\(digits)")
    }

    private var whatsappURL: URL? {
        guard let wa = shop.contact?.whatsapp, !wa.isEmpty else { return nil }
        let digits = wa.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return URL(string: "https://wa.me/\(digits)")
    }

    private var menuURL: URL? {
        guard let mn = branch.menu, !mn.isEmpty else { return nil }
        return URL(string: mn.hasPrefix("http") ? mn : "https://\(mn)")
    }

    private var instagramURL: URL? {
        guard let ig = shop.contact?.instagram, !ig.isEmpty else { return nil }
        return URL(string: "https://instagram.com/\(ig)")
    }

    private var siteURL: URL? {
        guard let st = shop.contact?.site, !st.isEmpty else { return nil }
        let lower = st.lowercased()
        guard !lower.contains("facebook.com"), !lower.contains("instagram.com") else { return nil }
        return URL(string: st.hasPrefix("http") ? st : "https://\(st)")
    }

    private var spotifyURL: URL? {
        guard let sp = shop.contact?.spotify, !sp.isEmpty else { return nil }
        return URL(string: sp)
    }

    private var linktreeURL: URL? {
        guard let lt = shop.contact?.linktree, !lt.isEmpty else { return nil }
        return URL(string: lt.hasPrefix("http") ? lt : "https://\(lt)")
    }

    private var ifoodURL: URL? {
        guard let url = branch.ifood, !url.isEmpty else { return nil }
        return URL(string: url)
    }

    private var rappiURL: URL? {
        guard let url = branch.rappi, !url.isEmpty else { return nil }
        return URL(string: url)
    }

    private var uberEatsURL: URL? {
        guard let url = branch.uberEats, !url.isEmpty else { return nil }
        return URL(string: url)
    }

    private var food99URL: URL? {
        guard let url = branch.food99, !url.isEmpty else { return nil }
        return URL(string: url)
    }

    private var hasDelivery: Bool {
        ifoodURL != nil || rappiURL != nil || uberEatsURL != nil || food99URL != nil
    }

    private var hasSocial: Bool {
        instagramURL != nil || siteURL != nil || spotifyURL != nil || linktreeURL != nil
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Ações
            HStack(spacing: 8) {
                directionsChip
                if let url = phoneURL {
                    SocialChip(label: "Ligar", iconSystemName: "phone.fill", url: url)
                }
                if let url = whatsappURL {
                    SocialChip(label: "WhatsApp", iconSystemName: "message.fill", url: url)
                }
                if let url = menuURL {
                    SocialChip(label: "Cardápio", iconSystemName: "menucard", url: url)
                }
            }
            .padding(.horizontal, 16)

            // Peça online
            if hasDelivery {
                SectionRow(label: "Peça online") {
                    if let url = ifoodURL {
                        SocialChip(label: "iFood", iconSystemName: "bag.fill", url: url)
                    }
                    if let url = rappiURL {
                        SocialChip(label: "Rappi", iconSystemName: "cart.fill", url: url)
                    }
                    if let url = uberEatsURL {
                        SocialChip(label: "Uber Eats", iconSystemName: "fork.knife", url: url)
                    }
                    if let url = food99URL {
                        SocialChip(label: "99Food", iconSystemName: "takeoutbag.and.cup.and.straw.fill", url: url)
                    }
                }
            }

            // Redes
            if hasSocial {
                SectionRow(label: "Redes") {
                    if let url = instagramURL {
                        SocialChip(label: "Instagram", iconSystemName: "camera.fill", url: url)
                    }
                    if let url = siteURL {
                        SocialChip(label: "Site", iconSystemName: "globe", url: url)
                    }
                    if let url = spotifyURL {
                        SocialChip(label: "Spotify", iconSystemName: "music.note", url: url)
                    }
                    if let url = linktreeURL {
                        SocialChip(label: "Linktree", iconSystemName: "link", url: url)
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .background(theme.tokens.colors.backgroundCard)
        .cornerRadius(theme.tokens.radius.radiusCard)
        .confirmationDialog("Como chegar", isPresented: $showDirections, titleVisibility: .visible) {
            directionsActions
        }
        .alert("Não foi possível abrir", isPresented: $showOpenFailAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("O app solicitado não está instalado e o link de fallback também não pôde ser aberto.")
        }
    }

    // MARK: - "Como chegar" chip

    private var directionsChip: some View {
        Button {
            showDirections = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 14))
                    .foregroundColor(theme.tokens.colors.primaryMain)
                Text("Como chegar")
                    .font(.system(size: 12))
                    .foregroundColor(theme.tokens.colors.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(theme.tokens.colors.backgroundSecondary)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Como chegar")
    }

    // MARK: - Directions action sheet buttons

    @ViewBuilder
    private var directionsActions: some View {
        let lat = branch.address.latitude ?? 0
        let lng = branch.address.longitude ?? 0
        let name = shop.longName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        Button("Apple Maps") {
            openWithFallback(
                primary: URL(string: "maps://?daddr=\(lat),\(lng)"),
                fallback: URL(string: "https://maps.apple.com/?daddr=\(lat),\(lng)")
            )
        }
        Button("Google Maps") {
            openWithFallback(
                primary: URL(string: "comgooglemaps://?daddr=\(lat),\(lng)"),
                fallback: URL(string: "https://maps.google.com/?q=\(lat),\(lng)")
            )
        }
        Button("Uber") {
            // swiftlint:disable:next line_length
            let uberPrimary = "uber://?action=setPickup&pickup=my_location&dropoff[latitude]=\(lat)&dropoff[longitude]=\(lng)&dropoff[nickname]=\(name)"
            // swiftlint:disable:next line_length
            let uberFallback = "https://m.uber.com/ul/?action=setPickup&pickup=my_location&dropoff[latitude]=\(lat)&dropoff[longitude]=\(lng)&dropoff[nickname]=\(name)"
            openWithFallback(primary: URL(string: uberPrimary), fallback: URL(string: uberFallback))
        }
        Button("99") {
            let taxi99Primary = "99app://ride?destination_lat=\(lat)&destination_lng=\(lng)&destination_name=\(name)"
            openWithFallback(primary: URL(string: taxi99Primary), fallback: URL(string: "https://99app.com"))
        }
        Button("Cancelar", role: .cancel) {}
    }

    private func openWithFallback(primary: URL?, fallback: URL?) {
        guard let primary else {
            guard let fallback else { showOpenFailAlert = true; return }
            UIApplication.shared.open(fallback) { success in
                if !success { Task { @MainActor in showOpenFailAlert = true } }
            }
            return
        }
        UIApplication.shared.open(primary) { success in
            if success { return }
            guard let fallback else { Task { @MainActor in showOpenFailAlert = true }; return }
            UIApplication.shared.open(fallback) { fallbackSuccess in
                if !fallbackSuccess { Task { @MainActor in showOpenFailAlert = true } }
            }
        }
    }
}

// MARK: - SectionRow

private struct SectionRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(theme.tokens.colors.textSecondary)
                .padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) { content() }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 2)
            }
        }
    }
}

// MARK: - SocialChip

private struct SocialChip: View {
    let label: String
    let iconSystemName: String
    let url: URL
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 6) {
                Image(systemName: iconSystemName)
                    .font(.system(size: 14))
                    .foregroundColor(theme.tokens.colors.primaryMain)
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(theme.tokens.colors.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(theme.tokens.colors.backgroundSecondary)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
