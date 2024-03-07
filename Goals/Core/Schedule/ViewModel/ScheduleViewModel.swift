//
//  ScheduleViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 06/03/2024.
//
import Foundation
import Combine
import SwiftUI
import Firebase

@MainActor
class ScheduleViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var goals = [(goal: Goal, steps: [Step])]()
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscribers()
    }

    @Published var selectedFilter: FeedFilterViewModel = .all {
        didSet {
            updateGoalsBasedOnFilter()
        }
    }

    private func updateGoalsBasedOnFilter() {
        switch selectedFilter {
        case .all:
            fetchDataForYourFriendsContracts()
        case .partner:
            fetchDataForYourContracts()
        }
    }

    private func setupSubscribers() {
        UserService.shared.$currentUser
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &cancellables)
    }

    private func fetchData(goalIDsFetch: @escaping (String) async throws -> [String]) {
        guard let uid = currentUser?.id else { return }

        Task {
            do {
                let goalIDs = try await goalIDsFetch(uid)
                var fetchedGoals = [(goal: Goal, steps: [Step])]()
                for goalID in goalIDs {
                    var goal = try await GoalService.fetchGoalDetails(goalId: goalID)
                    // Fetch the user data for this goal
                    if let ownerUser = try? await UserService.fetchUser(withUid: goal.ownerUid) {
                        goal.user = ownerUser
                    }
                    // Now fetch steps for this goal
                    let steps = try await StepService.fetchSteps(forGoalId: goalID)
                    fetchedGoals.append((goal: goal, steps: steps))
                }
                
                self.goals = fetchedGoals.sorted(by: { $0.goal.timestamp.dateValue() > $1.goal.timestamp.dateValue() })
            } catch {
                print("Error fetching goals and steps: \(error)")
            }
        }
    }

    func fetchDataForYourContracts() {
        fetchData(goalIDsFetch: GoalService.fetchPartnerGoalIDs)
    }

    func fetchDataForYourFriendsContracts() {
        fetchData(goalIDsFetch: GoalService.fetchFriendGoalIDs)
    }
}
