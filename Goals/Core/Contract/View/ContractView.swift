//
//  ContractView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//


import SwiftUI

struct ContractView: View {
    
    @Namespace var animation
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.9)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            .overlay(
                VStack {
                    Picker("", selection: $selectedTab) {
                        Text("My Contracts").tag(0)
                        Text("Friends Contracts").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    TabView(selection: $selectedTab) {
                        ScrollView {
                            contentForYourContracts()
                        }
                        .tag(0)
                        
                        ScrollView {
                            contentForFriendsContracts()
                        }
                        .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .navigationTitle("Contracts")
                .navigationBarTitleDisplayMode(.inline)
            )
        }
    }

    func contentForYourContracts() -> some View {
        VStack {
            
            HStack{
                Text("Today")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 55)
                Spacer()
            }
            .padding(.top)
            
            LazyVStack(spacing: 20){
                ForEach(0 ... 10, id: \.self) { thread in
                    CollapsedGoalView()
                }
            }
        }
    }

    func contentForFriendsContracts() -> some View {
        VStack {
            
            HStack{
                Text("Today")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 55)
                Spacer()
            }
            .padding(.top)
            
            LazyVStack(spacing: 20){
                ForEach(0 ... 10, id: \.self) { thread in
                    CollapsedGoalView()
                }
            }
        }
    }
}

#Preview {
    ContractView()
}
