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
    @Published var authError: AuthError?

    private var verificationID: String?

    @MainActor
    func sendVerificationCode() async {
        isAuthenticating = true
        do {
            verificationID = try await AuthService.shared.sendVerificationCode(to: phoneNumber)
            isAuthenticating = false
        } catch {
            // Handle errors
            showAlert = true
            isAuthenticating = false
            // Set appropriate auth error
        }
    }

    @MainActor
    func verifyCodeAndLogin() async throws {
        guard let verificationID = verificationID else {
            // Handle error: verification ID not found
            return
        }

        isAuthenticating = true
        do {
            try await AuthService.shared.loginWithPhoneNumber(verificationCode: verificationCode, verificationID: verificationID)
            isAuthenticating = false
        } catch {
            // Handle errors
            showAlert = true
            isAuthenticating = false
            // Set appropriate auth error
        }
    }
}
