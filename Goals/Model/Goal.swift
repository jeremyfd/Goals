//
//  Goal.swift
//  Goals
//
//  Created by Work on 19/01/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Goal: Identifiable, Codable {
    @DocumentID private var goalId: String?

    let ownerUid: String
    let partnerUid: String
    let timestamp: Timestamp
    let title: String
    let frequency: Int
    let description: String?
    var duration: Int
    var currentCount: Int
    
    var id: String {
        return goalId ?? NSUUID().uuidString
    }
    
    var user: User?
}

struct Step: Identifiable {
    var id: String { "\(weekNumber)-\(day)" }
    var weekNumber: Int
    var day: Int
    var evidence: Evidence?
    var status: StepStatus
}

enum StepStatus: String {
    case completed = "Completed"
    case readyToSubmit = "Ready to Submit"
    case notStartedYet = "Not Started Yet"
    case failed = "Failed"
    case completePreviousStep = "Complete previous step"
}

