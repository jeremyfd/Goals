//
//  LoginView.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

import SwiftUI
import Combine

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @StateObject var phoneNumberViewModel = PhoneNumberAuthViewModel()
    
    @State private var isCodeSent = false
    @State private var isSendingCode = false
    
    @State private var cancellables: Set<AnyCancellable> = []
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                Text("Phylax")
                    .font(.system(size: 45))
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("Sign In")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                VStack(spacing: 15) {
                    if !isCodeSent {
                        // Phone number field
                        PhoneNumberView(viewModel: phoneNumberViewModel)
                            .padding(.horizontal)
                            .onAppear {
                                if cancellables.isEmpty {
                                    setupCombinePipeline()
                                }
                            }
                        
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
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                            .background(RoundedRectangle(cornerRadius: 10).fill(colorScheme == .light ? Color.black : Color.white ))
                        }
                        .disabled(phoneNumberViewModel.phoneNumber.isEmpty || isSendingCode)
                        
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
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                            .background(RoundedRectangle(cornerRadius: 10).fill(colorScheme == .light ? Color.black : Color.white ))
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
    
    // Define a method to set up the Combine pipeline
    private func setupCombinePipeline() {
        phoneNumberViewModel.$phoneNumber
            .combineLatest(phoneNumberViewModel.$selectedCountry)
            .map { phoneNumber, selectedCountry in
                let fullNumber = selectedCountry.dialCode + phoneNumber.filter("0123456789".contains)
//                print("DEBUG: Full phone number in map: \(fullNumber)")
                return fullNumber
            }
            .removeDuplicates()
            .handleEvents(receiveOutput: { fullNumber in
//                print("DEBUG: Full phone number before assignment: \(fullNumber)")
            })
            .receive(on: RunLoop.main)
            .assign(to: \.phoneNumber, on: viewModel)
            .store(in: &cancellables)
    }
}


//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
