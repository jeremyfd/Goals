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
    var pendingCredential: AuthCredential?
    
    
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
    func verifyPhoneNumber(verificationCode: String, verificationID: String) async throws {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)

        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            // Store the credential for later use instead of signing in immediately
            self.pendingCredential = credential
        } catch {
            print("DEBUG: Verification failed with error \(error.localizedDescription)")
            throw error // Make sure this error is thrown for incorrect codes
        }
    }

    
    
    @MainActor
    func loginWithCredential(credential: AuthCredential, username: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            self.userSession = authResult.user
            // Assuming you want to upload user data immediately after signing in
            try await uploadUserData(phoneNumber: authResult.user.phoneNumber ?? "", username: username, id: authResult.user.uid)
        } catch {
            // Handle errors
            print("DEBUG: Failed to sign in with credential with error \(error.localizedDescription)")
            throw error
        }
    }
    
    
    @MainActor
    func createUser(username: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user not found."])
        }
        let userId = user.uid
        try await uploadUserData(phoneNumber: user.phoneNumber ?? "", username: username, id: userId)
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
