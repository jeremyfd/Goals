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
//            authError = AuthError(authErrorCode: .unknown)
        }
    }

    @MainActor
    func verifyCodeAndCreateUser() async throws {
        guard let verificationID = verificationID else {
            // Handle error: verification ID not found
            return
        }

        isAuthenticating = true
        do {
            try await AuthService.shared.verifyCodeAndCreateUser(verificationCode: verificationCode, verificationID: verificationID, username: username)
            isAuthenticating = false
        } catch {
            // Handle errors
            showAlert = true
            isAuthenticating = false
//            authError = AuthError(authErrorCode: .unknownError) // Update with appropriate error handling
        }
    }
}
