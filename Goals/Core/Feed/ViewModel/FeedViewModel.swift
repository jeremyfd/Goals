//
//  FeedViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 06/02/2024.
//

import Foundation
import Combine
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var goalsWithEvidences: [(goal: Goal, evidences: [Evidence])] = []
    @Published var currentUser: User?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser
            .sink { [weak self] user in
                self?.currentUser = user
                // Optionally, you can initiate data fetching here if you want to auto-load data when the user is set
                // self?.fetchDataForYourContracts()
            }
            .store(in: &cancellables)
    }
    
    func fetchDataForYourContracts() {
        guard let uid = currentUser?.id else { return }

        Task {
            do {
                let goalIDs = try await GoalService.fetchPartnerGoalIDs(uid: uid)
                var tempGoalsWithEvidences: [(Goal, [Evidence])] = []

                for goalID in goalIDs {
                    let goal = try await GoalService.fetchGoalDetails(goalId: goalID)
                    let evidences = try await EvidenceService.fetchEvidences(forGoalId: goal.id)
                    tempGoalsWithEvidences.append((goal, evidences))
                }

                DispatchQueue.main.async {
                    self.goalsWithEvidences = tempGoalsWithEvidences
                }
            } catch {
                print("Error fetching goals and evidences: \(error)")
            }
        }
    }

    func fetchDataForYourFriendsContracts() {
        guard let uid = currentUser?.id else { return }

        Task {
            do {
                let goalIDs = try await GoalService.fetchFriendGoalIDs(uid: uid)
                var tempGoalsWithEvidences: [(Goal, [Evidence])] = []

                for goalID in goalIDs {
                    let goal = try await GoalService.fetchGoalDetails(goalId: goalID)
                    let evidences = try await EvidenceService.fetchEvidences(forGoalId: goal.id)
                    tempGoalsWithEvidences.append((goal, evidences))
                }

                DispatchQueue.main.async {
                    self.goalsWithEvidences = tempGoalsWithEvidences
                }
            } catch {
                print("Error fetching goals and evidences: \(error)")
            }
        }
    }
}
