//
//  GoalViewModel.swift
//  Goals
//
//  Created by Work on 22/01/2024.
//

import Foundation

@MainActor
class GoalViewModel: ObservableObject {
    @Published var goals = [Goal]()
    
    let user: User
    
    init(user: User) {
        self.user = user
        Task { try await fetchUserGoals()}
    }
    
    func fetchUserGoals() async throws {
        self.goals = try await GoalService.fetchUserGoals(uid: user.id)
    }
}
