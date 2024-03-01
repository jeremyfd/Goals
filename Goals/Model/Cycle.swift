//
//  Cycle.swift
//  Goals
//
//  Created by Jeremy Daines on 28/02/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Cycle: Identifiable, Codable, Hashable {
    @DocumentID var cycleId: String?
    
    var goalID: String
    var startDate: Date
    var tier: Int
    
    var id: String {
        return cycleId ?? NSUUID().uuidString
    }
}
