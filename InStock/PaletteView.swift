//
//  PaletteView.swift
//  InStock
//
//  Created by Abdullah Atkaev on 28.02.2023.
//

import Foundation
import SwiftUI

struct WarehouseTableView: View {
    var paletteManager: PaletteManager
    @Binding var selectedPalette: Palette?

    var body: some View {
        let letters = (0..<paletteManager.columns).map { String(UnicodeScalar($0 + 65)!) }
        let numbers = (1...paletteManager.rows)

        VStack(spacing: 0) {
            ForEach(numbers, id: \.self) { number in
                HStack(spacing: 0) {
                    ForEach(letters, id: \.self) { letter in
                        let palette = paletteManager.palettes.first { $0.row == number && $0.column == letter.columnIndex }

                        Button(action: {
                            if selectedPalette == palette {
                                selectedPalette = nil
                            } else {
                                selectedPalette = palette
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(palette == nil ? Color.gray.opacity(0.5) : (palette == selectedPalette ? Color.blue : Color.white))
                                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 1, y: 1)
                                    .shadow(color: Color.white.opacity(0.7), radius: 3, x: -1, y: -1)
                                Text("\(letter)\(number)")
                                    .foregroundColor(palette == selectedPalette ? .white : .black)
                                    .font(.title3)
                            }
                            .padding(.all, 4)
                        }
                    }
                }
            }
        }
        .frame(height: 200)
    }
}
extension String {
    var columnIndex: Int {
        return Int(UnicodeScalar(self)!.value - 65)
    }
}

struct ContentView: View {
    @State private var selectedPalette: Palette?

    var body: some View {
        WarehouseTableView(paletteManager: PaletteManager(rows: 4, columns: 4), selectedPalette: $selectedPalette)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
