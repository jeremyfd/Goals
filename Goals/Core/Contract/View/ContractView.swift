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
    @State private var sortAscending: Bool = true // State variable to toggle sort order
    
    var body: some View {
        NavigationStack {
            LinearGradientView()
            .ignoresSafeArea()
            .overlay(
                VStack {
                    
                    FeedFilterView(selectedFilter: $viewModel.selectedFilter)
                    
                    Button(action: {
                        sortAscending.toggle()
                    }) {
                        HStack {
                            Spacer()
                            
                            Text("Sort")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.up.arrow.down")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                            
                        }
                        .padding(.trailing)
                    }
                    
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
            // Group and sort goals by tier
            let groupedGoals = Dictionary(grouping: viewModel.goals) { $0.tier }
            let sortedKeys = groupedGoals.keys.sorted(by: sortAscending ? (<) : (>))
            
            ForEach(sortedKeys, id: \.self) { key in
                
                Section(header:
                    HStack {
                        Text("Tier \(key)")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.leading, 15) // Adjust padding as needed
                        Spacer() // Pushes the text to the left
                    }
                ) {
                    LazyVStack(spacing: 20) {
                        ForEach(groupedGoals[key] ?? []) { goal in
                            CollapsedGoalViewCell(goal: goal)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContractView()
}
