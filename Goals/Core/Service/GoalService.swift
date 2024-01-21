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
        try await FirestoreConstants.GoalsCollection.addDocument(data: goalData)
//        try await updateUserFeedsAfterPost(threadId: ref.documentID)
    }
}
