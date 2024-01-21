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
    @DocumentID private var threadId: String?

    let ownerUID: String
    let partnerUID: String
    let timestamp: Timestamp
    let title: String
    let frequency: Int
    
    var id: String {
        return threadId ?? NSUUID().uuidString
    }
    
    var user: User?
    
}
