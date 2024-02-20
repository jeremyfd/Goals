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
    
    var currentUserID: String? {
            AuthService.shared.userSession?.uid
        }

    init(goalId: String, startDate: Date, duration: Int, frequency: Int) {
        self.goalId = goalId
        self.goalStartDate = startDate
        self.goalDuration = duration
        self.goalFrequency = frequency
        Task {
            await fetchEvidenceForGoal()
        }
    }

    // Asynchronously fetch evidences and calculate steps
    func fetchEvidenceForGoal() async {
        do {
            print("DEBUG: Fetching evidences for goal \(goalId)")
            let evidences = try await EvidenceService.fetchEvidences(forGoalId: goalId)
            print("DEBUG: Fetched \(evidences.count) evidences")
            DispatchQueue.main.async {
                self.calculateSteps(with: evidences)
            }
        } catch {
            print("DEBUG: Error fetching evidences: \(error)")
        }
    }

    private func calculateSteps(with evidences: [Evidence]) {
        print("DEBUG: Calculating steps with \(evidences.count) evidences")

        var result: [Step] = []
        let calendar = Calendar.current
        let currentDate = Date()
        print("DEBUG: Current date: \(currentDate)")
        let weeksSinceStart = calendar.dateComponents([.weekOfYear], from: goalStartDate, to: currentDate).weekOfYear ?? 0
        print("DEBUG: Weeks since start: \(weeksSinceStart)")


        // Track the last day that was completed for accurate status assignment
        var lastCompletedDay: Int? = nil
        
        print("DEBUG: Fetched evidences: \(evidences)")

        for week in 0..<goalDuration {
            let weekNumber = week + 1
            let isCurrentWeek = week == weeksSinceStart
            
            print("DEBUG: Current week: \(weekNumber), Last completed day: \(String(describing: lastCompletedDay))")

            for day in 1...goalFrequency {
                let evidenceSubmitted = evidences.first { $0.weekNumber == weekNumber && $0.dayNumber == day } != nil
                if evidenceSubmitted {
                    lastCompletedDay = day
                    print("DEBUG: Evidence submitted for day \(day)")
                }
            }

            for day in 1...goalFrequency {
                let status: StepStatus
                let evidenceSubmitted = evidences.first { $0.weekNumber == weekNumber && $0.dayNumber == day } != nil
                print("DEBUG: Calculating status for week \(weekNumber) day \(day)")

                if week < weeksSinceStart || (isCurrentWeek && day <= (lastCompletedDay ?? 0)) {
                    status = evidenceSubmitted ? .completed : .failed
                } else if day == (lastCompletedDay ?? 0) + 1 && isCurrentWeek {
                    status = .readyToSubmit
                } else if day > (lastCompletedDay ?? 0) + 1 && isCurrentWeek {
                    status = .completePreviousStep
                } else {
                    status = .notStartedYet
                }

                let evidenceForStep = evidences.first { $0.weekNumber == weekNumber && $0.dayNumber == day }
                let step = Step(weekNumber: weekNumber, dayNumber: day, evidence: evidenceForStep, status: status)

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