// DoppioAPIPath.swift
// App/Network
//
// Doppio API endpoint paths.
// Each case maps to a relative path under the API base URL.
//
// MockDataSource naming: path → fixture file
//   /cities              → cities.json
//   /shops               → shops.json
//   /shops/1             → shops_1.json
//   /news                → news.json
//   /news/1              → news_1.json
//   /baristas            → baristas.json
//   /baristas/1          → baristas_1.json

import Foundation

// MARK: - DoppioAPIPath

enum DoppioAPIPath: APIPathProvider {

    // MARK: City
    case cities

    // MARK: Shop
    case shops
    case shopDetail(id: Int)

    // MARK: News
    case news
    case newsDetail(id: Int)

    // MARK: Barista
    case baristas
    case baristaDetail(id: Int)

    // MARK: - APIPathProvider

    var path: String {
        switch self {
        case .cities:                 return "/cities"
        case .shops:                  return "/shops"
        case .shopDetail(let id):     return "/shops/\(id)"
        case .news:                   return "/news"
        case .newsDetail(let id):     return "/news/\(id)"
        case .baristas:               return "/baristas"
        case .baristaDetail(let id):  return "/baristas/\(id)"
        }
    }
}
