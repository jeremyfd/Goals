//
//  FeedViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 06/02/2024.
//

import Foundation
import Combine
import SwiftUI
import Firebase

@MainActor
class FeedViewModel: ObservableObject {
    @Published var goalsWithEvidences: [(goal: Goal, evidences: [Evidence])] = []
    @Published var currentUser: User?
    @Published var goals = [Goal]()
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
        Task { try await fetchGoals() }
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser
            .sink { [weak self] user in
                self?.currentUser = user
                // Optionally, you can initiate data fetching here if you want to auto-load data when the user is set
                // self?.fetchDataForYourContracts()
            }
            .store(in: &cancellables)
    }
    
    func fetchDataForYourContracts() {
        guard let uid = currentUser?.id else { return }

        Task {
            do {
                let goalIDs = try await GoalService.fetchPartnerGoalIDs(uid: uid)
                var tempGoalsWithEvidences: [(Goal, [Evidence])] = []

                for goalID in goalIDs {
                    let goal = try await GoalService.fetchGoalDetails(goalId: goalID)
                    let evidences = try await EvidenceService.fetchEvidences(forGoalId: goal.id)
                    tempGoalsWithEvidences.append((goal, evidences))
                }

                DispatchQueue.main.async {
                    self.goalsWithEvidences = tempGoalsWithEvidences
                }
            } catch {
                print("Error fetching goals and evidences: \(error)")
            }
        }
    }

    func fetchDataForYourFriendsContracts() {
        guard let uid = currentUser?.id else { return }

        Task {
            do {
                let goalIDs = try await GoalService.fetchFriendGoalIDs(uid: uid)
                var tempGoalsWithEvidences: [(Goal, [Evidence])] = []

                for goalID in goalIDs {
                    let goal = try await GoalService.fetchGoalDetails(goalId: goalID)
                    let evidences = try await EvidenceService.fetchEvidences(forGoalId: goal.id)
                    tempGoalsWithEvidences.append((goal, evidences))
                }

                DispatchQueue.main.async {
                    self.goalsWithEvidences = tempGoalsWithEvidences
                }
            } catch {
                print("Error fetching goals and evidences: \(error)")
            }
        }
    }
    
    private func fetchGoalIDs() async -> [String] {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No current user UID found")
            return []
        }
//        print("DEBUG: Current user UID: \(uid)")
        isLoading = true
        
        let snapshot = try? await FirestoreConstants
            .UserCollection
            .document(uid)
            .collection("user-feed")
            .getDocuments()
        
        let ids = snapshot?.documents.map({ $0.documentID }) ?? []
//        print("DEBUG: Fetched goal IDs: \(ids)")
        return ids
    }
    
    func fetchGoals() async {
        do {
//            print("DEBUG: Fetching goals")
            let goalIDs = await fetchGoalIDs()
//            print("DEBUG: Goal IDs fetched: \(goalIDs)")

            var fetchedGoals = [Goal]()
            try await withThrowingTaskGroup(of: Goal.self, body: { group in
                for id in goalIDs {
                    group.addTask { return try await GoalService.fetchGoal(goalId: id) }
                }

                for try await goal in group {
                    let enrichedGoal = try await fetchGoalUserData(goal: goal)
                    fetchedGoals.append(enrichedGoal)
                }
            })
            self.goals = fetchedGoals.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
            isLoading = false
//            print("DEBUG: Finished fetching goals, total count: \(self.goals.count)")
        } catch {
            print("DEBUG: Error fetching goals: \(error)")
            // Handle the error appropriately, maybe set an error state to show in UI
        }
    }
    
    private func fetchGoalUserData(goal: Goal) async throws -> Goal {
        var result = goal
    
        async let user = try await UserService.fetchUser(withUid: goal.ownerUid)
        result.user = try await user
        
        return result
    }
}
