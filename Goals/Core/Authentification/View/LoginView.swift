//
//  LoginView.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @State private var isCodeSent = false
    @State private var isSendingCode = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Text("Phylax")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("Sign In")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)

                VStack(spacing: 15) {
                    if !isCodeSent {
                        // Phone number field
                        TextField("Enter your phone number", text: $viewModel.phoneNumber)
                            .keyboardType(.phonePad)
                            .modifier(ThreadsTextFieldModifier())
                            .padding(.horizontal)
                        
                        // Send verification code button
                        Button(action: {
                            isSendingCode = true
                            Task {
                                await viewModel.sendVerificationCode()
                                if viewModel.errorMessage == nil {
                                         isCodeSent = true
                                     }
                                isSendingCode = false
                            }
                        }) {
                            Group {
                                if isSendingCode {
                                    ProgressView()
                                        .tint(Color.theme.primaryBackground)
                                } else {
                                    Text("Send Verification Code")
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity) // Adjusted to fill the width
                            .padding()
                            .foregroundColor(Color.theme.primaryBackground)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.black)) // Background to fill the button
                        }
                        .disabled(viewModel.phoneNumber.isEmpty || isSendingCode)
                    } else {
                        VStack{
                            Text("A code has been sent to \(viewModel.phoneNumber).")
                                .font(.footnote)
                                .foregroundColor(Color.theme.primaryText)
                            
                            Button("Edit number") {
                                isCodeSent = false
                                isSendingCode = false
                            }
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.primaryText)
                        }

                        // Verification code field
                        TextField("Verification Code", text: $viewModel.verificationCode)
                            .keyboardType(.numberPad)
                            .modifier(ThreadsTextFieldModifier())
                            .padding(.horizontal)
                        
                        // Login button
                        Button(action: {
                            Task { try await viewModel.verifyCodeAndLogin() }
                        }) {
                            Group {
                                if viewModel.isAuthenticating {
                                    ProgressView()
                                        .tint(Color.theme.primaryBackground)
                                } else {
                                    Text("Login")
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity) // Adjusted to fill the width
                            .padding()
                            .foregroundColor(Color.theme.primaryBackground)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.black)) // Background to fill the button
                        }
                        .disabled(viewModel.verificationCode.isEmpty)
                    }

                    NavigationLink(destination: RegistrationView().navigationBarBackButtonHidden(true)) {
                        HStack(spacing: 3) {
                            Text("Don't have an account?")
                            Text("Sign Up").fontWeight(.semibold)
                        }
                        .foregroundColor(Color.theme.primaryText)
                        .font(.body)
                    }
                    .padding(.vertical, 16)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error")
                )
            }
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
