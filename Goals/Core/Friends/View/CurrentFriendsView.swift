//
//  CurrentFriendsView.swift
//  Goals
//
//  Created by Work on 30/12/2023.
//

import SwiftUI

struct CurrentFriendsView: View {
    @StateObject var viewModel = CurrentFriendsViewModel()

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
                    NavigationLink(value: friend) {
                        UserCell(viewModel: UserCellViewModel(user: friend))
                    }
                }
            }
            .navigationDestination(for: User.self, destination: { user in
                UserProfileView(user: user)
            })
        }
    }
}

#Preview {
    CurrentFriendsView()
}
