//
//  RegistrationView.swift
//  Goals
//
//  Created by Work on 25/12/2023.
//

import SwiftUI
import Combine

struct RegistrationView: View {
    @StateObject var viewModel = RegistrationViewModel()
    @StateObject var phoneNumberViewModel = PhoneNumberAuthViewModel()

    @State private var isCodeSent = false
    @State private var isCodeVerified = false
    @Environment(\.dismiss) var dismiss
    
    @State private var cancellables: Set<AnyCancellable> = []
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Phylax")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom)
            
            Text("Sign Up")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom)
            
            // Text fields and button
            VStack(spacing: 15) {
                // Only show the phone number field initially
                if !isCodeSent {
                    PhoneNumberView(viewModel: phoneNumberViewModel)
                        .padding(.horizontal)
                        .onAppear {
                            if cancellables.isEmpty {
                                setupCombinePipeline()
                            }
                        }
                }
                
                // Once the code is sent, show the verification code field
                if isCodeSent && !isCodeVerified {
                    TextField("Verification Code", text: $viewModel.verificationCode)
                        .keyboardType(.numberPad)
                        .modifier(ThreadsTextFieldModifier())
                        .padding(.horizontal)
                }
                
                // Once the code is verified, show the username field
                if isCodeVerified {
                    TextField("Enter your username", text: $viewModel.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .modifier(ThreadsTextFieldModifier())
                        .padding(.horizontal)
                }
                
                // The button's role changes depending on the stage
                Button(action: {
                    Task {
                        if !isCodeSent {
                            await viewModel.sendVerificationCode()
                            isCodeSent = viewModel.verificationID != nil
                        } else if !viewModel.isCodeVerified {
                            await viewModel.verifyCode()
                            if viewModel.isCodeVerified {
                                isCodeVerified = true // Only update if verification was successful
                            }
                        } else if !viewModel.username.isEmpty {
                            await viewModel.finalizeRegistration(username: viewModel.username)
                        }
                    }
                }) {
                     Group {
                         if viewModel.isAuthenticating {
                             ProgressView()
                                 .tint(Color.theme.primaryBackground)
                         } else {
                             Text(getButtonText())
                         }
                     }
                     .frame(minWidth: 0, maxWidth: .infinity)
                     .padding()
                     .foregroundColor(Color.theme.primaryBackground)
                     .background(RoundedRectangle(cornerRadius: 10).fill(Color.black))
                 }
                 .modifier(ThreadsButtonModifier())
                 .disabled(getButtonDisabledState())
             }
             .padding(.horizontal)
            
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    Text("Sign In").fontWeight(.semibold)
                }
                .foregroundColor(Color.theme.primaryText)
                .font(.body)
            }
            .padding(.vertical, 16)
            
            Spacer()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "Unknown error")
            )
        }        
    }
    
    private func getButtonText() -> String {
        if isCodeVerified {
            return viewModel.username.isEmpty ? "Enter Username" : "Complete Registration"
        } else {
            return isCodeSent ? "Verify Code" : "Send Verification Code"
        }
    }

    private func getButtonDisabledState() -> Bool {
        if isCodeSent && !isCodeVerified {
            return viewModel.verificationCode.isEmpty
        } else if isCodeVerified {
            return viewModel.username.isEmpty
        }
        return viewModel.phoneNumber.isEmpty
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


#Preview {
    RegistrationView()
}
