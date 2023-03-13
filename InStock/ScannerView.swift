//
//  ScannerView.swift
//  InStock
//
//  Created by Abdullah Atkaev on 06.03.2023.
//

import Foundation
import SwiftUI

struct ScannerView: View {
    @ObservedObject var warehouse: Warehouse
    @Binding var newItem: StockItem?

    @State private var showingBarcodeScanner = false
    @State private var scannedBarcode = ""
    @State private var scannedQuantity = 1
    @State private var scannedItemName = ""
    @State private var selectedPalette: Palette?
    var scannerHeight: CGFloat = 200
    var body: some View {
        VStack {
            BarcodeScannerView(scannedBarcode: $scannedBarcode)
                .frame(height: scannerHeight)
                .clipped()
                .cornerRadius(10)
            if let existingItem = warehouse.getStockItem(barcode: scannedBarcode) {
                Text(existingItem.name)
                Text(existingItem.barcode)
                Stepper(value: $scannedQuantity, in: 1...100, label: {
                    Text("Количество: \(scannedQuantity)")
                })
            } else {
                TextField("Название", text: $scannedItemName)
                TextField("Штрих код", text: $scannedBarcode)
                Stepper(value: $scannedQuantity, in: 1...100, label: {
                    Text("Количество: \(scannedQuantity)")
                })
            }
            WarehouseTableView(paletteManager: warehouse.paletteManager, selectedPalette: $selectedPalette)
            doneButton
            Spacer()
        }
        .padding()
    }

    var doneButton: some View {
        Button("Добавить") {
            guard let selectedPalette else { return }
            if let catalogItem = warehouse.getStockItem(barcode: scannedBarcode) {
                let stockItem = StockItem(item: catalogItem, quantity: scannedQuantity, paletteId: selectedPalette.id)
                self.newItem = stockItem
            } else {
                let catalogItem = CatalogItem(name: scannedItemName, barcode: scannedBarcode, weight: 5, volume: Volume(length: 1, width: 1, height: 1), category: Category(name: "Random"))
                let stockItem = StockItem(item: catalogItem, quantity: scannedQuantity, paletteId: selectedPalette.id)
                self.newItem = stockItem
                warehouse.addCatalogItem(item: catalogItem)
            }
            scannedBarcode = ""
            scannedQuantity = 1
            scannedItemName = ""
        }
        .disabled(selectedPalette == nil)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background {
            Color.blue
        }
        .foregroundColor(.white)
        .cornerRadius(10)
        .font(.title2)
    }
}

//struct ScannerView_Preview: PreviewProvider {
//    static var previews: some View {
//        ScannerView(warehouse: Warehouse(catalogItems: mockItems), newItem: .constant(nil))
//    }
//}

struct ScannerView2: View {
    @ObservedObject var warehouse: Warehouse
    @Binding var newItem: StockItem?

    @State private var showingBarcodeScanner = false
    @State private var scannedBarcode = ""
    @State private var scannedQuantity = 1
    @State private var scannedItemName = ""
    @State private var selectedPalette: Palette?
    var body: some View {
        ZStack {
            BarcodeScannerView(scannedBarcode: $scannedBarcode)
                .ignoresSafeArea()
            Text(scannedBarcode)
                .font(.title)
//            VStack {
//                Spacer()
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(Color.white, lineWidth: 5)
//                    .frame(height: 200)
//                    .padding(.horizontal, 24)
//                Spacer()
//            }

        }
    }
}

struct ScannerView2_Preview: PreviewProvider {
    static var previews: some View {
        ScannerView2(warehouse: Warehouse(catalogItems: mockItems), newItem: .constant(nil))
    }
}
