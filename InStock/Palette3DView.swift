//
//  Palette3DView.swift
//  InStock
//
//  Created by Abdullah Atkaev on 10.03.2023.
//

import Foundation
import SwiftUI
import SceneKit

struct Palette3DView: View {
    let palette: Palette
    let cellSize: CGFloat = 30

    var body: some View {
        ZStack {
            // back plane
            Rectangle()
                .fill(Color.gray)
                .opacity(0.5)
                .frame(width: cellSize * CGFloat(palette.column), height: cellSize * CGFloat(palette.row))

            // left and right borders
            VStack(spacing: 0) {
                ForEach(0..<palette.row) { _ in
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 2, height: cellSize)
                }
            }
            .position(x: 0, y: CGFloat(palette.row) * cellSize / 2)
            .frame(width: 2, height: cellSize * CGFloat(palette.row))

            VStack(spacing: 0) {
                ForEach(0..<palette.row) { _ in
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 2, height: cellSize)
                }
            }
            .position(x: CGFloat(palette.column) * cellSize, y: CGFloat(palette.row) * cellSize / 2)
            .frame(width: 2, height: cellSize * CGFloat(palette.row))

            // top and bottom borders
            HStack(spacing: 0) {
                ForEach(0..<palette.column) { _ in
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: cellSize, height: 2)
                }
            }
            .position(x: CGFloat(palette.column) * cellSize / 2, y: 0)
            .frame(width: cellSize * CGFloat(palette.column), height: 2)

            HStack(spacing: 0) {
                ForEach(0..<palette.column) { _ in
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: cellSize, height: 2)
                }
            }
            .position(x: CGFloat(palette.column) * cellSize / 2, y: CGFloat(palette.row) * cellSize)
            .frame(width: cellSize * CGFloat(palette.column), height: 2)
        }
    }
}

struct Cell3DView: View {
    let size: CGFloat
    let fillColor: Color

    var body: some View {
        let edgeLength = size / sqrt(3)
        let points = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: edgeLength, y: 0),
            CGPoint(x: edgeLength * 1.5, y: size / 2),
            CGPoint(x: edgeLength, y: size),
            CGPoint(x: 0, y: size),
            CGPoint(x: -edgeLength / 2, y: size / 2)
        ]

        let path = Path { path in
            path.move(to: points[0])
            for i in 1..<points.count {
                path.addLine(to: points[i])
            }
            path.closeSubpath()
        }

        let gradient = LinearGradient(gradient: Gradient(colors: [fillColor, fillColor.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)

        return path
            .fill(gradient)
            .overlay(
                path
                    .stroke(Color.gray, lineWidth: 2)
            )
    }
}
