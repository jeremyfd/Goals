//
//  FriendsTabView.swift
//  Goals
//
//  Created by Work on 30/12/2023.
//

import SwiftUI

struct FriendsTabView: View {
    @StateObject private var viewModel = FriendsTabViewModel()
    @State private var selectedTab = "Friends"
    @FocusState private var isTextFieldFocused: Bool

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
                        TextField("Add or search for friends", text: $viewModel.searchText)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($isTextFieldFocused)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        if !viewModel.searchText.isEmpty {
                            Button("Cancel") {
                                viewModel.searchText = ""
                                isTextFieldFocused = false
                            }
                            .padding(.horizontal)
                            .transition(.move(edge: .trailing))
                            .animation(.default, value: viewModel.searchText)
                        }
                    }
                    .padding(.horizontal)

                    if viewModel.searchText.isEmpty {
                        PillTabSwitcher(selectedTab: $selectedTab)
                            .padding(.vertical)

                        TabView(selection: $selectedTab) {
                            FriendSuggestionsView().tag("Suggestions")
                            CurrentFriendsView().tag("Friends")
                            FriendRequestsView().tag("Requests")
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack {
                                ForEach(viewModel.searchResults, id: \.id) { user in
                                    UserCell(viewModel: UserCellViewModel(user: user))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
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
