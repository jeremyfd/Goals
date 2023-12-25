//
//  AuthService.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

import Firebase

class AuthService {
    @Published var userSession: FirebaseAuth.User?
    
    static let shared = AuthService()
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task { try await UserService.shared.fetchCurrentUser() }
    }
    
    @MainActor
    func loginWithPhoneNumber(verificationCode: String, verificationID: String) async throws {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)

        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            self.userSession = authResult.user
            // Fetch or update user data as necessary
        } catch {
            // Handle errors
            print("DEBUG: Failed to login with phone number with error \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func sendVerificationCode(to phoneNumber: String) async throws -> String {
        do {
            let verificationID = try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil)
            return verificationID
        } catch {
            // Handle errors
            print("DEBUG: Failed to send verification code with error \(error.localizedDescription)")
            throw error
        }
    }

    @MainActor
    func verifyCodeAndCreateUser(verificationCode: String, verificationID: String, username: String) async throws {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)

        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            // Proceed with user creation or updating user data
            let userId = authResult.user.uid
            try await uploadUserData(phoneNumber: authResult.user.phoneNumber ?? "", username: username, id: userId)
        } catch {
            // Handle errors
            print("DEBUG: Failed to verify code with error \(error.localizedDescription)")
            throw error
        }
        self.userSession = Auth.auth().currentUser
    }
    
    @MainActor
    private func uploadUserData(phoneNumber: String, username: String, id: String) async throws {
        let user = User(phoneNumber: phoneNumber, username: username.lowercased(), id: id)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try await FirestoreConstants.UserCollection.document(id).setData(encodedUser)
        UserService.shared.currentUser = user
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
        } catch {
            print("DEBUG: Failed to sign out")
        }
    }
}
