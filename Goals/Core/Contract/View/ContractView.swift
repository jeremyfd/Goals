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
                    // Directly display content for "My Contracts"
                    ScrollView {                        
                        contentForYourContracts()
                    }
                    .refreshable {
                        viewModel.fetchDataForYourFriendsContracts()
                    }
                }
                .navigationTitle("Contracts")
                .navigationBarTitleDisplayMode(.inline)
            )
        }
        .onAppear {
            viewModel.fetchDataForYourFriendsContracts()
        }
    }

    func contentForYourContracts() -> some View {
        
        VStack {
            
            FeedFilterView(selectedFilter: $viewModel.selectedFilter)
                .padding(.vertical)
            
            HStack{
                Text("Today")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 55)
                Spacer()
            }
            
            LazyVStack(spacing: 20){
                ForEach(viewModel.goals) { goal in
                    CollapsedGoalViewCell(goal: goal)
                }
            }
        }
    }
}

#Preview {
    ContractView()
}
