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

        // Determine the total number of completions needed and calculate the distribution of steps
        let totalCompletionsNeeded = goalTarget
        let completionsPerWeek = goalFrequency
        let totalWeeksNeeded = Int(ceil(Double(totalCompletionsNeeded) / Double(completionsPerWeek)))

        var stepsDistribution = [Int](repeating: completionsPerWeek, count: totalWeeksNeeded)
        let totalStepsDistributed = stepsDistribution.reduce(0, +)
        if totalStepsDistributed > totalCompletionsNeeded {
            let extraSteps = totalStepsDistributed - totalCompletionsNeeded
            stepsDistribution[stepsDistribution.count - 1] -= extraSteps
        }

        var cumulativeDayCount = 0
        var lastCompletedDayGlobal: Int? = nil

        for week in 0..<goalDuration {
            let weekNumber = week + 1
            let stepsThisWeek = week < stepsDistribution.count ? stepsDistribution[week] : 0

            // Update last completed day in a global context
            for day in 1...stepsThisWeek {
                cumulativeDayCount += 1
                if evidences.contains(where: {$0.weekNumber == weekNumber && $0.dayNumber == cumulativeDayCount}) {
                    lastCompletedDayGlobal = cumulativeDayCount
                }
            }

            for day in 1...stepsThisWeek {
                let dayNumberForStep = cumulativeDayCount - stepsThisWeek + day
                let evidenceSubmitted = evidences.contains { $0.weekNumber == weekNumber && $0.dayNumber == dayNumberForStep }
                let status: StepStatus

                if week < weeksSinceStart || (week == weeksSinceStart && dayNumberForStep <= (lastCompletedDayGlobal ?? 0)) {
                    status = evidenceSubmitted ? .completed : .failed
                } else if week == weeksSinceStart && dayNumberForStep == (lastCompletedDayGlobal ?? 0) + 1 {
                    status = .readyToSubmit
                } else if week == weeksSinceStart && dayNumberForStep > (lastCompletedDayGlobal ?? 0) + 1 {
                    status = .completePreviousStep
                } else if week > weeksSinceStart {
                    status = .notStartedYet // This ensures future weeks are marked as not started
                } else {
                    status = .notStartedYet // Default case for any other situation
                }

                let evidenceForStep = evidences.first { $0.weekNumber == weekNumber && $0.dayNumber == dayNumberForStep }
                let step = Step(weekNumber: weekNumber, dayNumber: dayNumberForStep, evidence: evidenceForStep, status: status)

                result.append(step)
            }
        }

        DispatchQueue.main.async {
            self.steps = result
        }
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
