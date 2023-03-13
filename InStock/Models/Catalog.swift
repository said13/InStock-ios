//
//  Catalog.swift
//  InStock
//
//  Created by Abdullah Atkaev on 06.03.2023.
//

import Foundation

struct CatalogItem: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var barcode: String
    var weight: Double
    var volume: Volume
    var category: Category
}

struct StockItem: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var item: CatalogItem
    var quantity: Int
    var paletteId: String

    var name: String {
        item.name
    }
}

enum ShipmentType: Codable {
    case incoming
    case outgoing
}

struct Palette: Equatable, Codable {
    let id: String
    let row: Int
    let column: Int
}

struct Shipment: Identifiable, Codable, Equatable {
    var id = UUID()
    let customerCode: String
    var shipmentType: ShipmentType
    var startDate = Date()
    var stockItems: [StockItem]
}

let mockItems = [
    CatalogItem(
        name: "Куртки",
        barcode: "4603934000274",
        weight: 5,
        volume: Volume(length: 0.30, width: 0.10, height: 0.20),
        category: Category(name: "Одежда")
    ),
    CatalogItem(
        name: "Посуда",
        barcode: "4870007380032",
        weight: 10,
        volume: Volume(length: 0.25, width: 0.5, height: 0.15),
        category: Category(name: "Товары для дома")
    ),
    CatalogItem(
        name: "Диски для авто",
        barcode: "4620001180059",
        weight: 25,
        volume: Volume(length: 0.28, width: 1, height: 0.18),
        category: Category(name: "Товары для авто")
    )
]

struct Volume: Equatable, Codable, Hashable {
    var length: Double
    var width: Double
    var height: Double
    var volume: Double {
        return length * width * height
    }
}

struct Category: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var name: String
}
