//
//  GoalService.swift
//  Goals
//
//  Created by Work on 21/01/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct GoalService {
    
    static func uploadGoal(_ goal: Goal) async throws {
        guard let goalData = try? Firestore.Encoder().encode(goal) else { return }
        let ref = try await FirestoreConstants.GoalsCollection.addDocument(data: goalData)
        try await updateUserFeedsAfterPost(goalId: ref.documentID)
    }
    
    static func fetchGoals() async throws -> [Goal] {
        let snapshot = try await FirestoreConstants
            .GoalsCollection
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap({ try? $0.data(as: Goal.self) })
    }
    
    static func fetchGoal(goalId: String) async throws -> Goal {
//        print("DEBUG: Fetching goal with ID: \(goalId)")
        let snapshot = try await FirestoreConstants.GoalsCollection.document(goalId).getDocument()
        let goal = try snapshot.data(as: Goal.self)
//        print("DEBUG: Successfully fetched goal: \(goal)")
        return goal
    }
    
    static func fetchUserGoals(uid: String) async throws -> [Goal] {
        let query = FirestoreConstants.GoalsCollection.whereField("ownerUid", isEqualTo: uid)
        let snapshot = try await query.getDocuments()
        
        let goals = snapshot.documents.compactMap({ try? $0.data(as: Goal.self) })
        return goals.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
    }
    
    private static func updateUserFeedsAfterPost(goalId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let followersSnapshot = try await FirestoreConstants.FriendsCollection.document(uid).collection("user-friends").getDocuments()
        
        for document in followersSnapshot.documents {
            try await FirestoreConstants
                .UserCollection
                .document(document.documentID)
                .collection("user-feed")
                .document(goalId).setData([:])
        }
        
        try await FirestoreConstants.UserCollection.document(uid).collection("user-feed").document(goalId).setData([:])
    }
    
    static func deleteGoal(goalId: String) async throws {
        // Attempt to delete the goal document from Firestore
        try await FirestoreConstants.GoalsCollection.document(goalId).delete()
        
        // Cleanup: Remove the goal from all user feeds
        try await removeGoalFromUserFeeds(goalId: goalId)
    }
    
    private static func removeGoalFromUserFeeds(goalId: String) async throws {
        // Query all users to find which feeds contain the goalId, this might need optimization for large datasets
        let usersSnapshot = try await FirestoreConstants.UserCollection.getDocuments()
        for userDocument in usersSnapshot.documents {
            let feedSnapshot = try await FirestoreConstants
                .UserCollection
                .document(userDocument.documentID)
                .collection("user-feed")
                .whereField(FieldPath.documentID(), isEqualTo: goalId)
                .getDocuments()
            
            for feedDocument in feedSnapshot.documents {
                // Delete the goal from the user's feed
                try await FirestoreConstants
                    .UserCollection
                    .document(userDocument.documentID)
                    .collection("user-feed")
                    .document(feedDocument.documentID)
                    .delete()
            }
        }
    }
}
