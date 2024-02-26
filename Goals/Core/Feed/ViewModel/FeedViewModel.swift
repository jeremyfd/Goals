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

    
    init() {
        setupSubscribers()
        Task { try await fetchGoals() }
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
                    allEvidencesWithGoal.append(contentsOf: evidences.map { (evidence: $0, goal: enrichedGoal) })
                }
                allEvidencesWithGoal.sort(by: { $0.evidence.timestamp.dateValue() > $1.evidence.timestamp.dateValue() })

                DispatchQueue.main.async {
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
    
//    func nextStepWithin24Hours(for goal: Goal) {
//        // Assuming StepsCalculator is accessible and initialized somewhere within FeedViewModel
//        let stepsCalculator = StepsCalculator() // Ideally, this should be initialized elsewhere and injected
//        
//        let evidences = [] // Fetch or receive as a parameter
//        let steps = stepsCalculator.calculateSteps(goalStartDate: goal.startDate, goalDuration: goal.duration, goalFrequency: goal.frequency, goalTarget: goal.target, evidences: evidences)
//        
//        let calendar = Calendar.current
//        let currentDate = Date()
//        
//        let nextStepWithin24Hours = steps.contains(where: { step in
//            guard let deadline = step.deadline else { return false }
//            let status = StepsCalculator.determineStepStatus(...) // Assuming it's adapted to be accessible
//            let hoursUntilDeadline = calendar.dateComponents([.hour], from: currentDate, to: deadline).hour ?? 0
//            return status == .readyToSubmit && hoursUntilDeadline <= 24
//        })
//    }
}
