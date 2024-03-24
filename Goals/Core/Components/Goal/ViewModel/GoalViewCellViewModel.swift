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
    @Published var reactionUsernames: [String: [String]] = [:] // Maps reaction types to usernames
    @Published var reactionCounts: [String: [String: Int]] = [:] // Maps reaction types to user names and their reaction counts
    @Published var stepDescription: String?
    
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
    
    func fetchStepDescription(stepID: String) {
        Task {
            do {
                let step = try await StepService.fetchStep(stepId: stepID)
                DispatchQueue.main.async {
                    self.stepDescription = step.description
                }
            } catch {
                print("Error fetching step description: \(error.localizedDescription)")
            }
        }
    }
}
