//
//  TierRankingsViewModel.swift
//  Goals
//
//  Created by Work on 21/01/2024.
//

import Foundation
import Combine
import SwiftUI
import Firebase

@MainActor
class TierRankingsViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var goals = [Goal]()
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscribers()
    }

    @Published var selectedFilter: FeedFilterViewModel = .all {
        didSet {
            updateGoalsBasedOnFilter()
//            print("DEBUG: Selected filter changed to \(selectedFilter)")
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
                var fetchedGoals = [Goal]()
                for goalID in goalIDs {
                    var goal = try await GoalService.fetchGoalDetails(goalId: goalID)
                    // Fetch the user data for this goal, assuming a function to fetch a user by their UID.
                    if let ownerUser = try? await UserService.fetchUser(withUid: goal.ownerUid) {
                        goal.user = ownerUser
                    }
                    fetchedGoals.append(goal)
                }
                
                self.goals = fetchedGoals.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
//                print("DEBUG: Finished fetching goals. Total goals: \(self.goals.count)")
            } catch {
                print("Error fetching goals: \(error)")
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
