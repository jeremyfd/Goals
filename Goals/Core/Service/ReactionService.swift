//
//  ReactionService.swift
//  Goals
//
//  Created by Jeremy Daines on 02/03/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct ReactionService {
        
        static func uploadReaction(_ reaction: Reaction) async throws -> String {
            print("DEBUG: Starting to upload reaction")
            let ref = try await FirestoreConstants.ReactionsCollection.addDocument(from: reaction)
            let documentID = ref.documentID
            print("DEBUG: Reaction uploaded with ID: \(documentID)")
            
            // Fetch the goal to get partnerUid
            print("DEBUG: Fetching goal for reaction with goalID: \(reaction.goalID)")
            let goal = try await GoalService.fetchGoal(goalId: reaction.goalID)
            print("DEBUG: Fetched goal with partnerUid: \(goal.partnerUid)")
            
            // Send notification
            print("DEBUG: Sending notification to ownerUid: \(goal.ownerUid)")
            await ActivityService.uploadNotification(toUid: goal.ownerUid, type: .react, goalId: goal.id, reactionType: reaction.type)
            print("DEBUG: Notification sent")
            
            return documentID
        }
    

    
    static func fetchReactions(forGoalId goalId: String) async throws -> [Reaction] {
        let querySnapshot = try await FirestoreConstants.ReactionsCollection.whereField("goalID", isEqualTo: goalId).getDocuments()
        
        let reactions: [Reaction] = querySnapshot.documents.compactMap { document -> Reaction? in
            try? document.data(as: Reaction.self)
        }
        return reactions
    }
    
    static func deleteReaction(reactionId: String) async throws {
        // Simply delete the cycle document from Firestore
        try await FirestoreConstants.ReactionsCollection.document(reactionId).delete()
    }
}
