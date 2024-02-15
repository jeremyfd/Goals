//
//  Evidence.swift
//  Goals
//
//  Created by Jeremy Daines on 15/02/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Evidence: Identifiable, Codable {
    @DocumentID var evidenceId: String?
    
    let goalID: String
    let ownerUid: String
    let partnerUid: String
    let timestamp: Timestamp
    var verified: Bool
    let weekNumber: Int
    let dayNumber: Int
    var imageUrl: String
    let description: String?
    
    var id: String {
        return evidenceId ?? NSUUID().uuidString
    }
    
    var user: User?
}

// Enum to represent the status of each step
enum StepStatus: String {
    case readyToSubmit = "Ready to Submit"
    case completed = "Completed"
    case completePreviousStep = "Complete preivous step"
    case failed = "Failed"
    case notStartedYet = "Not Started Yet"
}

// Model to represent a step in achieving a goal
struct Step: Identifiable {
    var id = UUID() // Provides a unique identifier for each step
    let weekNumber: Int // The week number of the step within the goal's duration
    let dayNumber: Int // The day number within the specific week
    var evidence: Evidence? // Optional evidence submitted for this step
    var status: StepStatus // The current status of the step
    
    // Additional properties can be added as needed, such as a detailed description or specific targets for each step.
}

