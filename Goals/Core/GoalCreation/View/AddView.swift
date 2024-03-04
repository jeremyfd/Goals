//
//  AddView.swift
//  Goals
//
//  Created by Jeremy Daines on 08/02/2024.
//

import SwiftUI

struct AddView: View {
    @Binding var tabIndex: Int
    @State private var showGoalCreationView = false

    var body: some View {
        VStack {
            
            Button(action: {
                showGoalCreationView = true
            }, label: {
                Text("Create Goal")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity) // Make button width to match the parent container
                    .background(Color.gray) // Grey background
                    .foregroundColor(.white) // White text
                    .cornerRadius(20)
            })
            
//            Button(action: {
//                
//            }, label: {
//                Text("Submit Evidence")
//                    .fontWeight(.bold)
//                    .padding()
//                    .frame(maxWidth: .infinity) // Make button width to match the parent container
//                    .background(Color.gray) // Grey background
//                    .foregroundColor(.white) // White text
//                    .cornerRadius(20)
//            })
            
            Spacer()
        }
        .background(Color.clear)
        .padding()
        .onDisappear { tabIndex = 0 }
        .sheet(isPresented: $showGoalCreationView) {
            GoalCreationView(tabIndex: $tabIndex)
        }
    }
}

//#Preview {
//    AddView()
//}
