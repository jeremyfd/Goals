//
//  FriendRequestsView.swift
//  Goals
//
//  Created by Work on 30/12/2023.
//

import SwiftUI

struct FriendRequestsView: View {
    @StateObject var viewModel = FriendRequestsViewModel()

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.receivedRequests, id: \.id) { user in
                    UserCell(viewModel: UserCellViewModel(user: user))
                }
            }
        }
    }
}


#Preview {
    FriendRequestsView()
}
