//
//  FeedView.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

//Color(hex: "#BC5216")

import SwiftUI

struct FeedView: View {
    @StateObject var viewModel = FeedViewModel()
    
    private var currentUser: User? {
        return viewModel.currentUser
    }
    
    @Namespace var animation
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
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
                    VStack(alignment: .leading) {
                        
                        HStack(alignment: .center) {
                            Text("Phylax")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.leading)
                            
                            Spacer()
                            
                            NavigationLink(destination: ActivityView()) {
                                Image(systemName: "heart")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                            }
                            
                            NavigationLink(destination: FriendsTabView()) {
                                Image(systemName: "person.2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                                    .padding(.horizontal)
                            }
                        }
                        
                        Text("Calendar - Last Day!")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.leading)
                        
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: 10) {
                                // Here, instead of using viewModel.goals, we filter for today's goals like in AgendaView
                                let today = Date()
                                let calendar = Calendar.current
                                // Filter to include only today's date
                                let stepsForToday = viewModel.stepsByDate.filter { date, _ in
                                    calendar.isDate(date, inSameDayAs: today)
                                }
                                let totalGoalsForToday = stepsForToday.values.flatMap { $0 }.count

                                ForEach(stepsForToday.keys.sorted(by: >), id: \.self) { date in
                                    ForEach(stepsForToday[date, default: []]
                                        .map({ StepGoalTuple(step: $0.0, goal: $0.1) }), id: \.id) { stepGoalTuple in
                                            HStack{
                                                NavigationLink {
                                                    ExpandedGoalView(goal: stepGoalTuple.goal)
                                                } label: {
                                                    HStack {
                                                        CircularProfileImageView(user: stepGoalTuple.goal.user, size: .small)
                                                        
                                                        Text(stepGoalTuple.goal.title)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.black)
                                                        
                                                        Spacer()
                                                        
                                                    }
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 1)
                                                    .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                                                    .background(Color.white)
                                                    .cornerRadius(40)
                                                }
                                            }
                                            .padding(.leading, totalGoalsForToday > 1 ? 8 : UIScreen.main.bounds.width / 2 - ((UIScreen.main.bounds.width - 250) / 2))
                                            .onAppear{
                                                print("Count of stepsForToday.keys: \(totalGoalsForToday)")
                                            }
                                        }
                                }
                            }
                        }
                        
                        
                        // Directly integrate the content for "My Contracts"
                        contentForYourContracts()
                        
                    }
                }
            )
        }
        .onAppear {
            viewModel.fetchDataForYourFriendsContracts()
            viewModel.fetchDataForYourFriendsContractsCalendar()
        }
        .refreshable {
            viewModel.fetchDataForYourFriendsContracts()
            viewModel.fetchDataForYourFriendsContractsCalendar()
        }
    }
    
    func contentForYourContracts() -> some View {
        VStack {
            
            FeedFilterView(selectedFilter: $viewModel.selectedFilter)
                .padding(.vertical)
            
            HStack{
                Text("Today")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
            }
            
            LazyVStack(spacing: 30) {
                ForEach(viewModel.allEvidencesWithGoal, id: \.evidence.id) { evidenceWithGoal in
                    EvidenceViewFeedView(evidence: evidenceWithGoal.evidence, goal: evidenceWithGoal.goal, currentUser: currentUser)
                }
            }
        }
    }
}

//#Preview {
//    FeedView()
//}

//struct FeedView_Previews: PreviewProvider {
//    static var previews: some View {
//        let viewModel = FeedViewModel()
//        viewModel.currentUser = DeveloperPreview.shared.user // Set the current user with mock data
//        viewModel.goalsWithEvidences = [(DeveloperPreview.shared.goal, [DeveloperPreview.shared.evidence])] // Set mock goals and evidences
//        return FeedView(viewModel: viewModel) // Initialize your view with the view model
//    }
//}
