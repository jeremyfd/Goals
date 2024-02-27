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
}

