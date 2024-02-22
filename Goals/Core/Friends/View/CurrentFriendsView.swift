//
//  CurrentFriendsView.swift
//  Goals
//
//  Created by Work on 30/12/2023.
//

import SwiftUI

struct CurrentFriendsView: View {
    @StateObject var viewModel = CurrentFriendsViewModel()
    @State private var selectedUser: User? // Keeps track of the selected user
    @State private var isNavigationTriggered: Bool = false // Controls navigation triggering

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("My Friends (\(viewModel.friends.count))")
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()

                ForEach(viewModel.friends, id: \.id) { friend in
                    NavigationLink(destination: UserProfileView(user: friend)) {
                        UserCell(viewModel: UserCellViewModel(user: friend))
                    }
                }

            }
        }
        .background(
            // Safely navigate to UserProfileView if selectedUser is not nil
            Group {
                if let user = selectedUser, isNavigationTriggered {
                    NavigationLink(
                        destination: UserProfileView(user: user),
                        isActive: $isNavigationTriggered
                    ) { EmptyView() }
                }
            }
        )
    }
}

#Preview {
    CurrentFriendsView()
}
