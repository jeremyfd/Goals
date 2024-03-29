//
//  EvidenceViewFeedView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI

struct EvidenceViewFeedView: View {
    @State private var isShowingExpandedGoalView = false
    
    var body: some View {
        VStack{
            
            
            ZStack(alignment: .bottom) {
                Image("gymphoto")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height/2)
                    .cornerRadius(40)
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .center, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
                    )

                HStack {
                    VStack(alignment: .leading) {
                        Text("London")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        Text("15:26 26/12/23")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height/2)
            .cornerRadius(40)

            
            NavigationLink {
//                ExpandedGoalView(goal.goal)
            } label: {
                HStack{
                    VStack(alignment: .leading){
                        Text("Go Gym")
                            .fontWeight(.bold)
                        
                        HStack{
                            Text("@jeremy")
                            Text("Week 2")
                        }
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Image(systemName: "heart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                .background(Color.white)
                .cornerRadius(40) // Rounded corners
            }
            .padding(.horizontal)
            
            Button {
                
            } label: {
                HStack{
                    Text("Confirm?")
                        .font(.title2)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .frame(width: UIScreen.main.bounds.width - 40, height: 40)
                .background(Color.green.opacity(0.7))
                .cornerRadius(40) // Rounded corners
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    EvidenceViewFeedView()
}
