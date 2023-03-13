//
//  CatalogView.swift
//  InStock
//
//  Created by Abdullah Atkaev on 26.02.2023.
//

import Foundation
import SwiftUI

struct CatalogView: View {
    @ObservedObject var warehouse: Warehouse
    @State private var showingAddItemSheet = false
    @State private var showingEditItemSheet = false
    @State private var newItemName = ""
    @State private var newItemBarcode = ""
    @State private var editItemName = ""
    @State private var editItemBarcode = ""
    @State private var selectedItem: CatalogItem?

    var body: some View {
        NavigationView {
            List {
                ForEach(warehouse.catalogItems) { item in
                    Button(action: {
                        selectedItem = item
                        editItemName = item.name
                        editItemBarcode = item.barcode
                        showingEditItemSheet = true
                    }) {
                        VStack(alignment: .leading) {
                            Text(item.name)
                            Text(item.barcode)
                        }
                    }
                }
                .onDelete(perform: deleteCatalogItems)
            }
            .navigationBarTitle("Каталог")
            .navigationBarItems(trailing: Button(action: {
                showingAddItemSheet = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddItemSheet) {
                AddItemView(itemName: $newItemName, itemBarcode: $newItemBarcode)
                    .onDisappear {
                        if !newItemName.isEmpty && !newItemBarcode.isEmpty {
                            warehouse.addCatalogItem(item: CatalogItem(name: newItemName, barcode: newItemBarcode, weight: 5,volume: Volume(length: 1, width: 1, height: 1), category: Category(name: "Random")))
                            newItemName = ""
                            newItemBarcode = ""
                        }
                    }
            }
            .sheet(isPresented: $showingEditItemSheet) {
                EditItemView(itemName: $editItemName, itemBarcode: $editItemBarcode)
                    .onDisappear {
                        if var item = selectedItem {
                            item.name = editItemName
                            item.barcode = editItemBarcode
                            warehouse.saveCatalog()
                        }
                    }
            }
        }
    }

    func deleteCatalogItems(at offsets: IndexSet) {
        warehouse.deleteCatalogItems(at: offsets)
    }
}

struct AddItemView: View {
    @Binding var itemName: String
    @Binding var itemBarcode: String

    var body: some View {
        Form {
            BarcodeScannerView(scannedBarcode: $itemBarcode)
                .frame(height: 200)
                .clipped()
                .cornerRadius(10)
            Section(header: Text("Item details")) {
                TextField("Name", text: $itemName)
                TextField("Barcode", text: $itemBarcode)
            }
        }
        .navigationBarTitle("Add Item")
        .navigationBarItems(trailing: Button("Save") {
            if !itemName.isEmpty && !itemBarcode.isEmpty {
                presentationMode.wrappedValue.dismiss()
            }
        })
    }

    @Environment(\.presentationMode) var presentationMode
}

struct EditItemView: View {
    @Binding var itemName: String
    @Binding var itemBarcode: String

    var body: some View {
        Form {
            Section(header: Text("Item details")) {
                TextField("Name", text: $itemName)
                TextField("Barcode", text: $itemBarcode)
            }
        }
        .navigationBarTitle("Edit Item")
        .navigationBarItems(trailing: Button("Save") {
            presentationMode.wrappedValue.dismiss()
        })
    }

    @Environment(\.presentationMode) var presentationMode
}

