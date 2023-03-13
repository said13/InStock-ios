//
//  TabView.swift
//  InStock
//
//  Created by Abdullah Atkaev on 22.02.2023.
//

import SwiftUI
import Foundation
import Combine

class Warehouse: ObservableObject {
    var cancellables: Set<AnyCancellable> = []

    var totalVolume: Double = 200
    @Published var catalogItems: [CatalogItem] = []
    @Published var stockItems: [StockItem] = []
    @Published var shipments: [Shipment] = []
    @Published var palettes: [Palette]
    var paletteManager: PaletteManager

    init(paletteManager: PaletteManager = PaletteManager(rows: 4, columns: 4)) {
        self.paletteManager = paletteManager
        self.palettes = paletteManager.palettes
        self.loadStock()
        self.loadCatalog()
        self.loadShipments()

        $stockItems
            .sink { [weak self] _ in self?.saveStock() }
            .store(in: &cancellables)
        $shipments
            .sink { [weak self] _ in self?.saveShipments() }
            .store(in: &cancellables)
        $catalogItems
            .sink { [weak self] _ in self?.saveCatalog() }
            .store(in: &cancellables)
    }

    func cleanShipments() {
        shipments.removeAll()
        saveShipments()
    }

    func cleanStock() {
        stockItems.removeAll()
        saveStock()
    }

    func cleanCatalog() {
        catalogItems.removeAll()
        saveCatalog()
    }

    init(catalogItems: [CatalogItem]) {
        self.catalogItems = catalogItems
        self.paletteManager = PaletteManager(rows: 4, columns: 4)
        self.palettes = self.paletteManager.palettes
    }

    private func addStockItem(item: StockItem) {
        if let itemIndex = stockItems.firstIndex(where: {$0.id == item.id}) {
            var mutableItem = stockItems[itemIndex]
            mutableItem.quantity += item.quantity
            stockItems[itemIndex] = mutableItem
        } else {
            stockItems.append(item)
        }
    }

    private func removeStockItem(item: StockItem) {
        if let itemIndex = stockItems.firstIndex(where: {$0.id == item.id}) {
            var mutableItem = stockItems[itemIndex]
            mutableItem.quantity -= item.quantity
            if mutableItem.quantity <= 0 {
                stockItems.remove(at: itemIndex)
            } else {
                stockItems[itemIndex] = mutableItem
            }
        }
    }

    private func saveStock() {
        do {
            let data = try JSONEncoder().encode(stockItems)
            UserDefaults.standard.set(data, forKey: "Stock")
        } catch {
            print("Error saving catalog: \(error.localizedDescription)")
        }
    }

    private func loadStock() {
        if let data = UserDefaults.standard.data(forKey: "Stock") {
            do {
                stockItems = try JSONDecoder().decode([StockItem].self, from: data)
            } catch {
                print("Error loading catalog: \(error.localizedDescription)")
            }
        }
    }

    public func getStockItem(barcode: String) -> CatalogItem? {
        return catalogItems.first(where: { $0.barcode == barcode })
    }
}

extension Warehouse {
    func addCatalogItem(item: CatalogItem) {
        catalogItems.append(item)
        saveCatalog()
    }

    func deleteCatalogItems(at offsets: IndexSet) {
        catalogItems.remove(atOffsets: offsets)
        saveCatalog()
    }

    func saveCatalog() {
        do {
            let data = try JSONEncoder().encode(catalogItems)
            UserDefaults.standard.set(data, forKey: "Catalog")
        } catch {
            print("Error saving catalog: \(error.localizedDescription)")
        }
    }

    func loadCatalog() {
        if let data = UserDefaults.standard.data(forKey: "Catalog") {
            do {
                let userDefaults = try JSONDecoder().decode([CatalogItem].self, from: data)
                catalogItems = userDefaults.isEmpty ? mockItems : userDefaults
            } catch {
                print("Error loading catalog: \(error.localizedDescription)")
            }
        }
    }
}

extension Warehouse {
    func addShipment(shipment: Shipment) {
        shipments.append(shipment)
        saveShipments()
    }

    func deleteShipment(at offsets: IndexSet) {
        shipments.remove(atOffsets: offsets)
        saveShipments()
    }

    func saveShipments() {
        do {
            let data = try JSONEncoder().encode(shipments)
            UserDefaults.standard.set(data, forKey: "Shipment")
        } catch {
            print("Error saving shipment: \(error.localizedDescription)")
        }
    }

    func loadShipments() {
        if let data = UserDefaults.standard.data(forKey: "Shipment") {
            do {
                shipments = try JSONDecoder().decode([Shipment].self, from: data)
            } catch {
                print("Error loading shipment: \(error.localizedDescription)")
            }
        }
    }

    func addItemToShipment(shipment: Shipment, item: StockItem) -> Shipment? {
        if let index = shipments.firstIndex(of: shipment) {
            var mutableShipment = shipment
            if let itemIndex = mutableShipment.stockItems.firstIndex(where: {$0.id == item.id}) {
                var mutableItem = mutableShipment.stockItems[itemIndex]
                mutableItem.quantity += item.quantity
                mutableShipment.stockItems[itemIndex] = mutableItem
            } else {
                mutableShipment.stockItems.append(item)
            }

            shipments[index] = mutableShipment
            addStockItem(item: item)
            return mutableShipment
        }
        return nil
    }

    func removeItemFromShipment(shipment: Shipment, item: StockItem) -> Shipment? {
        if let index = shipments.firstIndex(of: shipment) {
            var mutableShipment = shipment
            if let itemIndex = mutableShipment.stockItems.firstIndex(of: item) {
                mutableShipment.stockItems.remove(at: itemIndex)
                shipments[index] = mutableShipment
                return mutableShipment
            }
            return nil
        }
        return nil
    }
}

