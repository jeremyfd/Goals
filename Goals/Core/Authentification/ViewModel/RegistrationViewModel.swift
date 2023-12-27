//
//  RegistrationViewModel.swift
//  Goals
//
//  Created by Work on 25/12/2023.
//

import FirebaseAuth

class RegistrationViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var verificationCode = ""
    @Published var username = ""
    @Published var isAuthenticating = false
    @Published var isCodeVerified = false
    @Published var showAlert = false
    @Published var errorMessage: String?
    
    var verificationID: String?
    
    @MainActor
    func sendVerificationCode() async {
        guard !phoneNumber.isEmpty else {
            errorMessage = "Please enter a phone number."
            showAlert = true
            return
        }
        
        isAuthenticating = true
        do {
            // Check if phone number already exists
            let phoneNumberExists = try await UserService.phoneNumberExists(phoneNumber)
            if phoneNumberExists {
                errorMessage = "An account with this phone number already exists. Please sign in."
                showAlert = true
                isAuthenticating = false
                return
            }
            
            verificationID = try await AuthService.shared.sendVerificationCode(to: phoneNumber)
            isAuthenticating = false
        } catch let error as NSError {
            errorMessage = "Error: \(error.localizedDescription)"
            showAlert = true
            isAuthenticating = false
            verificationID = nil // Ensure this is nil on failure
        }
    }
    
    
    @MainActor
    func verifyCode() async {
        print("DEBUG: Verify Code started")

        guard let verificationID = verificationID else {
            errorMessage = "Verification ID not found."
            showAlert = true
            return
        }
        
        isAuthenticating = true
        do {
            let credential = try await AuthService.shared.verifyPhoneNumber(verificationCode: verificationCode, verificationID: verificationID)
            AuthService.shared.pendingCredential = credential
            isCodeVerified = true
        } catch let error as NSError {
            print("DEBUG: Verification failed: \(error.localizedDescription)")
            errorMessage = "Failed to verify code: \(error.localizedDescription)"
            showAlert = true
            isCodeVerified = false
            AuthService.shared.pendingCredential = nil
        }
        isAuthenticating = false
        
        print("DEBUG: Verify Code ended")
    }
    
    
    @MainActor
    func finalizeRegistration(username: String) async {
        
        // Username validation
        guard !username.isEmpty else {
            errorMessage = "Please enter a username."
            showAlert = true
            return
        }
        
        // Check if username already exists
        do {
            // Check if username already exists
            let usernameExists = try await UserService.usernameExists(username)
            if usernameExists {
                errorMessage = "This username is already taken. Please choose another."
                showAlert = true
                return
            }
        } catch {
            errorMessage = "Failed to check username: \(error.localizedDescription)"
            showAlert = true
            return
        }
        
        // Credential validation
        guard AuthService.shared.pendingCredential != nil else {
            errorMessage = "Phone number verification failed."
            showAlert = true
            return
        }
        
        // Attempting to finalize registration
        do {
            // Use the stored credential to sign in
            if let credential = AuthService.shared.pendingCredential {
                try await AuthService.shared.loginWithCredential(credential: credential, username: username)
                // Handle successful registration
            } else {
                errorMessage = "No valid credential available."
                showAlert = true
            }
        } catch {
            errorMessage = "Failed to complete registration: \(error.localizedDescription)"
            showAlert = true
        }
    }
}
