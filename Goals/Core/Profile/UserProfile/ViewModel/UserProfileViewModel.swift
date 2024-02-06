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
            self.user.isFriend = await isFriend
        }
    }
    
    func checkIfUserIsFriend() async -> Bool {
        return await UserService.checkIfUserIsFriend(user)
    }
    
}