extension Warehouse {
    func getPalette(item: StockItem) -> Palette? {
        for palette in palettes {
            if let existingItem = stockItems.first(where: {$0.id == item.id}),
               existingItem.paletteId == palette.id {
                return palette
            }
        }
        return nil
    }

    func getStockItems(palette: Palette?) -> [StockItem] {
        guard let palette = palette else {
            // If no palette is selected, return all stock items
            return stockItems
        }

        let paletteId = palette.id
        return stockItems.filter { $0.paletteId == paletteId }
    }
}

extension Warehouse {
    func getWeightStatistics(palette: Palette?) -> [(label: String, value: Double)] {
        let stockItems = getStockItems(palette: palette)
        let weights = Dictionary(grouping: stockItems, by: { $0.item.category }).compactMapValues { $0.reduce(0) { $0 + $1.item.weight * Double($1.quantity) } }
        return weights.sorted { $0.value > $1.value }
            .map { (label: $0.key.name, value: $0.value) }
    }

    func getVolumeStatistics(palette: Palette?) -> [(label: String, value: Double)] {
        let stockItems = getStockItems(palette: palette)
        let volumes = Dictionary(grouping: stockItems, by: { $0.item.category }).compactMapValues { $0.reduce(0) { $0 + $1.item.volume.volume * Double($1.quantity) } }
        return volumes.sorted { $0.value > $1.value }
            .map { (label: $0.key.name, value: $0.value) }
    }
}

struct WarehouseView: View {
    enum DisplayMode: String, Equatable, CaseIterable {
        case stats = "Статистика"
        case list = "Список"
        case palette = "Паллета"

        var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    }


    @ObservedObject var warehouse: Warehouse

    @State private var selectedPalette: Palette? = nil
    @State private var mode: DisplayMode = .stats

    private var statsModeContent: some View {
        ScrollView {
            VStack {
                StatisticsView(warehouse: warehouse, selectedPalette: $selectedPalette)
//                WarehouseTableView(paletteManager: warehouse.paletteManager, selectedPalette: $selectedPalette)
//                listModeContent
            }
        }
    }

    private var listModeContent: some View {
        List(warehouse.getStockItems(palette: selectedPalette)) { item in
            StockItemView(item: item)
        }
    }

    private var paletteModeContent: some View {
        VStack {
            WarehouseTableView(paletteManager: warehouse.paletteManager, selectedPalette: $selectedPalette)
            if let selectedPalette = selectedPalette {
                ScrollView {
                    LazyVStack {
                        ForEach(warehouse.getStockItems(palette: selectedPalette), id: \.self) { item in
                            StockItemView(item: item)
                        }
                    }
                }
            }
            Spacer()
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("Mode", selection: $mode) {
                    ForEach(DisplayMode.allCases, id: \.self) { value in
                        Text(value.localizedName).tag(value)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                switch mode {
                case .stats:
                    statsModeContent
                case .list:
                    listModeContent
                case .palette:
                    paletteModeContent
                }
            }
            .navigationBarTitle("Склад")
        }
    }
}

struct StockItemView: View {
    var item: StockItem

    var body: some View {
        VStack {
            HStack {
                Text(item.name)
                Spacer()
                Text("\(item.quantity) шт")
            }
            HStack {
                Text("Палета: \(item.paletteId)")
                Spacer()
            }
        }
    }
}

struct PaletteView: View {
    let palette: Palette?
    let warehouse: Warehouse

    var body: some View {
        VStack {
            if let palette = palette {
                Text("Palette \(palette.id)")
                List {
                    ForEach(warehouse.stockItems.filter { $0.paletteId == palette.id }) { item in
                        Text(item.name)
                    }
                }
            } else {
                Text("No palette selected.")
            }
        }
    }
}

struct PaletteManager {
    let rows: Int
    let columns: Int

    var palettes: [Palette] {
        var result: [Palette] = []
        for row in 1...rows {
            for column in 0..<columns {
                let letter = String(UnicodeScalar(column + 65)!)
                result.append(Palette(id: "\(letter)\(row)", row: row, column: column))
            }
        }
        return result
    }

    func getPalette(row: Int, column: Int) -> Palette? {
        return palettes.first { $0.row == row && $0.column == column }
    }
}

struct StatisticsView: View {
    @ObservedObject var warehouse: Warehouse
    @Binding var selectedPalette: Palette?

    var weightValues: [Double] {
        warehouse.getWeightStatistics(palette: selectedPalette)
            .map(\.value)
    }

    var weightLabels: [String] {
        warehouse.getWeightStatistics(palette: selectedPalette)
            .map(\.label)
    }

    var volumeValues: [Double] {
        warehouse.getVolumeStatistics(palette: selectedPalette)
            .map(\.value)
    }

    var volumeLabels: [String] {
        warehouse.getVolumeStatistics(palette: selectedPalette)
            .map(\.label)
    }

    var body: some View {
        HStack(spacing: 20) {
            PieChartView(values: weightValues, colors: [.red, .green, .blue], names: weightLabels, backgroundColor: .gray, innerRadiusFraction: 0.5)
            PieChartView(values: volumeValues, colors: [.red, .green, .blue], names: volumeLabels, backgroundColor: .gray, innerRadiusFraction: 0.5)
        }
        .padding()
    }
}

struct WarehouseView_Preview: PreviewProvider {
    static var previews: some View {
        WarehouseView(warehouse: Warehouse())
    }
}
