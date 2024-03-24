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
    
    let goal = Goal(
        ownerUid: "123",
        partnerUid: "123",
        timestamp: Timestamp(),
        title: "Play the Piano",
        frequency: 5,
        description: "I want to play Lalaland",
        duration: 1,
        currentCount: 2,
        targetCount: 7,
        tier: 1)
    
    let evidence = Evidence(
        goalID: "123",
        cycleID: "123",
        stepID: "123",
        ownerUid: "123",
        partnerUid: "123",
        timestamp: Timestamp(),
        verified: false,
        weekNumber: 1,
        dayNumber: 2,
        imageUrl: "https://firebasestorage.googleapis.com:443/v0/b/goals-8509a.appspot.com/o/evidences_images%2F8B2B9356-DC9A-4E56-A0BF-AA89506A6FF2?alt=media&token=8178cbff-4bcb-4c7c-ba63-f290078b0c13"
        )
}
