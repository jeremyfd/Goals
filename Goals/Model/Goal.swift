//
//  Goal.swift
//  Goals
//
//  Created by Work on 19/01/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Goal: Identifiable, Codable, Hashable {
    @DocumentID private var goalId: String?

    let ownerUid: String
    let partnerUid: String
    let timestamp: Timestamp
    let title: String
    let frequency: Int
    let description: String?
    var duration: Int
    var currentCount: Int
    var targetCount: Int
    var tier: Int
    
    var id: String {
        return goalId ?? NSUUID().uuidString
    }
    
    var user: User?    
}

enum GoalType: Int, CaseIterable, Identifiable, Codable {
    case friendGoalFeed
    case partnerGoalFeed
    
    var id: Int { return self.rawValue }
}
