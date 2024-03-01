//
//  ExpandedGoalViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 07/02/2024.
//

import Foundation
import Combine

@MainActor
class ExpandedGoalViewModel: ObservableObject {
    @Published var partnerUser: User?
    @Published var currentUser: User?
    @Published var goal: Goal?
    @Published var cycles: [Cycle] = []
    @Published var steps: [Step] = []
    @Published var evidences: [Evidence] = []
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser
            .sink { [weak self] user in
                self?.currentUser = user               
            }.store(in: &cancellables)
    }
    
    func fetchPartnerUser(partnerUid: String) {
        Task {
            do {
                let user = try await UserService.fetchUser(withUid: partnerUid)
                DispatchQueue.main.async {
                    self.partnerUser = user
                }
            } catch {
                print("Error fetching partner user: \(error)")
            }
        }
    }
    
    func deleteGoal(goalId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await GoalService.deleteGoal(goalId: goalId)
                // Call the completion handler to indicate success
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                // Call the completion handler with the error if deletion fails
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func refreshGoalDetails(goalId: String) async {
        do {
            let refreshedGoal = try await GoalService.fetchGoalDetails(goalId: goalId)
            DispatchQueue.main.async {
                self.goal = refreshedGoal
                // Perform any other state updates needed in response to the refreshed goal
            }
        } catch {
            print("Failed to refresh goal details:", error.localizedDescription)
            // Handle errors, possibly by updating another @Published property to show an error message
        }
    }
    
    func fetchCyclesForCurrentGoal() {
        guard let goalId = goal?.id else {
            print("Goal ID is not available")
            return
        }
        print("DEBUG: Fetching cycles for goal ID: \(goalId)")
        Task {
            isLoading = true
            do {
                let fetchedCycles = try await CycleService.fetchCycles(forGoalId: goalId)
                DispatchQueue.main.async {
                    self.cycles = fetchedCycles
                    self.isLoading = false
                    print("DEBUG: Fetched cycles: \(fetchedCycles.count), updating viewModel.cycles")
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false // Make sure to set this in case of an error as well
                    print("Error fetching cycles for goal: \(error.localizedDescription)")
                }            }
        }
    }
    
    func fetchStepsForCurrentGoal() {
        guard let goalId = goal?.id else {
            print("Goal ID is not available")
            return
        }
        print("DEBUG: Fetching steps for goal ID: \(goalId)")
        Task {
            do {
                let fetchedSteps = try await StepService.fetchSteps(forGoalId: goalId)
                DispatchQueue.main.async {
                    self.steps = fetchedSteps
                    print("DEBUG: Fetched steps: \(fetchedSteps.count)")
                }
            } catch {
                print("Error fetching steps for goal: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchEvidencesForCurrentGoal() {
        guard let goalId = goal?.id else {
            print("Goal ID is not available")
            return
        }
        Task {
            do {
                let fetchedEvidences = try await EvidenceService.fetchEvidences(forGoalId: goalId)
                DispatchQueue.main.async {
                    self.evidences = fetchedEvidences
                }
            } catch {
                print("Error fetching steps for goal: \(error.localizedDescription)")
            }
        }
    }
}
