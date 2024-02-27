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
        try await updatePartnerFeedAfterPost(goalId: ref.documentID, partnerUid: goal.partnerUid)
        
        ActivityService.uploadNotification(toUid: goal.partnerUid, type: .friendGoal, goalId: ref.documentID)
    }

    private static func updatePartnerFeedAfterPost(goalId: String, partnerUid: String) async throws {
        // Update the "user-feed-partner" for the partner user
        try await FirestoreConstants.UserCollection
            .document(partnerUid)
            .collection("user-feed-partner")
            .document(goalId).setData([:])
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
    
    static func fetchPartnerGoals(uid: String) async throws -> [Goal] {
        let snapshot = try await FirestoreConstants.UserCollection
            .document(uid)
            .collection("user-feed-partner")
            .getDocuments()
        
        return snapshot.documents.compactMap({ try? $0.data(as: Goal.self) })
    }
    
    static func fetchPartnerGoalIDs(uid: String) async throws -> [String] {
        let snapshot = try await FirestoreConstants.UserCollection
            .document(uid)
            .collection("user-feed-partner")
            .getDocuments()

        return snapshot.documents.map { $0.documentID }
    }
    
    static func fetchFriendGoalIDs(uid: String) async throws -> [String] {
        let snapshot = try await FirestoreConstants.UserCollection
            .document(uid)
            .collection("user-feed")
            .getDocuments()

        return snapshot.documents.map { $0.documentID }
    }
    
    static func fetchGoalDetails(goalId: String) async throws -> Goal {
        let snapshot = try await FirestoreConstants.GoalsCollection.document(goalId).getDocument()
        guard let goal = try? snapshot.data(as: Goal.self) else { throw NSError() }
        return goal
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
        //add if want to add own goals to user-feed
//        try await FirestoreConstants.UserCollection.document(uid).collection("user-feed").document(goalId).setData([:])
    }
    
    static func deleteGoal(goalId: String) async throws {
        // First, attempt to fetch the goal to get the partnerUid
        let goalDocumentSnapshot = try await FirestoreConstants.GoalsCollection.document(goalId).getDocument()
        if let goal = try? goalDocumentSnapshot.data(as: Goal.self) {
            // Proceed with cleanup before deleting the goal document
            // Remove the goal from all user feeds
            try await removeGoalFromUserFeeds(goalId: goalId)
            
            // Remove the goal from the partner's feed, now that we have the partnerUid
            try await removeGoalFromPartnerFeeds(goalId: goalId, partnerUid: goal.partnerUid)
            
            // Finally, delete the goal document from Firestore
            try await FirestoreConstants.GoalsCollection.document(goalId).delete()
        } else {
            // Handle the case where the goal doesn't exist or couldn't be fetched
            print("Error: Goal document with ID \(goalId) could not be fetched or does not exist.")
            // Optionally, throw a custom error if needed
        }
    }

    
    private static func removeGoalFromPartnerFeeds(goalId: String, partnerUid: String) async throws {
        // Directly attempt to delete the goal from the partner's "user-feed-partner" without fetching the goal
        try await FirestoreConstants.UserCollection
            .document(partnerUid)
            .collection("user-feed-partner")
            .document(goalId)
            .delete()
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
    
    static func incrementCurrentCountForGoal(goalId: String) async throws {
        let goalRef = FirestoreConstants.GoalsCollection.document(goalId)
        var needToIncrementTier = false // Flag to track whether we need to increment the tier

        // Synchronous transaction to increment currentCount
        let transactionResult = try await Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            let goalDocument: DocumentSnapshot
            do {
                goalDocument = try transaction.getDocument(goalRef)
            } catch let fetchError {
                errorPointer?.pointee = fetchError as NSError
                return nil
            }

            guard let currentCount = goalDocument.data()?["currentCount"] as? Int,
                  let targetCount = goalDocument.data()?["targetCount"] as? Int else {
                return nil
            }

            // Increment currentCount
            transaction.updateData(["currentCount": currentCount + 1], forDocument: goalRef)

            // Check if we need to increment the tier after this update
            if currentCount + 1 == targetCount {
                needToIncrementTier = true
            }

            return nil
        })

        // After the transaction, check if we need to increment the tier
        if needToIncrementTier {
            // Asynchronously increment the tier
            try await incrementTierForGoal(goalId: goalId)
        }

        // Handle any errors from the transaction
        if let transactionError = transactionResult as? Error {
            throw transactionError
        }
    }
    
    static func incrementTierForGoal(goalId: String) async throws {
        let goalRef = FirestoreConstants.GoalsCollection.document(goalId)
        
        try await Firestore.firestore().runTransaction { transaction, errorPointer in
            let goalDocument: DocumentSnapshot
            do {
                try goalDocument = transaction.getDocument(goalRef)
            } catch let fetchError {
                errorPointer?.pointee = fetchError as NSError
                return nil
            }

            guard let tier = goalDocument.data()?["tier"] as? Int else {
                return nil
            }

            transaction.updateData(["tier": tier + 1], forDocument: goalRef)
            return nil
        }
    }
}
