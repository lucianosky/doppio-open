// ShopTagCategory.swift
// App/Model — Ring 1 (Domain)
// No SwiftUI import — display details (colors, icons) live in the View layer.

import Foundation

// MARK: - Regular categories

enum ShopTagCategory: String, CaseIterable, Identifiable {
    case cafe          = "Café & Bebidas"
    case food          = "Comida & Doces"
    case vibe          = "Clima & Vibe"
    case occasion      = "Ocasião"
    case services      = "Serviços & Pagamento"
    case dietary       = "Alimentação Especial"
    case accessibility = "Acessibilidade"
    case parking       = "Estacionamento"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .cafe:          return "cup.and.saucer.fill"
        case .food:          return "fork.knife"
        case .vibe:          return "text.bubble.fill"
        case .occasion:      return "sparkles"
        case .services:      return "creditcard.fill"
        case .dietary:       return "leaf.fill"
        case .accessibility: return "figure.roll"
        case .parking:       return "car.fill"
        }
    }

    static func category(for tag: String) -> ShopTagCategory? {
        switch tag {
        case "café especial", "espresso", "cappuccino", "latte", "cold brew", "matcha",
             "café gelado", "torra própria", "café coado", "café filtrado":
            return .cafe
        case "croissant", "brownie", "cookies", "pão artesanal", "pão de queijo",
             "cheesecake", "brigadeiro", "quiche", "bolo", "sourdough":
            return .food
        case "aconchegante", "minimalista", "retrô", "tranquilo", "plantas",
             "temático", "bom para trabalhar", "reuniões":
            return .vibe
        case "aceita pets", "popular no café da manhã", "bom para grupos",
             "bom para encontros", "música ao vivo", "área externa", "rooftop":
            return .occasion
        case "wi-fi", "cartão de crédito", "nfc", "takeaway", "delivery",
             "serviço de mesa", "vale-refeição", "poa em dobro":
            return .services
        case "vegano", "vegetariano", "sem glúten", "leite vegetal", "orgânico":
            return .dietary
        case "cadeirante", "cadeira alta", "banheiro acessível", "entrada acessível",
             "estacionamento acessível", "assentos acessíveis":
            return .accessibility
        case "estacionamento gratuito", "estacionamento pago", "estacionamento na rua":
            return .parking
        default:
            return nil
        }
    }
}

// MARK: - Social tag IDs (display details in View layer)

enum SocialTagID: String, CaseIterable {
    case lgbtq     = "lgbtqia+ friendly"
    case womenOwned = "negócio de mulher"
    case womenOnly  = "exclusivo para mulheres"
    case transSafe  = "espaço trans seguro"
    case genderNeutral = "banheiro gênero neutro"

    static func find(_ raw: String) -> SocialTagID? {
        let key = raw.lowercased().trimmingCharacters(in: .whitespaces)
        return allCases.first { $0.rawValue == key }
    }
}

// MARK: - TagNormalizer

enum TagNormalizer {
    // swiftlint:disable:next cyclomatic_complexity
    static func normalize(_ raw: String) -> String? {
        let key = raw.lowercased().trimmingCharacters(in: .whitespaces)
        switch key {
        // Clima & Vibe
        case "cozy", "cozy place", "cozy atmosphere", "warm and cozy":
            return "aconchegante"
        case "meeting", "appointment required":
            return "reuniões"
        case "quiet", "quiet place", "good for working":
            return "bom para trabalhar"
        // Café & Bebidas
        case "specialty coffee", "special coffee", "high-quality coffee", "quality coffee":
            return "café especial"
        case "cappuccino", "cappucino":
            return "cappuccino"
        case "iced coffee", "iced coffees":
            return "café gelado"
        // Comida & Doces
        case "croissant", "croissants":
            return "croissant"
        case "brownie", "brownies", "dark chocolate brownie":
            return "brownie"
        case "cookie", "cookies", "wonderful cookies", "filled cookie", "soft cookie":
            return "cookies"
        case "artisanal bread", "artisanal breads":
            return "pão artesanal"
        case "pao de queijo":
            return "pão de queijo"
        // Ocasião
        case "dogs allowed", "dogs allowed inside", "dogs allowed outside":
            return "aceita pets"
        // Serviços & Pagamento
        case "free wi-fi", "wi-fi":
            return "wi-fi"
        case "double poa", "poa double":
            return "poa em dobro"
        // Estacionamento
        case "free parking lot", "on-site parking", "plenty of parking":
            return "estacionamento gratuito"
        case "paid parking lot", "paid street parking", "paid multi-storey car park":
            return "estacionamento pago"
        // Remover — ruído puro
        case "barista", "baristas", "call center", "notice", "mark", "book",
             "food", "table", "toilet", "seating", "space", "interior",
             "environment", "ambience", "structure", "team", "welcome",
             "filling", "soft opening", "merienda", "credit carnao que ds":
            return nil
        // Pass-through — PT nativo já correto
        default:
            return key
        }
    }
}

// MARK: - Categorize pipeline

extension ShopTagCategory {
    static func categorize(
        tags: [String]
    ) -> (regular: [(category: ShopTagCategory, tags: [String])], socialIDs: [SocialTagID]) {
        var regularMap: [ShopTagCategory: [String]] = [:]
        var socialIDs: [SocialTagID] = []

        for raw in tags {
            guard let normalized = TagNormalizer.normalize(raw) else { continue }

            if let socialID = SocialTagID.find(normalized) {
                if !socialIDs.contains(socialID) {
                    socialIDs.append(socialID)
                }
            } else if let cat = ShopTagCategory.category(for: normalized) {
                if !(regularMap[cat, default: []].contains(normalized)) {
                    regularMap[cat, default: []].append(normalized)
                }
            }
        }

        let regular = ShopTagCategory.allCases.compactMap { cat -> (ShopTagCategory, [String])? in
            guard let tags = regularMap[cat], !tags.isEmpty else { return nil }
            return (cat, tags)
        }

        return (regular: regular, socialIDs: socialIDs)
    }
}
