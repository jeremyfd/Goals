//
//  Evidence.swift
//  Goals
//
//  Created by Jeremy Daines on 09/02/2024.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Evidence: Identifiable, Codable {
    @DocumentID private var evidenceId: String?
    
    let goalID: String
    let weekNumber: Int
    let day: Int
    var imageURL: String?
    let timestamp: Timestamp
    var isVerified: Bool
    
    var id: String {
        return evidenceId ?? NSUUID().uuidString
    }
}
