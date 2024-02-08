//
//  FirestoreConstants.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

import Firebase

struct FirestoreConstants {
    private static let Root = Firestore.firestore()
    
    static let UserCollection = Root.collection("users")
    
    static let FriendRequestsCollection = Root.collection("friendrequests")
    
    static let FriendsCollection = Root.collection("friends")
    
    static let GoalsCollection = Root.collection("goals")
    
    static let EvidenceCollection = Root.collection("evidence")
    
}
