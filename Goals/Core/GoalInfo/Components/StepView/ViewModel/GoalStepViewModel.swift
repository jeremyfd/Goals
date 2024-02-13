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
            
            //            await fetchEvidences()
            
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
    
    var currentWeekIndex: Int {
        let calendar = Calendar.current
        let startDate = goal?.timestamp.dateValue() ?? Date()
        let currentDate = Date()
        // Calculate the number of weeks since the goal's start date
        let weeksSinceStart = calendar.dateComponents([.weekOfYear], from: startDate, to: currentDate).weekOfYear ?? 0
        return weeksSinceStart
    }
    
    func isWeekFullyCompleted(weekIndex: Int) -> Bool {
        // Given a week index, check the number of verified evidences for that week
        let verifiedEvidencesForWeek = evidences.filter { $0.weekNumber - 1 == weekIndex && $0.isVerified }.count
        return verifiedEvidencesForWeek == goal?.frequency
    }
}
    
    // MARK: - Evidences
    
    //    func fetchEvidences() {
    //        EvidenceService.shared.fetchEvidences(goalID: goalID) { [weak self] result in
    //            switch result {
    //            case .success(let fetchedEvidences):
    //                self?.evidences = fetchedEvidences.sorted {
    //                    guard let date1 = $0.submittedAt.timestamp.dateValue() as Date?,
    //                          let date2 = $1.submittedAt.timestamp.dateValue() as Date? else {
    //                        return false
    //                    }
    //                    return date1 > date2
    //                }
    //            case .failure(let error):
    //                print("Failed to fetch evidences: \(error.localizedDescription)")
    //                // Handle the error appropriately
    //            }
    //        }
    //    }
    
    //    func verifyEvidence(_ evidence: Evidence) {
    //        guard let index = evidences.firstIndex(where: { $0.id == evidence.id }) else {
    //            return
    //        }
    //
    //        evidences[index].isVerified = true
    //
    //        EvidenceService.shared.updateEvidence(evidence) { result in
    //            switch result {
    //            case .success:
    //                // Increment the current count of the goal
    //                self.goal?.currentCount += 1
    //                self.updateWeeklyProgress(forWeek: evidence.weekNumber - 1) // Assuming week numbers start from 1
    //                // Now update this change in the Firebase
    //                GoalService.shared.updateGoal(self.goal!) { updateResult in
    //                    switch updateResult {
    //                    case .success:
    //                        print("Goal's currentCount updated successfully")
    //                    case .failure(let error):
    //                        print("Failed to update goal's currentCount: \(error.localizedDescription)")
    //                        // You might want to revert the isVerified property change or show an error message to the user
    //                        self.evidences[index].isVerified = false
    //                    }
    //                }
    //            case .failure(let error):
    //                print("Failed to update evidence: \(error.localizedDescription)")
    //                // You might want to revert the isVerified property change or show an error message to the user
    //                self.evidences[index].isVerified = false
    //            }
    //        }
    //    }
    
    //    func deleteEvidence(_ evidence: Evidence, completion: @escaping (Result<Void, Error>) -> Void) {
    //        EvidenceService().deleteEvidence(evidence) { result in
    //                switch result {
    //                case .success:
    //                    ImageUploader.shared.deleteImage(url: evidence.imageURL) { result in
    //                        switch result {
    //                        case .success:
    //                            // Update the UI to reflect the deletion success
    //                            DispatchQueue.main.async {
    //                                self.deletionSuccess = true
    //                            }
    //                        case .failure(let error):
    //                            // Handle error deleting image
    //                            DispatchQueue.main.async {
    //                                self.deletionError = error
    //                            }
    //                        }
    //                    }
    //                case .failure(let error):
    //                    // Handle error deleting evidence
    //                    DispatchQueue.main.async {
    //                        self.deletionError = error
    //                    }
    //                }
    //            }
    //        }
//}

