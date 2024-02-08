//
//  UserContentListView.swift
//  Goals
//
//  Created by Jeremy Daines on 05/02/2024.
//

import SwiftUI

struct UserContentListView: View {
    @StateObject var viewModel: UserContentListViewModel

    init(user: User) {
        self._viewModel = StateObject(wrappedValue: UserContentListViewModel(user: user))
    }

    var body: some View {
        VStack {
            LazyVStack {
                if viewModel.goals.isEmpty {
                    Text(viewModel.noContentText())
                        .font(.headline)
                } else {
                    ForEach(viewModel.goals) { goal in
                        GoalViewCell(goal: goal)
                    }
                    .transition(.move(edge: .leading))
                }
            }
            .padding(.vertical, 8)
        }
    }
}


//#Preview {
//    UserContentListView()
//}
