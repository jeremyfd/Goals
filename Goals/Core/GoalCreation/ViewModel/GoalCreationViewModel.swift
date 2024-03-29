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
    @Published var frequency = 2.0
    @Published var duration = 1.0
    @Published var currentCount = 0.0
    @Published var description = ""
    @Published var partnerUsername: String = ""
    
    func uploadGoal() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let goal = Goal(
            ownerUid: uid,
            partnerUid: partnerUID,
            timestamp: Timestamp(),
            title: title,
            frequency: Int(frequency), 
            description: description, 
            duration: Int(duration), 
            currentCount: Int(currentCount))
        try await GoalService.uploadGoal(goal)
    }
}
