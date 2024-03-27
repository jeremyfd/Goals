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
                ScrollView(.horizontal, showsIndicators: false) { // Horizontal ScrollView
                    LazyHStack {
                        ForEach(viewModel.uiImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 300, maxHeight: 300)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 300)
//                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding()

                TextField("Step Description", text: $stepDescription)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding()

                Button("Select pictures") { // Updated for multiple selections
                    isPickerPresented = true
                }
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue) // Changed for better visibility
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.horizontal)

                if isSubmitting {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                } else {
                    Button("Submit Evidence") {
                        print("DEBUG: Submitting evidence for step")
                        isSubmitting = true
                        Task {
                            await viewModel.submitEvidence(stepDescription: stepDescription) { success in
                                DispatchQueue.main.async {
                                    isSubmitting = false
                                    if success {
                                        presentationMode.wrappedValue.dismiss()
                                        onSubmissionSuccess()
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
                    .background(Color.blue) // Changed for consistency
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .disabled(viewModel.uiImages.isEmpty || isSubmitting)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Select & Submit")
            .navigationBarTitleDisplayMode(.inline)
            .photosPicker(
                isPresented: $isPickerPresented,
                selection: $viewModel.selectedImages, // Use the updated property
                maxSelectionCount: 4,
                matching: .images,
                photoLibrary: .shared() // Allow multiple selections
            )
        }
    }
}



//struct SubmitEvidenceView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubmitEvidenceView()
//    }
//}
