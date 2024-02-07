//
//  GoalCreationViewModel.swift
//  Goals
//
//  Created by Work on 21/01/2024.
//

import Foundation
import Firebase

class GoalCreationViewModel: ObservableObject {
    @Published var title = ""
    @Published var partnerUID = ""
    @Published var frequency = 1.0
    @Published var partnerUsername: String = ""
    
    func uploadGoal() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let goal = Goal(
            ownerUid: uid,
            partnerUid: partnerUID,
            timestamp: Timestamp(),
            title: title,
            frequency: Int(frequency))
        try await GoalService.uploadGoal(goal)
    }
}
