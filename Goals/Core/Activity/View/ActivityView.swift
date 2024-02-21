//
//  ActivityView.swift
//  Goals
//
//  Created by Jeremy Daines on 21/02/2024.
//

import SwiftUI

enum ActivityNavigationConfig {
    case activityDetail(Activity)
    case userProfile(User)
}

struct ActivityView: View {
    @StateObject var viewModel = ActivityViewModel()
    @State private var selectedNavigation: ActivityNavigationConfig?
    @State private var isNavigationTriggered: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ActivityFilterView(selectedFilter: $viewModel.selectedFilter)
                        .padding(.vertical)

                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.notifications) { activityModel in
                            if activityModel.type != .friend {
                                Button(action: {
                                    self.selectedNavigation = .activityDetail(activityModel)
                                    self.isNavigationTriggered = true
                                }) {
                                    ActivityRowView(model: activityModel)
                                }
                            } else if let user = activityModel.user {
                                Button(action: {
                                    self.selectedNavigation = .userProfile(user)
                                    self.isNavigationTriggered = true
                                }) {
                                    ActivityRowView(model: activityModel)
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
            }
            // Conditional NavigationLinks for each case
            .background(
                EmptyView()
                    .background(
                        NavigationLink(
                            destination: destinationView(),
                            isActive: $isNavigationTriggered
                        ) { EmptyView() }
                    )
            )
        }
    }

        @ViewBuilder
        private func destinationView() -> some View {
            if let navigation = selectedNavigation {
                switch navigation {
                case .activityDetail(let activity):
                    if let goal = activity.goal {
                        ExpandedGoalView(goal: goal)
                            .onAppear {
                                self.isNavigationTriggered = false
                            }
                    } else {
                        Text("Goal details are not available.")
                            .onAppear {
                                self.isNavigationTriggered = false
                            }
                    }
                case .userProfile(let user):
                    UserProfileView(user: user)
                        .onAppear {
                            self.isNavigationTriggered = false
                        }
                }
            } else {
                EmptyView()
            }
        }

}


//struct ActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityView()
//    }
//}

//    @ViewBuilder
//    private func destinationView() -> some View {
//        if let navigation = selectedNavigation {
//            switch navigation {
//            case .activityDetail(let activity):
//                if let goal = activity.goal {
//                    ExpandedGoalView(goal: goal)
//                } else {
//                    Text("Goal details are not available.")
//                }
//            case .userProfile(let user):
//                UserProfileView(user: user)
//            }
//        } else {
//            EmptyView()
//        }
//    }
