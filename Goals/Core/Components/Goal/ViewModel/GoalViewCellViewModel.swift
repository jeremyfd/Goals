//
//  GoalViewCellViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 21/02/2024.
//

import Foundation
import Firebase
import Combine

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
    
    func uploadReaction(type: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let reaction = Reaction(goalID: goalId, type: type, ownerUid: uid)

        do {
            let reactionId = try await ReactionService.uploadReaction(reaction)
            print("DEBUG: Uploaded reaction with ID: \(reactionId)")
        } catch {
            print("DEBUG: Error uploading reaction: \(error)")
        }
    }
}
