//
//  SubmitEvidenceView.swift
//  Goals
//
//  Created by Jeremy Daines on 15/02/2024.
//

import SwiftUI
import PhotosUI

struct SubmitEvidenceView: View {
    @StateObject var viewModel: SubmitEvidenceViewModel
    @State private var isPickerPresented = false
    @Environment(\.presentationMode) var presentationMode
    @State private var isSubmitting = false
    @State private var stepDescription: String = ""
    var onSubmissionSuccess: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                if let selectedImage = viewModel.uiImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: 300)
                    
                    TextField("Step Description", text: $stepDescription)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.bottom)
                    
                    Button("Choose a different picture") {
                        isPickerPresented = true
                    }
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    
                    if isSubmitting {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    } else {
                        Button("Submit Evidence") {
                            print("DEBUG: Submitting evidence for step")
                            isSubmitting = true // Indicate submission started
                            Task {
                                await viewModel.submitEvidence(stepDescription: stepDescription) { success in
                                    DispatchQueue.main.async { // Ensure UI updates are on the main thread
                                        isSubmitting = false // Reset submission state
                                        if success {
                                            presentationMode.wrappedValue.dismiss()
                                            self.onSubmissionSuccess()
                                        } else {
                                            // Handle failure, e.g., by showing an alert
                                        }
                                    }
                                }
                            }
                        }
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .disabled(isSubmitting) // Disable button during submission
                    }
                } else {
                    Button("Select picture") {
                        isPickerPresented = true
                    }
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
                
                
            }
            .navigationTitle("Select & Submit")
            .navigationBarTitleDisplayMode(.inline)
            .photosPicker(isPresented: $isPickerPresented, selection: $viewModel.selectedImage, matching: .images, photoLibrary: .shared())
        }
    }
}


//struct SubmitEvidenceView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubmitEvidenceView()
//    }
//}
