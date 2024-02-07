//
//  UserContentListViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 05/02/2024.
//

import Foundation

@MainActor
class UserContentListViewModel: ObservableObject {
    @Published var goals = [Goal]()
    
    private let user: User
    
    init(user: User) {
        self.user = user
        Task { try await fetchUserGoals() }
    }
    
    func fetchUserGoals() async throws {
        var userGoals = try await GoalService.fetchUserGoals(uid: user.id)
        
        for i in 0 ..< userGoals.count {
            userGoals[i].user = self.user
        }
        self.goals = userGoals
    }
    
    func noContentText() -> String {
        let name = user.isCurrentUser ? "You" : user.username
        let nextWord = user.isCurrentUser ? "haven't" : "hasn't"
        
        return "\(name) \(nextWord) created any goals yet."
    }
}
