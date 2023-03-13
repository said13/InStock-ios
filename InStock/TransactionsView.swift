//
//  Transactions.swift
//  InStock
//
//  Created by Abdullah Atkaev on 28.02.2023.
//

import Foundation
import SwiftUI

struct Party: Identifiable {
    let id: String
    let customerNumber: String
}

struct Transaction: Identifiable {
    let id: String
    let partyId: String
    let date: Date
    let description: String
    let amount: Double
}

class ShipmentsVM: ObservableObject {
    @Published var selectedItem: Shipment?
    @Published var showingAddItemSheet = false
    @Published var showingEditItemSheet = false
}

struct ShipmentsView: View {
    @ObservedObject var warehouse: Warehouse
    @ObservedObject var shipmentsVM: ShipmentsVM = ShipmentsVM()

    var body: some View {
        NavigationView {
            List {
                ForEach(warehouse.shipments) { item in
                    NavigationLink(destination: TransactionsView(warehouse: warehouse, shipment: item)) {
                        VStack(alignment: .leading) {
                            Text(item.customerCode)
                            Text(item.startDate.formatted())
                        }
                    }
                }
                .onDelete { index in
                    warehouse.deleteShipment(at: index)
                }
            }
            .navigationBarTitle("Приемка")
            .navigationBarItems(trailing: Button(action: {
                shipmentsVM.showingAddItemSheet = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $shipmentsVM.showingAddItemSheet) {
                ShipmentForm(warehouse: warehouse)
            }
        }
    }
}

struct ShipmentForm: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var warehouse: Warehouse
    @State var customerCode: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        Form {
            TextField("Customer code", text: $customerCode)
                .focused($isFocused)
            Button("Add") {
                let newShipment = Shipment(customerCode: customerCode, shipmentType: .incoming, stockItems: [])
                warehouse.addShipment(shipment: newShipment)

                presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            self.isFocused = true
        }
    }
}

struct TransactionsView: View {
    @ObservedObject var warehouse: Warehouse
    @State var shipment: Shipment
    @State private var showingScanner = false
    @State private var showingScanner2 = false
    @State var newItem: StockItem?
    var body: some View {
        ZStack {
            List {
                ForEach(shipment.stockItems) { item in
                    StockItemView(item: item)
                }
            }
            VStack {
                Spacer()
                ButtonFactory.makePrimaryButton(withTitle: "Scan") {
                    showingScanner2 = true
                }
                .padding()
            }
        }
        .navigationBarTitle("Приемка \(shipment.customerCode)")
        .navigationBarItems(trailing: Button(action: {
            showingScanner = true
        }) {
            Image(systemName: "barcode.viewfinder")
        })
        .sheet(isPresented: $showingScanner) {
            ScannerView(warehouse: warehouse, newItem: $newItem)
        }
        .sheet(isPresented: $showingScanner2) {
            ScannerView2(warehouse: warehouse, newItem: $newItem)
        }
        .onChange(of: newItem) { newValue in
            if let newValue,
               let shipment = warehouse.addItemToShipment(shipment: shipment, item: newValue) {
                self.shipment = shipment
            }
        }
    }
}

struct TransactionsView_Preview: PreviewProvider {
    static var previews: some View {
        TransactionsView(warehouse: Warehouse(catalogItems: []), shipment: Shipment(customerCode: "", shipmentType: .incoming, stockItems: []))
    }
}
