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
    @Published var evidencesByStep: [String: [Evidence]] = [:] // Maps step IDs to their evidences
    @Published var reactionUsernames: [String: [String]] = [:] // Maps reaction types to usernames
    @Published var reactionCounts: [String: [String: Int]] = [:] // Maps reaction types to user names and their reaction counts
    @Published var stepDescription: String?
    @Published var isStepVerified: Bool = false

    
    let uid = Auth.auth().currentUser?.uid

    init(goalId: String) {
        self.goalId = goalId
        Task {
            await fetchEvidenceForGoal()
            await fetchReactionsForGoal()
        }
    }

    func fetchEvidenceForGoal() async {
        do {
            let fetchedEvidences = try await EvidenceService.fetchEvidences(forGoalId: goalId)
            DispatchQueue.main.async { // Ensure UI updates are on the main thread
                // Organize evidences by step ID
                var evidencesByStepTemp: [String: [Evidence]] = [:]
                for evidence in fetchedEvidences {
                    evidencesByStepTemp[evidence.stepID, default: []].append(evidence)
                }
                self.evidencesByStep = evidencesByStepTemp
            }
        } catch {
            print("DEBUG: Error fetching evidences: \(error)")
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
    
    func fetchReactionsForGoal() async {
        do {
            let fetchedReactions = try await ReactionService.fetchReactions(forGoalId: goalId)
            var tempReactionCounts: [String: [String: Int]] = [:]
            
            for reaction in fetchedReactions {
                let user = try await UserService.fetchUser(withUid: reaction.ownerUid)
                let username = user.username
                
                if tempReactionCounts[reaction.type] != nil {
                    tempReactionCounts[reaction.type]?[username, default: 0] += 1
                } else {
                    tempReactionCounts[reaction.type] = [username: 1]
                }
            }
            
            DispatchQueue.main.async {
                self.reactionCounts = tempReactionCounts
            }
        } catch {
            print("DEBUG: Error fetching reactions or user data: \(error)")
        }
    }
    
    func fetchStepDescriptionAndVerifyStatus(stepID: String) {
        Task {
            do {
                let step = try await StepService.fetchStep(stepId: stepID)
                DispatchQueue.main.async {
                    self.stepDescription = step.description
                    // Assume your Step model has an isVerified field
                    self.isStepVerified = step.isVerified ?? false
                }
            } catch {
                print("Error fetching step details: \(error.localizedDescription)")
            }
        }
    }

    
    func verifyStep(stepId: String, isVerified: Bool) {
        Task {
            do {
                try await StepService.updateStepVerification(stepId: stepId, isVerified: isVerified, goalId: self.goalId)
                await fetchStepDescriptionAndVerifyStatus(stepID: stepId)
            } catch {
                print("Error verifying step: \(error.localizedDescription)")
            }
        }
    }

}
