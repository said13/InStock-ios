//
//  SettingsView.swift
//  InStock
//
//  Created by Abdullah Atkaev on 09.03.2023.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    var warehouse: Warehouse
    
    var body: some View {
        NavigationView {
            Form {
                Button {
                    warehouse.cleanShipments()
                } label: {
                    Text("Clean shipments")
                }
                Button {
                    warehouse.cleanStock()
                } label: {
                    Text("Clean stock")
                }
                Button {
                    warehouse.cleanCatalog()
                } label: {
                    Text("Clean catalog")
                }
            }
            .navigationBarTitle(Text("Настройки"))
        }
    }
}

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsView(warehouse: Warehouse(catalogItems: []))
    }
}
