//
//  FeedView.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

import SwiftUI

struct FeedView: View {
    var body: some View {
        Text("This is the Feed")
        
        Button("Log Out") {
            AuthService.shared.signOut()
        }
        .font(.subheadline)
        .padding(.top)
    }
}

#Preview {
    FeedView()
}
