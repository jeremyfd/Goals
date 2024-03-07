//
//  NextTierViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 27/02/2024.
//

import Foundation

class NextTierViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var operationSuccessful: Bool? = nil
    
    private var frequency: Int = 2
    private var tier: Int = 1
    private let deadlines: [Int: [Int]] = [
        2: [6, 7, 13, 14, 20, 21, 28],
        3: [5, 6, 7, 12, 13, 14, 21],
        4: [4, 5, 6, 7, 12, 13, 14],
        5: [3, 4, 5, 6, 7, 13, 14],
        6: [2, 3, 4, 5, 6, 7, 14],
        7: [1, 2, 3, 4, 5, 6, 7]
    ]

    func incrementTargetCount(goalId: String) {
        isProcessing = true
        operationSuccessful = nil // Reset the success state
        Task {
            do {
                try await GoalService.incrementTargetCountForGoal(goalId: goalId)
                DispatchQueue.main.async { [weak self] in
                    self?.isProcessing = false
                    self?.operationSuccessful = true
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.isProcessing = false
                    self?.operationSuccessful = false
                    print("Error incrementing target count: \(error)")
                }
            }
        }
    }
    
    func createNewCycleWithStartDate(for goalId: String, startDate: Date, frequency: Int, tier: Int) async throws {
        self.frequency = frequency
        self.tier = tier

        // Use the provided start date for the new cycle
        var cycle = Cycle(goalID: goalId, startDate: startDate, tier: tier)
        let cycleId = try await CycleService.uploadCycle(cycle)
        cycle.cycleId = cycleId

        let totalSteps = 7
        let frequencyInt = Int(self.frequency)
        let calendar = Calendar.current
        
        // Fetch all steps for the goal to find the last weekNumber and stepNumber
        let existingSteps = try await StepService.fetchSteps(forGoalId: goalId)
        let lastWeekNumber = existingSteps.max(by: { $0.weekNumber < $1.weekNumber })?.weekNumber ?? 0
        let lastDayNumber = existingSteps.max(by: { $0.dayNumber < $1.dayNumber })?.dayNumber ?? 0
        
        // Adjust starting values for weekNumber and stepNumber
        var currentWeekNumber = lastWeekNumber + 1
        var currentDayNumber = lastDayNumber + 1
        
        // Get the deadlines array based on the frequency
        guard let frequencyDeadlines = deadlines[frequencyInt] else { return }
        
        for _ in 1...totalSteps {
            // Calculate stepNumber based on the currentStepNumber
            let stepNumber = currentDayNumber % totalSteps == 0 ? totalSteps : currentDayNumber % totalSteps
            
            // Use the step number to get the days to add from the deadlines array
            let daysToAdd = frequencyDeadlines[stepNumber - 1]
            // Calculate the preliminary deadline date using the new start date
            let preliminaryDeadline = calendar.date(byAdding: .day, value: daysToAdd - 1, to: cycle.startDate)!
            // Set the deadline to one second before midnight
            let stepDeadline = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: preliminaryDeadline)!
            
            // Create the step with the updated weekNumber and stepNumber
            let step = Step(cycleID: cycle.cycleId ?? "", goalID: cycle.goalID, weekNumber: currentWeekNumber, dayNumber: currentDayNumber, deadline: stepDeadline, tier: cycle.tier, isSubmitted: false, isVerified: false)
            _ = try await StepService.uploadStep(step)
            
            currentDayNumber += 1
            if stepNumber % frequencyInt == 0 {
                currentWeekNumber += 1
            }
            
        }
    }
}

