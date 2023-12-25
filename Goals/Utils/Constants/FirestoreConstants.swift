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
    
}
