//
//  UserService.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

import Firebase
import FirebaseFirestoreSwift

class UserService {
    
    @Published var currentUser: User?
    
    static let shared = UserService()
    private static let userCache = NSCache<NSString, NSData>()
    
    @MainActor
    private func uploadUserData(phoneNumber: String, username: String, id: String) async throws {
        let user = User(id: id, phoneNumber: phoneNumber, username: username.lowercased())
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try await FirestoreConstants.UserCollection.document(id).setData(encodedUser)
        UserService.shared.currentUser = user
    }
    
    func updateUserName(withNewName name: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw CustomError.userNotLoggedIn }
        
        let updateField = ["fullName": name]
        try await FirestoreConstants.UserCollection.document(uid).updateData(updateField)
        
        // Update the local current user's name
        if var currentUser = currentUser {
            currentUser.fullName = name
            self.currentUser = currentUser
        }
    }
    
    @MainActor
    func fetchCurrentUser(completion: @escaping (Bool, Error?) -> Void) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false, CustomError.userNotLoggedIn) // Define CustomError as needed
            return
        }
        
        do {
            let snapshot = try await FirestoreConstants.UserCollection.document(uid).getDocument()
            let user: User? = try snapshot.data(as: User.self)
            if let unwrappedUser = user {
                self.currentUser = unwrappedUser
                completion(true, nil)
            } else {
                completion(false, CustomError.userNotFound)
            }

            self.currentUser = user
            completion(true, nil)
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            completion(false, error)
        } catch {
            print("Error fetching user: \(error)")
            completion(false, error)
        }
    }

    
    static func fetchUser(withUid uid: String) async throws -> User {
        if let nsData = userCache.object(forKey: uid as NSString) {
            if let user = try? JSONDecoder().decode(User.self, from: nsData as Data) {
                return user
            }
        }
        
        let snapshot = try await FirestoreConstants.UserCollection.document(uid).getDocument()
        let user = try snapshot.data(as: User.self)
        
        if let userData = try? JSONEncoder().encode(user) {
            userCache.setObject(userData as NSData, forKey: uid as NSString)
        }
        
        return user
    }
    
    static func fetchUsers() async throws -> [User] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        let snapshot = try await FirestoreConstants.UserCollection.getDocuments()
        let users = snapshot.documents.compactMap({ try? $0.data(as: User.self) })
        return users.filter({ $0.id != uid })
    }
    
    static func usernameExists(_ username: String) async throws -> Bool {
        let querySnapshot = try await FirestoreConstants.UserCollection
            .whereField("username", isEqualTo: username.lowercased())
            .getDocuments()
        return !querySnapshot.documents.isEmpty
    }
    
    static func phoneNumberExists(_ phoneNumber: String) async throws -> Bool {
        let querySnapshot = try await FirestoreConstants.UserCollection
            .whereField("phoneNumber", isEqualTo: phoneNumber)
            .getDocuments()
        return !querySnapshot.documents.isEmpty
    }
    
    func reset() {
        self.currentUser = nil
    }
    
}

// MARK: - Friend Requests and Management

extension UserService {
    // Send a friend request
    @MainActor
    func sendFriendRequest(toUid uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await FirestoreConstants
            .FriendRequestsCollection
            .document(currentUid)
            .collection("sent-requests")
            .document(uid)
            .setData([:])
        
        try await FirestoreConstants
            .FriendRequestsCollection
            .document(uid)
            .collection("received-requests")
            .document(currentUid)
            .setData([:])
        
        ActivityService.uploadNotification(toUid: uid, type: .friend)
        
    }
    
    // Accept a friend request
    @MainActor
    func acceptFriendRequest(fromUid uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Add each other as friends and remove the friend request in parallel
        async let addFriendForCurrentUser = FirestoreConstants
            .FriendsCollection
            .document(currentUid)
            .collection("user-friends")
            .document(uid)
            .setData([:])
        
        async let addFriendForOtherUser = FirestoreConstants
            .FriendsCollection
            .document(uid)
            .collection("user-friends")
            .document(currentUid)
            .setData([:])
        
        async let removeRequest = removeFriendRequest(fromUid: uid)
        
        // Update feeds for both users
        async let updateFeedForCurrentUser = updateUserFeedAfterFriend(followedUid: uid, targetUserId: currentUid)
        async let updateFeedForOtherUser = updateUserFeedAfterFriend(followedUid: currentUid, targetUserId: uid)
        
        // Await all operations to complete
        _ = try await (addFriendForCurrentUser, addFriendForOtherUser, removeRequest, updateFeedForCurrentUser, updateFeedForOtherUser)
    }


    
    // Reject a friend request
    @MainActor
    func rejectFriendRequest(fromUid uid: String) async throws {
        // Simply remove the friend request
        async let _ = try await removeFriendRequest(fromUid: uid)
    }
    
