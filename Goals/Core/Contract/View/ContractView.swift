//
//  ContractView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//


import SwiftUI

struct ContractView: View {
    @StateObject var viewModel = ContractViewModel()
    
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
                    .refreshable {
                        Task { try await viewModel.fetchGoals() }
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
                ForEach(viewModel.goals) { goal in
                    CollapsedGoalView(goal: goal)
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
                ForEach(viewModel.goals) { goal in
                    CollapsedGoalView(goal: goal)
                }
            }
        }
    }
}

#Preview {
    ContractView()
}
