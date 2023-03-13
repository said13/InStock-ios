//
//  File.swift
//  InStock
//
//  Created by Abdullah Atkaev on 09.03.2023.
//

import Foundation
import SwiftUI

struct ButtonFactory {
    static func makePrimaryButton(withTitle title: String, isEnabled: Bool = true, action: @escaping () -> Void) -> some View {
        return Button(action: action) {
            Text(title)
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isEnabled ? Color.blue : Color.gray)
                .cornerRadius(8)
                .opacity(isEnabled ? 1.0 : 0.5)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.spring())
        .buttonStyle(PlainButtonStyle())
    }

    static func makeSecondaryButton(withTitle title: String, isEnabled: Bool = true, action: @escaping () -> Void) -> some View {
        return Button(action: action) {
            Text(title)
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundColor(isEnabled ? .blue : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isEnabled ? Color.blue : Color.gray, lineWidth: 2)
                )
                .background(Color.white)
                .cornerRadius(8)
                .opacity(isEnabled ? 1.0 : 0.5)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.spring())
        .buttonStyle(PlainButtonStyle())
    }
}
