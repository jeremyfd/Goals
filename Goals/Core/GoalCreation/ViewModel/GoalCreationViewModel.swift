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
    
    private let deadlines: [Int: [Int]] = [
        2: [6, 7, 13, 14, 20, 21, 28],
        3: [5, 6, 7, 12, 13, 14, 21],
        4: [4, 5, 6, 7, 12, 13, 14],
        5: [3, 4, 5, 6, 7, 13, 14],
        6: [2, 3, 4, 5, 6, 7, 14],
        7: [1, 2, 3, 4, 5, 6, 7]
    ]
    
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
            currentCount: Int(currentCount),
            targetCount: Int(targetCount),
            tier: Int(tier))
        
        // Upload the goal and get the documentID of the newly created goal
        let goalId = try await GoalService.uploadGoal(goal)
        
        // Create and upload a new cycle associated with the newly created goal
        var cycle = Cycle(goalID: goalId, startDate: Date(), tier: 1)
        let cycleId = try await CycleService.uploadCycle(cycle)
        cycle.cycleId = cycleId
        
        let totalSteps = 7
        let frequencyInt = Int(self.frequency)
        let calendar = Calendar.current
        
        // Get the deadlines array based on the frequency
        guard let frequencyDeadlines = deadlines[frequencyInt] else { return }
        
        for stepNumber in 1...totalSteps {
            // Use the step number to get the days to add from the deadlines array
            let daysToAdd = frequencyDeadlines[stepNumber - 1]
            // Calculate the preliminary deadline date
            let preliminaryDeadline = calendar.date(byAdding: .day, value: daysToAdd - 1, to: cycle.startDate)!
            // Set the deadline to one second before midnight
            let stepDeadline = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: preliminaryDeadline)!
            
            print("DEBUG: Day \(stepNumber): Deadline - \(stepDeadline), Tier - \(cycle.tier)")
            
            // Assuming the existence of a Step object and StepService.uploadStep method to save the step
            let step = Step(cycleID: cycle.cycleId ?? "", goalID: cycle.goalID, weekNumber: (stepNumber - 1) / frequencyInt + 1, dayNumber: stepNumber, deadline: stepDeadline, tier: cycle.tier, isSubmitted: false, isVerified: false)
            _ = try await StepService.uploadStep(step)
        }
        
    }
}
