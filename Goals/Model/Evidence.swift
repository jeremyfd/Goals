//
//  Evidence.swift
//  Goals
//
//  Created by Jeremy Daines on 15/02/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Evidence: Identifiable, Codable, Hashable {
    @DocumentID var evidenceId: String?
    
    let goalID: String
    let cycleID: String
    let stepID: String
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

