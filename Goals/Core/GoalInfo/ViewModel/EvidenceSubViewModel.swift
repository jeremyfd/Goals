//
//  EvidenceSubViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 15/02/2024.
//

import Foundation
import SwiftUI  // For UIImage

class EvidenceSubViewModel: ObservableObject {
    @Published var steps: [Step] = []  // Steps should include evidence status
    private let stepsCalculator = StepsCalculator()
    @Published var isSubmittingEvidence = false
    
    let goalId: String
    let goalStartDate: Date
    let goalDuration: Int
    let goalFrequency: Int
    let goalTarget: Int
    
    var currentUserID: String? {
        AuthService.shared.userSession?.uid
    }
    
    init(goalId: String, startDate: Date, duration: Int, frequency: Int, targetCount: Int) {
        self.goalId = goalId
        self.goalStartDate = startDate
        self.goalDuration = duration
        self.goalFrequency = frequency
        self.goalTarget = targetCount
        Task {
            await fetchEvidenceForGoal()
        }
    }
    
    @MainActor
    func calculateSteps(with evidences: [Evidence], for goalCycles: [GoalCycle]) {
        // Assuming you need to handle multiple GoalCycles
        goalCycles.forEach { goalCycle in
            let calculatedSteps = stepsCalculator.calculateSteps(
                goalCycles: goalCycles,
                goalDuration: goalDuration,
                goalFrequency: goalFrequency,
                goalTarget: goalTarget,
                evidences: evidences)
            // Assuming you need to append or manage steps for multiple GoalCycles
            self.steps.append(contentsOf: calculatedSteps)
        }
    }

    // Present evidence submission UI
    func presentEvidenceSubmission(for step: Step) {
        isSubmittingEvidence = true
        // Implement UI presentation logic here, possibly using a sheet or navigation
    }
    
    func fetchEvidenceForGoal() async {
        do {
            let evidences = try await EvidenceService.fetchEvidences(forGoalId: goalId)
            // Assuming you have a way to fetch or determine the relevant GoalCycles for the goalId
            let goal = try await GoalService.fetchGoalDetails(goalId: goalId)
            let goalCycles = goal.cycles
            
            await calculateSteps(with: evidences, for: goalCycles)
        } catch {
            print("DEBUG: Error fetching evidences: \(error)")
        }
    }

    func deleteEvidence(evidenceId: String) {
        guard !evidenceId.isEmpty else { return }
        
        Task {
            do {
                // Delete the evidence document and its associated image
                try await EvidenceService.deleteEvidence(evidenceId: evidenceId)
                // Fetch the updated list of evidences after deletion
                await fetchEvidenceForGoal()
            } catch {
                print("Error deleting evidence: \(error.localizedDescription)")
                // Handle the error, e.g., show an error message to the user
            }
        }
    }
    
    func verifyEvidence(evidenceId: String) {
        guard !evidenceId.isEmpty else { return }
        
        Task {
            do {
                // Update the evidence's verification status to true and increment the goal's current count
                try await EvidenceService.updateEvidenceVerification(evidenceId: evidenceId, isVerified: true, goalId: goalId)
                // Refresh the evidence list to reflect the change
                await fetchEvidenceForGoal()
                // Optionally, if you have UI elements depending on the goal's currentCount, trigger their update here
            } catch {
                print("Error verifying evidence: \(error.localizedDescription)")
                // Handle the error, e.g., show an error message to the user
            }
        }
    }
}

class StepsCalculator {
    
