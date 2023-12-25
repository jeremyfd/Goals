//
//  RegistrationView.swift
//  Goals
//
//  Created by Work on 25/12/2023.
//

import SwiftUI

struct RegistrationView: View {
    @StateObject var viewModel = RegistrationViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            
            // logo image
            Image("threads-app-icon")
                .renderingMode(.template)
                .resizable()
                .colorMultiply(Color.theme.primaryText)
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding()
            
            // text fields
            VStack {
                TextField("Enter your phone number", text: $viewModel.phoneNumber)
                    .keyboardType(.phonePad)
                    .modifier(ThreadsTextFieldModifier())
                
                TextField("Enter your username", text: $viewModel.username)
                    .autocapitalization(.none)
                    .modifier(ThreadsTextFieldModifier())
                
                // Button to send verification code
                Button("Send Verification Code") {
                    Task { await viewModel.sendVerificationCode() }
                }
                
                // Verification code text field
                TextField("Verification Code", text: $viewModel.verificationCode)
                    .keyboardType(.numberPad)
                    .modifier(ThreadsTextFieldModifier())
                
                // Button to verify code and create user
                Button("Verify Code and Sign Up") {
                    Task { try await viewModel.verifyCodeAndCreateUser() }
                }
                .disabled(viewModel.verificationCode.isEmpty)
            }
            
            Button {
                Task { try await viewModel.verifyCodeAndCreateUser() }
            } label: {
                Text(viewModel.isAuthenticating ? "" : "Sign up")
                    .foregroundColor(Color.theme.primaryBackground)
                    .modifier(ThreadsButtonModifier())
                    .overlay {
                        if viewModel.isAuthenticating {
                            ProgressView()
                                .tint(Color.theme.primaryBackground)
                        }
                    }
                
            }
            .padding(.vertical)
            
            Spacer()
            
            Divider()
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    
                    Text("Sign in")
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color.theme.primaryText)
                .font(.footnote)
            }
            .padding(.vertical, 16)
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Error"),
                  message: Text(viewModel.authError?.description ?? ""))
        }
    }
}

#Preview {
    RegistrationView()
}
