//
//  LoginViewModel.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var verificationCode = ""
    @Published var isAuthenticating = false
    @Published var showAlert = false
    @Published var errorMessage: String?  // Add this line for the error message
    private var verificationID: String?

    @MainActor
    func sendVerificationCode() async {
        guard !phoneNumber.isEmpty else {
            errorMessage = "Please enter a phone number."
            showAlert = true
            return
        }

        isAuthenticating = true
        do {
            let userExists = try await UserService.phoneNumberExists(phoneNumber)
            if !userExists {
                errorMessage = "No account found with this phone number. Please sign up."
                showAlert = true
            } else {
                verificationID = try await AuthService.shared.sendVerificationCode(to: phoneNumber)
            }
        } catch {
            errorMessage = "Failed to send verification code: \(error.localizedDescription)"
            showAlert = true
        }
        isAuthenticating = false
    }

    @MainActor
    func verifyCodeAndLogin() async throws {
        guard let verificationID = verificationID else {
            errorMessage = "Verification ID not found."
            showAlert = true
            return
        }

        isAuthenticating = true
        do {
            try await AuthService.shared.loginWithPhoneNumber(verificationCode: verificationCode, verificationID: verificationID)
            isAuthenticating = false
        } catch let error as NSError {
            errorMessage = "Failed to log in: \(error.localizedDescription)"
            showAlert = true
            isAuthenticating = false
            throw error
        }
    }
}
