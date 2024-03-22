//
//  FeedViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 06/02/2024.
//
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
    @Published var currentUser: User?
    @Published var goals = [Goal]()
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    @Published var allEvidencesWithGoal: [(evidence: Evidence, goal: Goal)] = []
    
    var groupedEvidences: [Date: [(evidence: Evidence, goal: Goal)]] {
            Dictionary(grouping: allEvidencesWithGoal, by: { Calendar.current.startOfDay(for: $0.evidence.timestamp.dateValue()) })
        }
        
        var sortedGroupedEvidencesKeys: [Date] {
            groupedEvidences.keys.sorted(by: { $0 > $1 })
        }

    
    init() {
        setupSubscribers()
        Task {
            try await fetchGoals()
            await MainActor.run {
                fetchDataForYourFriendsContracts()
            }
        }
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
//                print("DEBUG: Current user updated: \(String(describing: user))")
            }
            .store(in: &cancellables)
    }
    
    func fetchDataForYourContracts() {
        guard let uid = currentUser?.id else { return }

        Task {
            do {
                let goalIDs = try await GoalService.fetchPartnerGoalIDs(uid: uid)
                var allEvidencesWithGoal: [(evidence: Evidence, goal: Goal)] = []

                for goalID in goalIDs {
                    let goal = try await GoalService.fetchGoalDetails(goalId: goalID)
                    let enrichedGoal = try await fetchGoalUserData(goal: goal)

                    let evidences = try await EvidenceService.fetchEvidences(forGoalId: enrichedGoal.id)
                    // Append each evidence along with its goal to the list
                    allEvidencesWithGoal.append(contentsOf: evidences.map { (evidence: $0, goal: enrichedGoal) })
                }

                // Sort all evidences by timestamp, regardless of their goal
                allEvidencesWithGoal.sort(by: { $0.evidence.timestamp.dateValue() > $1.evidence.timestamp.dateValue() })

                DispatchQueue.main.async {
                    // Here, instead of setting goalsWithEvidences, you'll likely need to adjust your UI to work with this new structure
                    // For example, you might have a new @Published property for allEvidencesWithGoal
                    self.allEvidencesWithGoal = allEvidencesWithGoal
//                    print("DEBUG: Finished fetching user contracts. Total evidences: \(self.allEvidencesWithGoal.count)")
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
                var allEvidencesWithGoal: [(evidence: Evidence, goal: Goal)] = []

                for goalID in goalIDs {
                    let goal = try await GoalService.fetchGoalDetails(goalId: goalID)
                    let enrichedGoal = try await fetchGoalUserData(goal: goal)

                    let evidences = try await EvidenceService.fetchEvidences(forGoalId: enrichedGoal.id)
                    // Append each evidence along with its goal to the list
                    allEvidencesWithGoal.append(contentsOf: evidences.map { (evidence: $0, goal: enrichedGoal) })
                }

                // Sort all evidences by timestamp, regardless of their goal
                allEvidencesWithGoal.sort(by: { $0.evidence.timestamp.dateValue() > $1.evidence.timestamp.dateValue() })

                DispatchQueue.main.async {
                    // Here, instead of setting goalsWithEvidences, you'll likely need to adjust your UI to work with this new structure
                    // For example, you might have a new @Published property for allEvidencesWithGoal
                    self.allEvidencesWithGoal = allEvidencesWithGoal
//                    print("DEBUG: Finished fetching evidences. Total evidences: \(self.allEvidencesWithGoal.count)")
                }
            } catch {
                print("Error fetching goals and evidences: \(error)")
            }
        }
    }

    func fetchGoals() async {
        do {
            guard let uid = Auth.auth().currentUser?.uid else {
                print("DEBUG: No current user UID found")
                return
            }
            let fetchedGoals = try await GoalService.fetchUserGoals(uid: uid)

            // Initialize an array to hold enriched goals
            var enrichedGoals = [Goal]()
            
            // Fetch user data for each goal and enrich the goal with it
            for goal in fetchedGoals {
                do {
                    // Fetch user data
                    let user = try await UserService.fetchUser(withUid: goal.ownerUid)
                    // Create a new Goal instance with user data added
                    var enrichedGoal = goal
                    enrichedGoal.user = user
                    // Append the enriched goal to the array
                    enrichedGoals.append(enrichedGoal)
                } catch {
                    print("DEBUG: Error fetching user for goal: \(goal.id), error: \(error)")
                }
            }

            DispatchQueue.main.async {
                // Update your goals property with the enriched goals
                self.goals = enrichedGoals
//                print("DEBUG: Fetched and enriched \(enrichedGoals.count) goals with user data.")
            }
        } catch {
            print("DEBUG: Error fetching goals for the current user: \(error)")
            // Handle the error appropriately, maybe set an error state to show in UI
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
    
    private func fetchGoalUserData(goal: Goal) async throws -> Goal {
        var result = goal
    
        async let user = try await UserService.fetchUser(withUid: goal.ownerUid)
        result.user = try await user
        
        return result
    }
        
}
