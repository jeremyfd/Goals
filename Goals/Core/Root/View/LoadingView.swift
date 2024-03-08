//
//  LoadingView.swift
//  Goals
//
//  Created by Jeremy Daines on 08/03/2024.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Phylax")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            ProgressView()
                .scaleEffect(1.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradientView())
        .foregroundColor(Color.primary)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LoadingView()
}
