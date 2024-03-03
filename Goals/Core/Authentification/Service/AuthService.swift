//
//  AuthService.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

import Firebase
import FirebaseAuth

class AuthService {
    @Published var userSession: FirebaseAuth.User?
    
    static let shared = AuthService()
    var pendingCredential: AuthCredential?
    
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await UserService.shared.fetchCurrentUser { success, error in
                // Handle the result of fetching the current user
                if success {
//                    print("DEBUG: User fetched successfully.")
                } else if let error = error {
                    print("Error fetching user: \(error)")
                }
            }
        }
    }

    @MainActor
    func loginWithPhoneNumber(verificationCode: String, verificationID: String, completion: @escaping (Bool, Error?) -> Void) async {
        do {
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
            let authResult = try await Auth.auth().signIn(with: credential)
            self.userSession = authResult.user
            await UserService.shared.fetchCurrentUser { success, error in
                completion(success, error)
            }
        } catch {
            print("DEBUG: Failed to login with phone number with error \(error.localizedDescription)")
            completion(false, error)
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
    
    func verifyPhoneNumber(verificationCode: String, verificationID: String) async throws -> AuthCredential {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        _ = try await Auth.auth().signIn(with: credential)
        return credential
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
    func finalizeRegistration(credential: AuthCredential, username: String) async throws {
        let authResult = try await Auth.auth().signIn(with: credential)
        self.userSession = authResult.user
        try await uploadUserData(phoneNumber: authResult.user.phoneNumber ?? "", username: username, id: authResult.user.uid)
        // Note: The uploadUserData method should handle the uploading of user data to your documents.
    }

    
    @MainActor
    private func uploadUserData(phoneNumber: String, username: String, id: String) async throws {
        let user = User(id: id, phoneNumber: phoneNumber, username: username.lowercased())
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try await FirestoreConstants.UserCollection.document(id).setData(encodedUser)
        UserService.shared.currentUser = user
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            UserService.shared.reset()
        } catch {
            print("DEBUG: Failed to sign out")
        }
    }
}
