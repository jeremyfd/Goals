//
//  ScheduleView.swift
//  Goals
//
//  Created by Jeremy Daines on 06/03/2024.
//

import SwiftUI

struct ScheduleView: View {
    @StateObject var viewModel = ScheduleViewModel()
    @State private var showingReactionsForStepID: String? = nil
    @Namespace var animation
    @State private var sortAscending: Bool = true
    
    private var sortedStepsByDate: [(date: Date, steps: [Step])] {
        Dictionary(grouping: viewModel.goals.flatMap { $0.steps }) { $0.deadline.startOfDay() }
            .sorted { sortAscending ? $0.key < $1.key : $0.key > $1.key }
            .map { ($0.key, $0.value) }
    }
    
    var body: some View {
        ScrollView {
            FeedFilterView(selectedFilter: $viewModel.selectedFilter)
                .padding(.top)
            
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
            
                contentForYourContracts()
            
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
    
    func contentForYourContracts() -> some View {
        LazyVStack {
            ForEach(sortedStepsByDate, id: \.date) { date, steps in
                StepsSectionView(date: date, steps: steps, showingReactionsForStepID: $showingReactionsForStepID, viewModel: viewModel)
            }
        }
        .padding(.bottom)
    }
}

struct StepsSectionView: View {
    var date: Date
    var steps: [Step]
    @Binding var showingReactionsForStepID: String?
    var viewModel: ScheduleViewModel
    
    var body: some View {
        Section(header: HStack {

            Text(date, formatter: DateFormatter.shortDate)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
                .padding(.leading)
                .padding(.leading)
            
            Spacer()

        }) {
            ForEach(steps, id: \.id) { step in
                // Find the goal tuple that contains the current step
                if let goalTuple = viewModel.goals.first(where: { $0.steps.contains(where: { $0.id == step.id }) }) {
                    StepRowView(step: step, goal: goalTuple, showingReactionsForStepID: $showingReactionsForStepID, viewModel: viewModel)
                }
            }
        }
    }
}


struct StepRowView: View {
    var step: Step
    var goal: (goal: Goal, steps: [Step]) // Pass the whole tuple
    @Binding var showingReactionsForStepID: String? // Use String for ID
    var viewModel: ScheduleViewModel
    
    var body: some View {
        
        NavigationLink {
            ExpandedGoalView(goal: goal.goal)
        } label: {
        VStack {
            // Compare strings directly
            if showingReactionsForStepID == step.id {
                let cellViewModel = GoalViewCellViewModel(goalId: goal.goal.id)
                
                ReactionButtonsView(
                    goalID: goal.goal.id,
                    ownerUid: goal.goal.ownerUid,
                    viewModel: cellViewModel
                )
                .padding(.leading)
                .padding(.vertical, 5)
                .frame(width: UIScreen.main.bounds.width - 40, height: 100)
                .background(Color.white)
                .cornerRadius(30)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(goal.goal.title)")
                        .fontWeight(.bold)
                    HStack {
                        Text("@\(goal.goal.user?.username ?? "Unknown")")
                        Text("Tier: \(step.tier)")
                    }
                }
                .foregroundStyle(Color.black)
                .padding()
                
                Spacer()
                
                Button {
                    // Toggle ID or nil
                    showingReactionsForStepID = showingReactionsForStepID == step.id ? nil : step.id
                } label: {
                    Image(systemName: "heart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                }
                
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
            .cornerRadius(40)
        }
    }
    }
}





private extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self) - 1
    }
}

private extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}


//#Preview {
//    ScheduleView()
//}
