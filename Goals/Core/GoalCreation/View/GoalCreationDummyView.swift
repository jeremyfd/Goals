//
//  GoalCreationDummyView.swift
//  Goals
//
//  Created by Work on 21/01/2024.
//

import SwiftUI

struct GoalCreationDummyView: View {
    @State private var presented = false
    @Binding var tabIndex: Int
    
    var body: some View {
        VStack { }
        .onAppear { presented = true }
        .sheet(isPresented: $presented) {
            GoalCreationView(tabIndex: $tabIndex)
        }
    }
}

//#Preview {
//    GoalCreationDummyView()
//}
