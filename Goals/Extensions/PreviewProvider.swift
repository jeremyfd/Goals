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
    
    var user = User(
        id: NSUUID().uuidString,
        phoneNumber: "+33622003938",
        username: "daniel-ricciardo",
        profileImageUrl: nil,
        bio: "Daniel Ricciardo",
        fullName: "Daniel Ricciardo"
    )
    
}
