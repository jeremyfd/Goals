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
                    if let ownerUser = try? await UserService.fetchUser(withUid: goal.ownerUid) {
                        goal.user = ownerUser
                    }
                    fetchedGoals.append(goal)
                }
                
                // No need to sort by timestamp unless you want the newest goals first within the same progress level
                self.goals = fetchedGoals.sorted {
                    ($0.tier, $0.currentCount) > ($1.tier, $1.currentCount)
                }
            } catch {
                print("Error fetching goals: \(error)")
            }
        }
    }


    func fetchDataForYourContracts() {
        fetchData(goalIDsFetch: GoalService.fetchPartnerGoalIDs)
    }

    func fetchDataForYourFriendsContracts() {
        guard let uid = currentUser?.id else { return }

        Task {
            do {
                // Fetch goal IDs from the current user's friends
                let friendGoalIDs = try await GoalService.fetchFriendGoalIDs(uid: uid)
                // Fetch goal IDs from the current user
                let userGoalIDs = try await GoalService.fetchUserGoalIDs(uid: uid)
                
                // Combine both sets of goal IDs
                let combinedGoalIDs = Array(Set(friendGoalIDs + userGoalIDs))
                
                var fetchedGoals = [Goal]()
                for goalID in combinedGoalIDs {
                    var goal = try await GoalService.fetchGoalDetails(goalId: goalID)
                    if let ownerUser = try? await UserService.fetchUser(withUid: goal.ownerUid) {
                        goal.user = ownerUser
                    }
                    fetchedGoals.append(goal)
                }
                
                // Sorting the combined list of goals
                self.goals = fetchedGoals.sorted {
                    ($0.tier, $0.currentCount) > ($1.tier, $1.currentCount)
                }
            } catch {
                print("Error fetching goals: \(error)")
            }
        }
    }

}
