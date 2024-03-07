//
//  ScheduleView.swift
//  Goals
//
//  Created by Jeremy Daines on 06/03/2024.
//

import SwiftUI

struct ScheduleView: View {
    @StateObject var viewModel = ScheduleViewModel()
    @State private var showReactions = false
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
            
//            ScrollView {
                contentForYourContracts()
//            }
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
        LazyVStack{
            ForEach(sortedStepsByDate, id: \.date) { date, steps in
                Section(header:
                            HStack {
                    Text(date, formatter: DateFormatter.shortDate)
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    Spacer()
                }
                ) {
                    ForEach(steps, id: \.id) { step in
                        if let goalWithSteps = viewModel.goals.first(where: { $0.goal.id == step.goalID }) {
                            
                            if showReactions {
                                let cellViewModel = GoalViewCellViewModel(goalId: goalWithSteps.goal.id)

                                    ReactionButtonsView(
                                        goalID: goalWithSteps.goal.id,
                                        ownerUid: goalWithSteps.goal.ownerUid,
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
                                    Text("\(goalWithSteps.goal.title)")
                                        .fontWeight(.bold)
                                    HStack {
                                        Text("@\(goalWithSteps.goal.user?.username ?? "Unknown")")
                                        Text("Tier: \(step.tier)")
                                    }
                                }
                                .foregroundStyle(Color.black)
                                .padding()
                                
                                Spacer()
                                
                                Button {
                                    showReactions.toggle()
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
        }
    }
}

private extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
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
