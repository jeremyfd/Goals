//
//  FriendsTabView.swift
//  Goals
//
//  Created by Work on 30/12/2023.
//

import SwiftUI

struct FriendsTabView: View {
    @State private var searchText = ""
    @State private var selectedTab = "Friends"

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.9)]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea()
                
                VStack {
                    HStack {
                        TextField("Add or search for friends", text: $searchText)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Custom pill-shaped tab switcher placed at the top
                    PillTabSwitcher(selectedTab: $selectedTab)
                        .padding(.vertical)
                    
                    // TabView for swipe functionality
                    TabView(selection: $selectedTab) {
                        FriendSuggestionsView()
                            .tag("Suggestions") // Identifier for the tab
                        
                        CurrentFriendsView()
                            .tag("Friends") // Identifier for the tab
                        
                        SentRequestsView()
                            .tag("Requests") // Identifier for the tab
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hides the default tab bar
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}

struct PillTabSwitcher: View {
    @Binding var selectedTab: String
    private let tabs = ["Suggestions", "Friends", "Requests"]

    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                Text(tab)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(self.selectedTab == tab ? Color.black : Color.clear)
                    .foregroundColor(self.selectedTab == tab ? .white : .black)
                    .clipShape(Capsule())
                    .onTapGesture {
                        withAnimation {
                            self.selectedTab = tab
                        }
                    }
            }
        }
        .background(Color.gray.opacity(0.2))
        .clipShape(Capsule())
    }
}

#Preview {
    FriendsTabView()
}
