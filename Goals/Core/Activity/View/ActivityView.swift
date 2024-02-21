//
//  ActivityView.swift
//  Goals
//
//  Created by Jeremy Daines on 21/02/2024.
//

import SwiftUI

struct ActivityView: View {
    @StateObject var viewModel = ActivityViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    ActivityFilterView(selectedFilter: $viewModel.selectedFilter)
                        .padding(.vertical)

                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.notifications) { activityModel in
                            if activityModel.type != .friend {
                                NavigationLink(value: activityModel) {
                                    ActivityRowView(model: activityModel)
                                }
                            } else {
                                NavigationLink(value: activityModel.user) {
                                    ActivityRowView(model: activityModel)
                                }
                            }
                        }
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Activity")
            .navigationDestination(for: Activity.self, destination: { model in
                if let goal = model.goal {
                    ExpandedGoalView(goal: goal)
                }
            })
            .navigationDestination(for: User.self, destination: { user in
                UserProfileView(user: user)
            })
        }
    }
}

//struct ActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityView()
//    }
//}
