//
//  User.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

import FirebaseFirestoreSwift
import Firebase
import Foundation

struct User: Identifiable, Codable {
    let id: String
    let phoneNumber : String
    let username: String
    var profileImageUrl: String?
    var bio: String?
    var link: String?
    var stats: UserStats?
    
    var isCurrentUser: Bool {
        return id == Auth.auth().currentUser?.uid
    }
}

struct UserStats: Codable {
    var followersCount: Int
    var followingCount: Int
    var threadsCount: Int
}

extension User: Hashable {
    var identifier: String { return id }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
