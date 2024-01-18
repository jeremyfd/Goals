//
//  GoalCreationView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI

struct GoalCreationView: View {
    @State private var goalName = ""
    @State private var goalPartner = ""
    @State private var goalFrequency = ""

    
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
                            Text("Name:")
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            TextField("Goal name...", text: $goalName)
                                .padding(5)
//                                .background(Color(.systemGray6))
//                                .cornerRadius(8)
                        }
                        HStack {
                            Text("Partner:")
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            TextField("Partner username...", text: $goalPartner)
                                .padding(5)
//                                .background(Color(.systemGray6))
//                                .cornerRadius(8)
                        }
                        HStack {
                            Text("Frequency:")
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            TextField("Partner username...", text: $goalFrequency)
                                .padding(5)
//                                .background(Color(.systemGray6))
//                                .cornerRadius(8)
                        }
                        
                        VStack (alignment: .leading, spacing: 15){
                            Text("You will not be able to delete this goal and your friends will keep you accountable to it.")
                            Text("Please create your goal wisely.")
                        }
                        .padding(.top)
                        
                        Button(action: {
                            
                        }, label: {
                            Text("Create Goal")
                                .foregroundStyle(Color.black)
                                .fontWeight(.bold)

                        })
                        .padding(.top)
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
