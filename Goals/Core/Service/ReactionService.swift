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
        let ref = try await FirestoreConstants.ReactionsCollection.addDocument(from: reaction)
        return ref.documentID
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
