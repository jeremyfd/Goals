//
//  GoalStepViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 09/02/2024.
//

import Foundation
import Firebase
import Combine
import SwiftUI

@MainActor
class GoalStepViewModel: ObservableObject {
    
    @Published var goal: Goal?
    @Published var evidences: [Evidence] = []
    @Published var steps: [Step] = []
    @Published var currentUserID: String?  // State variable for the current user ID
    @Published var username: String?
    @Published var deletionError: Error?
    @Published var deletionSuccess: Bool = false
    @Published var weeklyProgress: [WeeklyProgress] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    let goalID: String
    
    init(goalID: String) {
        self.goalID = goalID
        self.currentUserID = Auth.auth().currentUser?.uid  // Assign the current user ID
        Task {
            await loadGoal()
        }
    }
    
    func loadGoal() async {
        do {
            let fetchedGoal = try await GoalService.fetchGoal(goalId: goalID)
            self.goal = fetchedGoal
            self.weeklyProgress = Array(repeating: WeeklyProgress(verifiedEvidencesCount: 0, totalPossible: self.goal?.frequency ?? 0), count: self.goal?.duration ?? 0)
            
            await fetchEvidences()
            do {
                let user = try await UserService.fetchUser(withUid: fetchedGoal.ownerUid) // Updated to match your function signature
                self.username = user.username
            } catch {
                print("Failed to fetch user: \(error.localizedDescription)")
                // Handle the error appropriately here
            }
        } catch {
            print("Failed to fetch goal: \(error.localizedDescription)")
            // Handle other errors appropriately here
        }
    }
    
    func updateWeeklyProgress(forWeek weekNumber: Int) {
        print("DEBUG: Updating weekly progress for week: \(weekNumber)")
        guard weekNumber < weeklyProgress.count else { return }
        weeklyProgress[weekNumber].verifiedEvidencesCount += 1
    }
    
    var weeklyVerifiedEvidenceCounts: [Int] {
        var counts: [Int] = Array(repeating: 0, count: goal?.duration ?? 0)
        
        for evidence in evidences where evidence.isVerified {
            let weekNumber = evidence.weekNumber - 1  // Array is 0-indexed, but week numbers start from 1.
            counts[weekNumber] += 1
        }
        
        return counts
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    func steps(forGoal goal: Goal) -> [Step] {
        var result: [Step] = []
        let calendar = Calendar.current
        let startDate = goal.timestamp.dateValue()
        let currentDate = Date()
        let weeksSinceStart = calendar.dateComponents([.weekOfYear], from: startDate, to: currentDate).weekOfYear ?? 0
        
        var lastCompletedDayOfTheWeek: Int?
        var day = 1
        
        for week in 0..<goal.duration {
            let weekNumber = week + 1
            for _ in 0..<goal.frequency {
                
                let status: StepStatus
                
                let evidenceSubmitted = evidences.contains { $0.weekNumber == weekNumber && $0.day == day }
                
                if week < weeksSinceStart {
                    // Past week
                    status = evidenceSubmitted ? .completed : .failed
                } else if week == weeksSinceStart {
                    // Current week
                    if evidenceSubmitted {
                        status = .completed
                        lastCompletedDayOfTheWeek = day
                    } else {
                        let nextExpectedDay: Int
                        if let lastDay = lastCompletedDayOfTheWeek {
                            nextExpectedDay = lastDay + 1
                        } else {
                            // If no evidence has been submitted this week, the next expected day is the first day of the week.
                            nextExpectedDay = (week * goal.frequency) + 1
                        }
                        
                        if day == nextExpectedDay {
                            status = .readyToSubmit
                        } else if day > nextExpectedDay {
                            status = .completePreviousStep
                        } else {
                            status = .failed
                        }
                    }
                    
                } else {
                    // Future week
                    status = .notStartedYet
                }
                
                // Create the step
                //                print("DEBUG: Week: \(weekNumber), Day: \(day), Status: \(status)")
                let step = Step(weekNumber: weekNumber, day: day, evidence: nil, status: status)
                result.append(step)
                
                day += 1
            }
        }
        
        return result

}
    
    // MARK: - Evidences
    
    func fetchEvidences() async {
        do {
            let fetchedEvidences = try await EvidenceService.shared.fetchEvidences(goalID: goalID)
            DispatchQueue.main.async {
                self.evidences = fetchedEvidences.sorted { $0.timestamp.dateValue() < $1.timestamp.dateValue() }
                print("DEBUG: Evidences fetched and sorted.")
                self.generateSteps() // Regenerate steps with new evidence data
            }
        } catch {
            print("DEBUG: Failed to fetch evidences: \(error.localizedDescription)")
        }
    }
    
    private func generateSteps() {
        guard let goal = goal else { return }
        print("DEBUG: Generating steps for goal with duration: \(goal.duration)")
        
        var generatedSteps: [Step] = []
        for week in 1...goal.duration {
            for day in 1...goal.frequency {
                let evidenceForStep = evidences.first { $0.weekNumber == week && $0.day == day }
                let status: StepStatus = evidenceForStep != nil ? .completed : .notStartedYet // Simplified for demonstration
                let step = Step(weekNumber: week, day: day, evidence: evidenceForStep, status: status)
                generatedSteps.append(step)
                if evidenceForStep != nil {
                    print("DEBUG: Evidence \(evidenceForStep!.id) associated with Step for Week: \(week), Day: \(day)")
                } else {
                    print("DEBUG: No evidence for Step for Week: \(week), Day: \(day)")
                }
            }
        }
        self.steps = generatedSteps
    }
    
    @MainActor
    func verifyEvidence(_ evidence: Evidence) async {
        guard let index = evidences.firstIndex(where: { $0.id == evidence.id }) else {
            return
        }

        evidences[index].isVerified = true

        do {
            try await EvidenceService.shared.updateEvidence(evidence)
            // Increment the current count of the goal
            self.goal?.currentCount += 1
            self.updateWeeklyProgress(forWeek: evidence.weekNumber - 1) // Assuming week numbers start from 1

            // Now update this change in the Firebase
            try await GoalService.shared.updateGoal(self.goal!)
            print("Goal's currentCount updated successfully")
        } catch {
            print("Failed to update: \(error.localizedDescription)")
            // Revert the isVerified property change or show an error message to the user
            self.evidences[index].isVerified = false
        }
    }
    
    @MainActor
    func deleteEvidence(_ evidence: Evidence) async -> Result<Void, Error> {
        do {
            // Assuming EvidenceService.deleteEvidence is now an async function
            try await EvidenceService.shared.deleteEvidence(evidence)
            
            // Assuming you need to transform the imageURL to a path suitable for deleteImage
            if let imageURL = evidence.imageURL {
                // Assuming you have a way to derive the storage path from the imageURL
                let path = derivePathFromURL(imageURL: imageURL)
                try await ImageUploader.deleteImage(atPath: path)
            }
            
            // Update the UI to reflect the deletion success
            self.deletionSuccess = true
            return .success(())
        } catch {
            // Handle error deleting evidence or image
            self.deletionError = error
            return .failure(error)
        }
    }
    
    private func derivePathFromURL(imageURL: String) -> String {
        return imageURL
    }
    
}

