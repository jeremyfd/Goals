//
//  Reaction.swift
//  Goals
//
//  Created by Jeremy Daines on 02/03/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Reaction: Identifiable, Hashable, Codable {
    @DocumentID var reactionId: String?
    
    var goalID: String
    var type: String
    var ownerUid: String
    
    var id: String {
        return reactionId ?? NSUUID().uuidString
    }
    
}
