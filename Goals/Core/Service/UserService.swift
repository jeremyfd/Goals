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
    
    @MainActor
    func fetchCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let snapshot = try await FirestoreConstants.UserCollection.document(uid).getDocument()
        let user = try snapshot.data(as: User.self)
        self.currentUser = user
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
}
