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
    @State private var showGoalCreationView = false
    @Environment(\.colorScheme) var colorScheme
    
    private var currentUser: User? {
        return viewModel.currentUser
    }
    
    @Namespace var animation

    
    var body: some View {
        
        NavigationStack {
            LinearGradientView()
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
                            
                            Text("My Goals")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.leading)
                            
                            if !viewModel.goals.isEmpty {
                                
                                ScrollView (.horizontal, showsIndicators: false){
                                    HStack {
                                        LazyHStack {
                                            ForEach(viewModel.goals, id: \.id) { goal in
                                                CalendarViewFeedView(goal: goal, currentUser: currentUser)

                                            }
                                        }
                                            .padding(.leading)
                                        
                                        Button(action: {
                                            showGoalCreationView = true
                                        }, label: {
                                            
                                            HStack {
                                                Text("Add Goal +")
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .padding()
                                                    .frame(height: 40)
                                                    .foregroundColor(Color.black)
                                                    .background(Color.white)
                                                    .cornerRadius(40)
                                            }
                                        })
                                    }
                                }
                                
                            } else {
                                
                                Button(action: {
                                    showGoalCreationView = true
                                }, label: {
                                    HStack {
                                        Text("Create Goal +")
                                            .fontWeight(.bold)
                                            .padding()
                                            .frame(width: UIScreen.main.bounds.width - 150, height: 40)
                                            .foregroundColor(Color.black)
                                            .background(Color.white)
                                            .cornerRadius(40)

                                    }
                                })
                                .padding(.leading)
                            }
                            
                            Text("My Friends Goals")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.leading)
                                .padding(.top)

                            
                            // Directly integrate the content for "My Contracts"
                            contentForYourContracts()
                            
                        }
                    }
                )
        }
        .onAppear {
            viewModel.fetchDataForYourFriendsContracts()
        }
        .sheet(isPresented: $showGoalCreationView, onDismiss: {
            Task { try await viewModel.fetchGoals() }
        }) {
            GoalCreationView()
        }
        .refreshable {
            Task { try await viewModel.fetchGoals() }
            viewModel.fetchDataForYourFriendsContracts()
        }

    }
    
    func contentForYourContracts() -> some View {
        VStack {
            
            FeedFilterView(selectedFilter: $viewModel.selectedFilter)
            
            if viewModel.sortedGroupedEvidencesKeys.isEmpty {
                // Show a message when there are no evidences
                VStack {
                    Text("No evidences yet")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    VStack {
                        Text("Add more Friends:")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        
                        HStack {
                            Text("Click on this icon at the top ")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Image(systemName: "person.2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                        }
                        .padding(.top, -5)
                    }
                }
                
            } else {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.sortedGroupedEvidencesKeys, id: \.self) { date in
                        Section(header:
                                    HStack {
                            Spacer()

                            Text(date, formatter: DateFormatter.mediumDateFormatter)
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.trailing)
                                .padding(.trailing)

                        }
                            .padding(.top)
                        )
                        {
                            ForEach(viewModel.groupedEvidences[date] ?? [], id: \.evidence.id) { evidenceWithGoal in
                                EvidenceViewFeedView(evidence: evidenceWithGoal.evidence, goal: evidenceWithGoal.goal, currentUser: viewModel.currentUser)
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
        }
    }

}

extension DateFormatter {
    static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
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
