//
//  SubmitEvidenceView.swift
//  Goals
//
//  Created by Jeremy Daines on 13/02/2024.
//

import SwiftUI
import PhotosUI

struct SubmitEvidenceView: View {
    @StateObject private var viewModel = SubmitEvidenceViewModel()
    @State private var isPickerPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let selectedImage = viewModel.uiImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: 300)
                    
                    Button("Choose a different picture") {
                        isPickerPresented = true
                    }
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    
                    Button("Submit Evidence") {
                        // Action for submitting the evidence
                    }
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    
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

struct SubmitEvidenceView_Previews: PreviewProvider {
    static var previews: some View {
        SubmitEvidenceView()
    }
}
