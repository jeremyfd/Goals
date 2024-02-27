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
    @Published var tier = 1.0
    @Published var currentCount = 0.0
    @Published var targetCount = 7.0
    @Published var description = ""
    @Published var partnerUsername: String = ""
    
    func uploadGoal() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Create the goal object as before
        let goal = Goal(
            ownerUid: uid,
            partnerUid: partnerUID,
            timestamp: Timestamp(),
            title: title,
            frequency: Int(frequency),
            description: description,
            duration: Int(duration),
            currentCount: Int(currentCount),
            targetCount: Int(targetCount),
            tier: Int(tier),
            cycles: [] // Initialize cycles as empty or with a default value if necessary
        )
        
        // Upload the goal and retrieve the goalId
        let goalId = try await GoalService.uploadGoal(goal)
        
        // Create the initial GoalCycle
        let initialCycle = GoalCycle(
            startDate: goal.timestamp.dateValue(), // Convert Firestore Timestamp to Date
            tier: 1,
            goalID: goalId
        )
        
        // Optionally, fetch the goal to ensure it's been uploaded correctly
        var uploadedGoal = try await GoalService.fetchGoalDetails(goalId: goalId)
        
        // Add the initial cycle to the goal's cycles array
        uploadedGoal.cycles.append(initialCycle)
        
        // Update the goal with the new cycle information
        try await GoalService.updateGoal(goalId: goalId, updatedGoal: uploadedGoal)
    }
}
