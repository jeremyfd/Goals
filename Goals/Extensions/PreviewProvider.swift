//
//  PreviewProvider.swift
//  Goals
//
//  Created by Work on 11/01/2024.
//

import SwiftUI
import Firebase

extension PreviewProvider {
    static var dev: DeveloperPreview {
        return DeveloperPreview.shared
    }
}

class DeveloperPreview: ObservableObject {
    static let shared = DeveloperPreview()
    
    let user = User(
        id: NSUUID().uuidString,
        phoneNumber: "+33622003938",
        username: "daniel-ricciardo",
        profileImageUrl: nil,
        bio: "Daniel Ricciardo",
        fullName: "Daniel Ricciardo"
    )
    
    let goal = Goal(ownerUid: "123", partnerUid: "123", timestamp: Timestamp(), title: "Play the Piano", frequency: 5, description: "I want to play Lalaland", duration: 1, currentCount: 2)
}
