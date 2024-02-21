//
//  ActivityService.swift
//  Goals
//
//  Created by Jeremy Daines on 21/02/2024.
//

import Firebase
import FirebaseFirestoreSwift

struct ActivityService {
    static func fetchUserActivity() async throws -> [Activity] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await FirestoreConstants
            .ActivityCollection
            .document(uid)
            .collection("user-notifications")
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap({ try? $0.data(as: Activity.self) })
    }
    
    static func uploadNotification(toUid uid: String, type: ActivityType, goalId: String? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return }
        
        let model = Activity(
            type: type,
            senderUid: currentUid,
            timestamp: Timestamp(),
            goalId: goalId
        )
        
        guard let data = try? Firestore.Encoder().encode(model) else { return }
        
        FirestoreConstants.ActivityCollection.document(uid).collection("user-notifications").addDocument(data: data)
    }
    
    static func deleteNotification(toUid uid: String, type: ActivityType, goalId: String? = nil) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let snapshot = try await FirestoreConstants
            .ActivityCollection
            .document(uid)
            .collection("user-notifications")
            .whereField("uid", isEqualTo: currentUid)
            .getDocuments()
        
        for document in snapshot.documents {
            let notification = try? document.data(as: Activity.self)
            guard notification?.type == type else { return }
            
            if goalId != nil {
                guard goalId == notification?.goalId else { return }
            }
            
            try await document.reference.delete()
        }
    }
}
