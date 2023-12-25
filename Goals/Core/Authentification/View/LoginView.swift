//
//  LoginView.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
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
                    // Text field for phone number
                    TextField("Enter your phone number", text: $viewModel.phoneNumber)
                        .keyboardType(.phonePad)
                        .modifier(ThreadsTextFieldModifier())
                    
                    // Button to send verification code
                    Button("Send Verification Code") {
                        Task { await viewModel.sendVerificationCode() }
                    }
                    
                    // Verification code text field
                    TextField("Verification Code", text: $viewModel.verificationCode)
                        .keyboardType(.numberPad)
                        .modifier(ThreadsTextFieldModifier())
                    
                    // Button to login
                    Button {
                        Task { try await viewModel.verifyCodeAndLogin() }
                    } label: {
                        Text(viewModel.isAuthenticating ? "" : "Login")
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
                    .disabled(viewModel.verificationCode.isEmpty)
                    
                    Spacer()
                    
                    Divider()
                    
                    NavigationLink {
                        RegistrationView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack(spacing: 3) {
                            Text("Don't have an account?")
                            
                            Text("Sign Up")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color.theme.primaryText)
                        .font(.footnote)
                    }
                    .padding(.vertical, 16)
                }
                
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"),
                      message: Text(viewModel.authError?.description ?? ""))
            }
        }
    }
}
