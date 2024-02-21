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
    
    var id: String {
        return activityModelId ?? NSUUID().uuidString
    }
}

enum ActivityType: Int, CaseIterable, Identifiable, Codable {
    case like
    case reply
    case follow
    
    var id: Int { return self.rawValue }
}

