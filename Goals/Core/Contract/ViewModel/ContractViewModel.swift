//
//  ContractViewModel.swift
//  Goals
//
//  Created by Work on 21/01/2024.
//

import Foundation
import Firebase

@MainActor
class ContractViewModel: ObservableObject {
    @Published var goals = [Goal]()
    @Published var isLoading = false
    
    
    init() {
//        print("DEBUG: ContractViewModel initialized")
        Task { try await fetchGoals() }
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