    // Remove a friend
    @MainActor
    func removeFriend(uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Remove each other as friends
        async let removeForCurrentUser = FirestoreConstants
            .FriendsCollection
            .document(currentUid)
            .collection("user-friends")
            .document(uid)
            .delete()
        
        async let removeForOtherUser = FirestoreConstants
            .FriendsCollection
            .document(uid)
            .collection("user-friends")
            .document(currentUid)
            .delete()
        
        // Update feeds for both users to reflect the removal of friendship
        async let updateFeedForCurrentUser = updateUserFeedAfterUnfriend(unfollowedUid: uid, targetUserId: currentUid)
        async let updateFeedForOtherUser = updateUserFeedAfterUnfriend(unfollowedUid: currentUid, targetUserId: uid)
        
        // Await all operations to complete
        _ = try await (removeForCurrentUser, removeForOtherUser, updateFeedForCurrentUser, updateFeedForOtherUser)
    }


    
    // Helper function to remove a friend request
    private func removeFriendRequest(fromUid uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        async let _ = try await FirestoreConstants
            .FriendRequestsCollection
            .document(currentUid)
            .collection("received-requests")
            .document(uid)
            .delete()
        
        async let _ = try await FirestoreConstants
            .FriendRequestsCollection
            .document(uid)
            .collection("sent-requests")
            .document(currentUid)
            .delete()
    }
    
    // Unsend a friend request
    @MainActor
    func unsendFriendRequest(toUid uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await FirestoreConstants
            .FriendRequestsCollection
            .document(currentUid)
            .collection("sent-requests")
            .document(uid)
            .delete()
        
        try await FirestoreConstants
            .FriendRequestsCollection
            .document(uid)
            .collection("received-requests")
            .document(currentUid)
            .delete()
        
        async let _ = try await ActivityService.deleteNotification(toUid: uid, type: .friend)
    }
    
    // Delete a received friend request
    @MainActor
    func deleteReceivedFriendRequest(fromUid uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await FirestoreConstants
            .FriendRequestsCollection
            .document(currentUid)
            .collection("received-requests")
            .document(uid)
            .delete()
        
        try await FirestoreConstants
            .FriendRequestsCollection
            .document(uid)
            .collection("sent-requests")
            .document(currentUid)
            .delete()
    }
    
    // Check if a user is already a friend
    static func checkIfUserIsFriendWithUid(_ uid: String) async -> Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        let collection = FirestoreConstants.FriendsCollection.document(currentUid).collection("user-friends")
        guard let snapshot = try? await collection.document(uid).getDocument() else { return false }
        return snapshot.exists
    }
    
    static func checkIfUserIsFriend(_ user: User) async -> Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        let collection = FirestoreConstants.FriendsCollection.document(currentUid).collection("user-friends")
        guard let snapshot = try? await collection.document(user.id).getDocument() else { return false }
        return snapshot.exists
    }
    
    static func checkIfRequestSent(toUid targetUid: String) async throws -> Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        let document = try await FirestoreConstants
            .FriendRequestsCollection
            .document(currentUid)
            .collection("sent-requests")
            .document(targetUid)
            .getDocument()
        
        return document.exists
    }
    
    static func checkIfRequestReceived(fromUid targetUid: String) async throws -> Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        let document = try await FirestoreConstants
            .FriendRequestsCollection
            .document(currentUid)
            .collection("received-requests")
            .document(targetUid)
            .getDocument()
        
        return document.exists
    }
}


// MARK: - Feed Updates

extension UserService {
    // Update to include a targetUserId parameter
    func updateUserFeedAfterFriend(followedUid: String, targetUserId: String) async throws {
        let goalsSnapshot = try await FirestoreConstants.GoalsCollection.whereField("ownerUid", isEqualTo: followedUid).getDocuments()
        
        for document in goalsSnapshot.documents {
            try await FirestoreConstants
                .UserCollection
                .document(targetUserId) // Use targetUserId instead of currentUid
                .collection("user-feed")
                .document(document.documentID)
                .setData([:])
        }
    }

    // Update to include a targetUserId parameter
    func updateUserFeedAfterUnfriend(unfollowedUid: String, targetUserId: String) async throws {
        let goalsSnapshot = try await FirestoreConstants.GoalsCollection.whereField("ownerUid", isEqualTo: unfollowedUid).getDocuments()
        
        for document in goalsSnapshot.documents {
            try await FirestoreConstants
                .UserCollection
                .document(targetUserId) // Use targetUserId instead of currentUid
                .collection("user-feed")
                .document(document.documentID)
                .delete()
        }
    }
}

// MARK: - ImageService

extension UserService {
    
    @MainActor
    func updateUserProfileImage(withImageUrl imageUrl: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await Firestore.firestore().collection("users").document(currentUid).updateData([
            "profileImageUrl": imageUrl
        ])
        
        self.currentUser?.profileImageUrl = imageUrl
    }
}



enum CustomError: Error {
    case userNotLoggedIn
    case userNotFound
    case decodingError
    case unknownError
}
