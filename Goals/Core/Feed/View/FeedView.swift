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
                VStack(alignment: .leading) {
                    
                    HStack(alignment: .center) {
                        
                        Text("My Goals")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.leading)
                        
                        Spacer()
                        
                        NavigationLink(destination: FriendsTabView()) {
                            Image(systemName: "person.2.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, height: 35)
                                .padding(.horizontal)
                        }
                    }
                    
                    if let user = currentUser {
                        FeedSelfGoalsView(user: user)
                            .padding(.horizontal)
                    }
                    
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
                
            )
        }
        .onChange(of: selectedTab) { _ in
            fetchDataBasedOnSelectedTab()
        }
        .onAppear {
            fetchDataBasedOnSelectedTab()
        }
    }
    
    func fetchDataBasedOnSelectedTab() {
        if selectedTab == 0 {
            viewModel.fetchDataForYourContracts()
        } else if selectedTab == 1 {
            viewModel.fetchDataForYourFriendsContracts()
        }
    }
    
    
    func contentForYourContracts() -> some View {
        VStack {
            
            HStack{
                Text("Today")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
            }
            
            LazyVStack(spacing: 30) {
                ForEach(viewModel.goalsWithEvidences, id: \.goal.id) { pair in
                    ForEach(pair.evidences, id: \.id) { evidence in
                        EvidenceViewFeedView(evidence: evidence, goal: pair.goal, currentUser: currentUser)
                    }
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
                    .padding(.leading)
                Spacer()
            }
            
            LazyVStack(spacing: 30) {
                ForEach(viewModel.goalsWithEvidences, id: \.goal.id) { pair in
                    ForEach(pair.evidences, id: \.id) { evidence in
                        EvidenceViewFeedView(evidence: evidence, goal: pair.goal, currentUser: currentUser)
                    }
                }
            }
            
        }
    }
}

#Preview {
    FeedView()
}
