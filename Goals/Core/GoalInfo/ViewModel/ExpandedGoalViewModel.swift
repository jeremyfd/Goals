//
//  ExpandedGoalViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 07/02/2024.
//

import Foundation
import Combine

class ExpandedGoalViewModel: ObservableObject {
    @Published var partnerUser: User?
    @Published var currentUser: User?
    @Published var goal: Goal?
    
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
}
