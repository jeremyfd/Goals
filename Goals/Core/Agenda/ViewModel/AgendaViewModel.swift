//
//  AgendaViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 26/02/2024.
//

import Foundation
import SwiftUI
import Firebase
import Combine

class AgendaViewModel: ObservableObject {
    @Published var currentUser: User?
    private var cancellables = Set<AnyCancellable>()
    let stepsCalculator = StepsCalculator()

    @Published var evidencesByDate: [Date: [(Evidence, Goal)]] = [:]
    @Published var stepsByDate: [Date: [(Step, Goal)]] = [:]
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &cancellables)
    }

    func fetchDataForYourFriendsContractsCalendar() {
        guard let uid = currentUser?.id else { return }

        Task {
            do {
                let goalIDs = try await GoalService.fetchFriendGoalIDs(uid: uid)
                var allStepsWithGoal: [(step: Step, goal: Goal)] = []

                for goalID in goalIDs {
                    let goal = try await GoalService.fetchGoalDetails(goalId: goalID)
                    let enrichedGoal = try await fetchGoalUserData(goal: goal)

                    // Assume you have a way to determine these parameters from your goal object
                    let goalStartDate = enrichedGoal.timestamp.dateValue() // Convert Timestamp to Date
                    let goalDuration = enrichedGoal.duration // Example; adjust as needed
                    let goalFrequency = enrichedGoal.frequency // Example; adjust as needed
                    let goalTarget = enrichedGoal.targetCount // Example; adjust as needed

                    let evidences = try await EvidenceService.fetchEvidences(forGoalId: enrichedGoal.id)
                    let steps = stepsCalculator.calculateSteps(goalStartDate: goalStartDate, goalDuration: goalDuration, goalFrequency: goalFrequency, goalTarget: goalTarget, evidences: evidences)

                    allStepsWithGoal.append(contentsOf: steps.map { (step: $0, goal: enrichedGoal) })
                }

                // Now you have all steps with their corresponding goal, you can organize them for the view
                organizeStepsByDeadline(allStepsWithGoal)
            } catch {
                print("Error fetching goals and steps: \(error)")
            }
        }
    }

    private func fetchGoalUserData(goal: Goal) async throws -> Goal {
        var result = goal
    
        async let user = try await UserService.fetchUser(withUid: goal.ownerUid)
        result.user = try await user
        
        return result
    }
    
    func organizeEvidencesByDeadline(_ evidencesWithGoal: [(Evidence, Goal, Date)]) {
        var organizedData: [Date: [(Evidence, Goal)]] = [:]
        for (evidence, goal, deadline) in evidencesWithGoal {
            let deadlineStartOfDay = Calendar.current.startOfDay(for: deadline)
            if organizedData[deadlineStartOfDay] == nil {
                organizedData[deadlineStartOfDay] = [(evidence, goal)]
            } else {
                organizedData[deadlineStartOfDay]?.append((evidence, goal))
            }
        }
        DispatchQueue.main.async {
            self.evidencesByDate = organizedData
        }
    }
    
    func organizeStepsByDeadline(_ stepsWithGoal: [(Step, Goal)]) {
        var organizedData: [Date: [(Step, Goal)]] = [:]
        for (step, goal) in stepsWithGoal {
            let deadline = step.deadline
            let deadlineStartOfDay = Calendar.current.startOfDay(for: deadline)
            if organizedData[deadlineStartOfDay] == nil {
                organizedData[deadlineStartOfDay] = [(step, goal)]
            } else {
                organizedData[deadlineStartOfDay]?.append((step, goal))
            }
        }
        DispatchQueue.main.async {
            self.stepsByDate = organizedData // Assuming you have a property to hold this data
        }
    }
}
