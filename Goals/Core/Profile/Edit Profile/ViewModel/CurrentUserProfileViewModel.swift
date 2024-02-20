//
//  CurrentUserProfileViewModel.swift
//  Goals
//
//  Created by Work on 18/01/2024.
//

import Foundation
import Combine

class CurrentUserProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var goals = [Goal]()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser
            .sink { [weak self] user in
                self?.currentUser = user
                // Fetch user goals whenever the current user changes.
                if let user = user {
                    self?.fetchUserGoals(for: user)
                }
            }.store(in: &cancellables)
    }
    
    private func fetchUserGoals(for user: User) {
        Task {
            do {
                let fetchedUserGoals = try await GoalService.fetchUserGoals(uid: user.id)
                await MainActor.run {
                    // Directly modify each goal's user property if necessary
                    self.goals = fetchedUserGoals.map { goal in
                        var mutableGoal = goal
                        mutableGoal.user = user
                        return mutableGoal
                    }
                }
            } catch {
                print("Error fetching user goals: \(error)")
            }
        }
    }
    
    func refreshUserGoals(for user: User) {
        fetchUserGoals(for: user)
    }

    func noContentText() -> String {
        guard let user = currentUser else {
            return "User not found."
        }
        
        let name = user.isCurrentUser ? "You" : user.username
        let nextWord = user.isCurrentUser ? "haven't" : "hasn't"
        
        return "\(name) \(nextWord) created any goals yet."
    }
}
