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
    // Adjust the tuple to include the Goal object
    @Published var allStepsWithEvidences: [(step: Step, evidences: [Evidence], goal: Goal)] = []

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
                var allStepsWithEvidences: [(step: Step, evidences: [Evidence])] = []

                for goalID in goalIDs {
                    let steps = try await StepService.fetchSteps(forGoalId: goalID)
                    let submittedSteps = steps.filter { $0.isSubmitted }

                    for step in submittedSteps {
                        let evidences = try await EvidenceService.fetchEvidences(forStepId: step.id)
                        if !evidences.isEmpty {
                            allStepsWithEvidences.append((step: step, evidences: evidences))
                        }
                    }
                }

            } catch {
                print("Error fetching steps and evidences: \(error)")
            }
        }
    }

    func fetchDataForYourFriendsContracts() {
        guard let uid = currentUser?.id else { return }

        Task {
            do {
                let goalIDs = try await GoalService.fetchFriendGoalIDs(uid: uid)
                var tempAllStepsWithEvidences: [(step: Step, evidences: [Evidence], goal: Goal)] = []

                for goalID in goalIDs {
                    // Use fetchGoal here to fetch the specific Goal for the current goalID
                    let goal = try await GoalService.fetchGoal(goalId: goalID)
                    let steps = try await StepService.fetchSteps(forGoalId: goalID)
                    let submittedSteps = steps.filter { $0.isSubmitted }

                    for step in submittedSteps {
                        let evidences = try await EvidenceService.fetchEvidences(forStepId: step.id)
                        if !evidences.isEmpty {
                            // Append the tuple including the fetched goal
                            tempAllStepsWithEvidences.append((step: step, evidences: evidences, goal: goal))
                        }
                    }
                }
                
                // Ensure to perform UI updates on the main thread
                DispatchQueue.main.async {
                    self.allStepsWithEvidences = tempAllStepsWithEvidences
                }

            } catch {
                print("Error fetching steps and evidences: \(error)")
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
