//
//  GoalCreationView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI

struct GoalCreationView: View {
    @State private var goalName = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.9)]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea()
                
                VStack {
                    Text("Create your Goal")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    VStack{
                        HStack {
                            Text("Name")
                            
                            Spacer()
                            
                            TextField("Goal name...", text: $goalName)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        HStack {
                            Text("Partner")
                            
                            Spacer()
                            
                            TextField("Partner username...", text: $goalName)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        HStack {
                            Text("Frequency")
                            
                            Spacer()
                            
                            TextField("Partner username...", text: $goalName)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            
                        }, label: {
                            Text("Create Goal")
                        })
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}


#Preview {
    GoalCreationView()
}
