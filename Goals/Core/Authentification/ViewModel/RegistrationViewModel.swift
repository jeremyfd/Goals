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
        guard let verificationID = verificationID else {
            errorMessage = "Verification ID not found."
            showAlert = true
            return
        }
        
        isAuthenticating = true
        do {
            try await AuthService.shared.verifyPhoneNumber(verificationCode: verificationCode, verificationID: verificationID)
            isCodeVerified = true
            isAuthenticating = false
        } catch let error as NSError {
            errorMessage = "Failed to verify code: \(error.localizedDescription)"
            showAlert = true
            isCodeVerified = false
            isAuthenticating = false
        }
    }
    
    @MainActor
    func createUser() async throws {
        guard !username.isEmpty else {
            errorMessage = "Please enter a username."
            showAlert = true
            return
        }
        
        // Check if username already exists
        let usernameExists = try await UserService.usernameExists(username)
        if usernameExists {
            errorMessage = "This username is already taken. Please choose another."
            showAlert = true
            return
        }
        
        // Ensure that you have a valid credential from the phone number verification
        guard let credential = AuthService.shared.pendingCredential else {
            errorMessage = "Phone number verification failed."
            showAlert = true
            return
        }
        
        isAuthenticating = true
        do {
            // Make sure to pass the correct credential here
            let credential = // get the correct AuthCredential
            try await AuthService.shared.loginWithCredential(credential: credential, username: username)
            isAuthenticating = false
        } catch let error as NSError {
            errorMessage = "Failed to create user: \(error.localizedDescription)"
            showAlert = true
            isAuthenticating = false
            throw error
        }
    }
    
}
