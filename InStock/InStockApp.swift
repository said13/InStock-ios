//
//  InStockApp.swift
//  InStock
//
//  Created by Abdullah Atkaev on 22.02.2023.
//

import SwiftUI

@main
struct InStockApp: App {
    var body: some Scene {
        WindowGroup {
            InStockContent()
        }
    }
}

struct InStockContent: View {
    @State private var showSettings = false
    @ObservedObject var warehouse = Warehouse()

    var body: some View {
        TabView {
            ShipmentsView(warehouse: warehouse)
                .tabItem {
                    Label(
                        "Приемка / Отгрузка",
                        systemImage: "arrow.left.arrow.right"
                    )
                }
            WarehouseView(warehouse: warehouse)
                .tabItem {
                    Label(
                        "Склад",
                        systemImage: "bag"
                    )
                }
            CatalogView(warehouse: warehouse)
                .tabItem {
                    Label(
                        "Каталог",
                        systemImage: "book"
                    )
                }
            SettingsView(warehouse: warehouse)
                .tabItem {
                    Label(
                        "Настройки",
                        systemImage: "gear"
                    )
                }
        }
    }
}

struct InStockContent_Preview: PreviewProvider {
    static var previews: some View {
        InStockContent(warehouse: Warehouse())
    }
}
