//
//  Activity.swift
//  Goals
//
//  Created by Jeremy Daines on 21/02/2024.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct Activity: Identifiable, Codable, Hashable {
    @DocumentID private var activityModelId: String?
    let type: ActivityType
    let senderUid: String
    let timestamp: Timestamp
    var goalId: String?
    
    var user: User?
    var goal: Goal?
    var isFriend: Bool?
    
    var reactionType: String?
    
    var id: String {
        return activityModelId ?? NSUUID().uuidString
    }
}

enum ActivityType: Int, CaseIterable, Identifiable, Codable {
    case react
    case friendGoal
    case partnerGoal
    case friend
    case evidence
    
    var id: Int { return self.rawValue }
}

