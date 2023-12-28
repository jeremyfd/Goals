//
//  FeedView.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

//Color(hex: "#BC5216")

import SwiftUI

struct FeedView: View {
    
    @Namespace var animation
    @State private var selectedTab: String = "Your Contracts"
    
    var body: some View {
        
        NavigationStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.9)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            .overlay(
                ScrollView {
                    VStack{
                        HStack{
                            // Your Contracts tab
                            Text("My Contracts")
                                .font(.title3)
                                .fontWeight(selectedTab == "Your Contracts" ? .bold : .none)
                                .foregroundColor(selectedTab == "Your Contracts" ? .black : .gray)
                                .fixedSize(horizontal: true, vertical: false) // Prevent text wrapping
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = "Your Contracts"
                                    }
                                }
                                .padding(.horizontal)
                            
                            
                            // Friends Contracts tab
                            Text("Friends Contracts")
                                .font(.title3)
                                .fontWeight(selectedTab == "Friends Contracts" ? .bold : .none)
                                .foregroundColor(selectedTab == "Friends Contracts" ? .black : .gray)
                                .fixedSize(horizontal: true, vertical: false) // Prevent text wrapping
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = "Friends Contracts"
                                    }
                                }
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 4)
                        
                        HStack{
                            Text("Today")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.leading, 55)
                            Spacer()
                        }
                        
                        VStack{
                            Image("gymphoto")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height/1.75)
                                .cornerRadius(40)
                            
                            Button {
                                
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
                        
                        Spacer()
                    }
                    .navigationTitle("Feed")
                    .navigationBarTitleDisplayMode(.inline)
                    
                }
            )
        }
    }
}

#Preview {
    FeedView()
}