    // Modify the function to accept GoalCycles
    func calculateSteps(goalCycles: [GoalCycle], goalDuration: Int, goalFrequency: Int, goalTarget: Int, evidences: [Evidence]) -> [Step] {
        var result: [Step] = []
        let calendar = Calendar.current
        let currentDate = Date()
        
        for goalCycle in goalCycles {
            // Calculate weeks since start for each cycle
            let weeksSinceStart = calendar.dateComponents([.weekOfYear], from: goalCycle.startDate, to: currentDate).weekOfYear ?? 0
            
            let completionsPerWeek = goalFrequency
            let totalWeeksNeeded = Int(ceil(Double(goalTarget) / Double(completionsPerWeek)))
            var stepsDistribution = [Int](repeating: completionsPerWeek, count: totalWeeksNeeded)
            adjustStepsDistributionIfNeeded(&stepsDistribution, totalCompletionsNeeded: goalTarget)
            
            var lastCompletedDayGlobal: Int? = nil
            
            for week in 0..<goalDuration {
                let stepsThisWeek = week < stepsDistribution.count ? stepsDistribution[week] : 0
                let weekEndDate = calendar.date(byAdding: .day, value: 7 * (week + 1) - 1, to: goalCycle.startDate)!
                
                for dayIndex in 0..<stepsThisWeek {
                    let dayNumberForStep = week * completionsPerWeek + dayIndex + 1
                    let evidenceSubmitted = evidences.contains(where: { $0.weekNumber == week + 1 && $0.dayNumber == dayNumberForStep && $0.goalID == goalCycle.goalID }) // Ensure evidence matches goalCycle
                    if evidenceSubmitted {
                        lastCompletedDayGlobal = dayNumberForStep
                    }
                    
                    // Calculate deadline by going backwards from the end of the week
                    let daysBackward = stepsThisWeek - dayIndex - 1
                    let stepDeadline = calculateStepDeadline(weekEndDate: weekEndDate, daysBackward: daysBackward)
                    
                    let status = determineStepStatus(week: week, dayNumberForStep: dayNumberForStep, evidenceSubmitted: evidenceSubmitted, weeksSinceStart: weeksSinceStart, lastCompletedDayGlobal: lastCompletedDayGlobal)
                    
                    let evidenceForStep = evidences.first(where: { $0.weekNumber == week + 1 && $0.dayNumber == dayNumberForStep && $0.goalID == goalCycle.goalID }) // Ensure evidence matches goalCycle
                    let step = Step(id: UUID(), weekNumber: week + 1, dayNumber: dayNumberForStep, evidence: evidenceForStep, status: status, deadline: stepDeadline)
                    result.append(step)
                }
            }
        }
        
        return result
    }
    
    private func calculateStepDeadline(weekEndDate: Date, daysBackward: Int) -> Date {
        // A helper function to calculate the deadline for a step by going backwards from the week's end date
        // based on the actual number of days needed for the step in that week.
        let calendar = Calendar.current
        let stepDate = calendar.date(byAdding: .day, value: -daysBackward, to: weekEndDate)!
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: stepDate)!
    }

    private func adjustStepsDistributionIfNeeded(_ stepsDistribution: inout [Int], totalCompletionsNeeded: Int) {
        let totalStepsDistributed = stepsDistribution.reduce(0, +)
        if totalStepsDistributed > totalCompletionsNeeded {
            let extraSteps = totalStepsDistributed - totalCompletionsNeeded
            stepsDistribution[stepsDistribution.count - 1] -= extraSteps
        }
    }

    private func determineStepStatus(week: Int, dayNumberForStep: Int, evidenceSubmitted: Bool, weeksSinceStart: Int, lastCompletedDayGlobal: Int?) -> StepStatus {
        if week < weeksSinceStart || (week == weeksSinceStart && dayNumberForStep <= (lastCompletedDayGlobal ?? 0)) {
            return evidenceSubmitted ? .completed : .failed
        } else if week == weeksSinceStart && dayNumberForStep == (lastCompletedDayGlobal ?? 0) + 1 {
            return .readyToSubmit
        } else if week == weeksSinceStart && dayNumberForStep > (lastCompletedDayGlobal ?? 0) + 1 {
            return .completePreviousStep
        } else if week > weeksSinceStart {
            return .notStartedYet // This ensures future weeks are marked as not started
        }
        return .notStartedYet // Fallback default
    }

}
