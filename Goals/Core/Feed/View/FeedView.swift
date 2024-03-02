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
                        
                        if !viewModel.goals.isEmpty {
                            
                            Text("Calendar - Last Day!")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.leading)
                            
                            ScrollView (.horizontal, showsIndicators: false){
                                LazyVGrid(columns: columns, spacing: 10) {
                                    ForEach(viewModel.goals, id: \.id) { goal in
                                        CalendarViewFeedView(goal: goal, currentUser: currentUser)
                                            .padding(.leading, viewModel.goals.count > 1 ? 8 : UIScreen.main.bounds.width / 2 - ((UIScreen.main.bounds.width - 250) / 2))
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
