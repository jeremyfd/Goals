//
//  FeedSelfGoalsView.swift
//  Goals
//
//  Created by Jeremy Daines on 06/02/2024.
//

import SwiftUI

struct FeedSelfGoalsView: View {
    @StateObject var viewModel: UserContentListViewModel

    init(user: User) {
        self._viewModel = StateObject(wrappedValue: UserContentListViewModel(user: user))
    }

    var body: some View {
        ScrollView(.horizontal) {
            
            HStack(spacing: 10) {
                if viewModel.goals.isEmpty {
                    Text(viewModel.noContentText())
                        .font(.headline)
                        .padding(.bottom)
                } else {
                    ForEach(viewModel.goals) { goal in
                        SelfCollapsedGoalViewCell(goal: goal)
                            .padding(.bottom, 5)
                    }
                    .transition(.move(edge: .leading))
                }
            }
        }
    }
}


//#Preview {
//    FeedSelfGoalsView()
//}
