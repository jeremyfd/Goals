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
    
    private func calculateSteps(with evidences: [Evidence]) {
        var result: [Step] = []
        let calendar = Calendar.current
        let currentDate = Date()
        let weeksSinceStart = calendar.dateComponents([.weekOfYear], from: goalStartDate, to: currentDate).weekOfYear ?? 0
        
        let completionsPerWeek = goalFrequency
        let totalWeeksNeeded = Int(ceil(Double(goalTarget) / Double(completionsPerWeek)))
        var stepsDistribution = [Int](repeating: completionsPerWeek, count: totalWeeksNeeded)
        adjustStepsDistributionIfNeeded(&stepsDistribution, totalCompletionsNeeded: goalTarget)
        
        var lastCompletedDayGlobal: Int? = nil
        
        for week in 0..<goalDuration {
            let stepsThisWeek = week < stepsDistribution.count ? stepsDistribution[week] : 0
            let weekEndDate = calendar.date(byAdding: .day, value: 7 * (week + 1) - 1, to: goalStartDate)!
            
            for dayIndex in 0..<stepsThisWeek {
                let dayNumberForStep = week * completionsPerWeek + dayIndex + 1
                let evidenceSubmitted = evidences.contains(where: { $0.weekNumber == week + 1 && $0.dayNumber == dayNumberForStep })
                if evidenceSubmitted {
                    lastCompletedDayGlobal = dayNumberForStep
                }
                
                // Calculate deadline by going backwards from the end of the week
                let daysBackward = stepsThisWeek - dayIndex - 1
                let stepDeadline = calculateStepDeadline(weekEndDate: weekEndDate, daysBackward: daysBackward)
                
                let status = determineStepStatus(week: week, dayNumberForStep: dayNumberForStep, evidenceSubmitted: evidenceSubmitted, weeksSinceStart: weeksSinceStart, lastCompletedDayGlobal: lastCompletedDayGlobal)
                
                let evidenceForStep = evidences.first(where: { $0.weekNumber == week + 1 && $0.dayNumber == dayNumberForStep })
                let step = Step(weekNumber: week + 1, dayNumber: dayNumberForStep, evidence: evidenceForStep, status: status, deadline: stepDeadline)
                result.append(step)
            }
        }
        
        DispatchQueue.main.async {
            self.steps = result
        }
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

    // Present evidence submission UI
    func presentEvidenceSubmission(for step: Step) {
        isSubmittingEvidence = true
        // Implement UI presentation logic here, possibly using a sheet or navigation
    }
    
    // Asynchronously fetch evidences and calculate steps
    func fetchEvidenceForGoal() async {
        do {
            //            print("DEBUG: Fetching evidences for goal \(goalId)")
            let evidences = try await EvidenceService.fetchEvidences(forGoalId: goalId)
            //            print("DEBUG: Fetched \(evidences.count) evidences")
            DispatchQueue.main.async {
                self.calculateSteps(with: evidences)
            }
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
