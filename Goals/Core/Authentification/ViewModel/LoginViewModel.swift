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
    func verifyCodeAndLogin() async {
        guard let verificationID = verificationID else {
            self.errorMessage = "Verification ID not found."
            self.showAlert = true
            return
        }

        self.isAuthenticating = true
        await AuthService.shared.loginWithPhoneNumber(verificationCode: verificationCode, verificationID: verificationID) { success, error in
            if success {
                // Handle successful login
                // Make sure to execute any UI updates on the main thread.
                DispatchQueue.main.async {
                    self.isAuthenticating = false
                    // Other UI updates...
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Login error: \(error.localizedDescription)"
                    self.showAlert = true
                    self.isAuthenticating = false
                }
            }
        }
    }
}
