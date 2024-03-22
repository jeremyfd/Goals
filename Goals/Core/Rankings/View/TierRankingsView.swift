//
//  TierRankingsView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI


struct TierRankingsView: View {
    @StateObject var viewModel = TierRankingsViewModel()
    @Namespace var animation
    @State private var sortAscending: Bool = false
    
    var body: some View {
        VStack {
            FeedFilterView(selectedFilter: $viewModel.selectedFilter)
                .padding(.top)
            
            Button(action: {
                withAnimation {
                    sortAscending.toggle()
                }
            }) {
                HStack {
                    Spacer()
                    Text("Sort")
                        .fontWeight(.bold)
                    Image(systemName: sortAscending ? "arrow.down" : "arrow.up") // Change icon based on sort direction
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
        .background(LinearGradientView())
        .navigationTitle("Tier Rankings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchDataForYourFriendsContracts()
        }
    }
    
    private var rankedGoals: [(rank: Int, goal: Goal)] {
        let sortedGoalsByHighest = viewModel.goals.sorted { $0.currentCount > $1.currentCount }
        return sortedGoalsByHighest.enumerated().map { (index, goal) in
            (rank: index + 1, goal: goal)
        }
    }
    
    private func sortedAndGroupedGoals() -> [(key: Int, value: [(rank: Int, goal: Goal)])] {
        let displayOrderGoals = sortAscending ? rankedGoals.reversed() : rankedGoals
        
        let groupedRankedGoals = Dictionary(grouping: displayOrderGoals) { $0.goal.tier }
        let sortedGroupedKeys = groupedRankedGoals.keys.sorted(by: sortAscending ? (<) : (>))
        
        return sortedGroupedKeys.map { key in
            (key, groupedRankedGoals[key] ?? [])
        }
    }
    
    func contentForYourContracts() -> some View {
        VStack {
            let sortedAndGrouped = sortedAndGroupedGoals()
            
            if sortedAndGrouped.isEmpty {
                Text("No goals yet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
            } else {
                ForEach(sortedAndGrouped, id: \.key) { tier, goalsInTier in
                    Section(header:
                        HStack {
                            Text("Tier \(tier)")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.leading, 15)
                            Spacer()
                    }
                    ) {
                        LazyVStack(spacing: 20) {
                            ForEach(goalsInTier, id: \.goal.id) { rankedGoal in
                                HStack {
                                    Text("\(rankedGoal.rank). ")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    CollapsedGoalViewCell(goal: rankedGoal.goal)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.bottom)
    }
    
    
    
}


//#Preview {
//    TierRankingsView()
//}
