//
//  LinearGradientView.swift
//  Goals
//
//  Created by Jeremy Daines on 05/03/2024.
//

import SwiftUI

// Define a reusable LinearGradientView component
struct LinearGradientView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors:
                colorScheme == .light ? [Color.white, Color.orange.opacity(0.9)] : [Color.black, Color.orange.opacity(0.9)]
            ),
            startPoint: .bottom,
            endPoint: .top
        )
        .ignoresSafeArea() // Adjust this based on your needs
    }
}
