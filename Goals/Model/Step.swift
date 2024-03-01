//
//  Step.swift
//  Goals
//
//  Created by Jeremy Daines on 28/02/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Step: Identifiable, Hashable, Codable {
    @DocumentID var stepId: String?
    
    var cycleID: String
    var goalID: String
    let weekNumber: Int
    let dayNumber: Int
    var status: StepStatus
    var deadline: Date
    var tier: Int
    
    var id: String {
        return stepId ?? NSUUID().uuidString
    }
}

enum StepStatus: String, Codable {
    case readyToSubmit = "Ready to Submit"
    case completed = "Completed"
    case completePreviousStep = "Complete previous step" // Note the typo in "previous"
    case failed = "Failed"
    case notStartedYet = "Not Started Yet"
}
