//
//  UserProfileViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 06/02/2024.
//

import Foundation

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var goals = [Goal]()
    @Published var user: User
    
    init(user: User) {
        self.user = user
    }
    
    func loadUserData() {
        Task {
            async let isFriend = await checkIfUserIsFriend()
            async let fetchedGoals = fetchUserGoals(for: user)
            self.user.isFriend = await isFriend
            self.goals = await fetchedGoals
        }
    }
    
    private func fetchUserGoals(for user: User) async -> [Goal] {
        do {
            let fetchedUserGoals = try await GoalService.fetchUserGoals(uid: user.id)
            // Directly modify each goal's user property if necessary
            let goalsWithUser = fetchedUserGoals.map { goal -> Goal in
                var mutableGoal = goal
                mutableGoal.user = user
                return mutableGoal
            }
            return goalsWithUser
        } catch {
            print("Error fetching user goals: \(error)")
            return []
        }
    }
    
    func refreshUserGoals() {
        Task {
            self.goals = await fetchUserGoals(for: user)
        }
    }
    
    func checkIfUserIsFriend() async -> Bool {
        return await UserService.checkIfUserIsFriend(user)
    }
}
