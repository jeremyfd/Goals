//
//  ExpandedGoalViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 07/02/2024.
//

import Foundation

class ExpandedGoalViewModel: ObservableObject {
    @Published var partnerUser: User?
    
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
}
