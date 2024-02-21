//
//  GoalViewCellViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 21/02/2024.
//

import Foundation

class GoalViewCellViewModel: ObservableObject {
    let goalId: String
    @Published var evidences: [Evidence] = [] // Store fetched evidences

    init(goalId: String) {
        self.goalId = goalId
        Task {
            await fetchEvidenceForGoal()
        }
    }

    func fetchEvidenceForGoal() async {
        do {
            let fetchedEvidences = try await EvidenceService.fetchEvidences(forGoalId: goalId)
            DispatchQueue.main.async { // Ensure UI updates are on the main thread
                self.evidences = fetchedEvidences
            }
        } catch {
            print("DEBUG: Error fetching evidences: \(error)")
            // Consider error handling strategy here
        }
    }
}
