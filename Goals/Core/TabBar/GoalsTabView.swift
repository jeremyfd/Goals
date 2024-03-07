//
//  GoalsTabView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI

struct GoalsTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                }
                .onAppear { selectedTab = 0 }
                .tag(0)
            
            DashboardView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "list.bullet.clipboard.fill" : "list.bullet.clipboard")
                        .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                }
                .onAppear { selectedTab = 1 }
                .tag(1)
            
            AddDummyView(tabIndex: $selectedTab)
                .tabItem { Image(systemName: "plus") }
                .onAppear { selectedTab = 2 }
                .tag(2)
            
            PublicChallengesView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "trophy.fill" : "trophy")
                        .environment(\.symbolVariants, selectedTab == 3 ? .fill : .none)
                }
                .onAppear { selectedTab = 3 }
                .tag(3)
            
            CurrentUserProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                        .environment(\.symbolVariants, selectedTab == 4 ? .fill : .none)
                }
                .onAppear { selectedTab = 4 }
                .tag(4)
        }
        .tint(Color.theme.primaryText)
    }
}


#Preview {
    GoalsTabView()
}
