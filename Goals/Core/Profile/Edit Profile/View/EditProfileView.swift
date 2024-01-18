//
//  EditProfileView.swift
//  Goals
//
//  Created by Work on 14/01/2024.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @State private var newFullName = ""
    @StateObject var viewModel = EditProfileViewModel()
    @Environment(\.presentationMode) var presentation
    
    //    private var user: User? {
    //        return viewModel.currentUser
    //    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Profile")) {
                    
                    PhotosPicker(selection: $viewModel.selectedImage) {
                        if let image = viewModel.profileImage {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: ProfileImageSize.small.dimension, height: ProfileImageSize.small.dimension)
                                .clipShape(Circle())
                                .foregroundColor(Color(.systemGray4))
                        } else {
                            CircularProfileImageView(size: .small)
                        }
                    }
                    
                    Button(action: {
                        // Show an image picker to select a new profile picture
                        // You can implement this part using UIImagePickerController or other methods.
                    }) {
                        Text("Change Profile Picture")
                    }
                }
                
                Section(header: Text("Full Name")) {
                    TextField("Enter your full name", text: $newFullName)
                }
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    self.presentation.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    Task {
                        try await viewModel.updateUserData()
                        self.presentation.wrappedValue.dismiss()
                    }
                }
            )
        }
        .navigationBarBackButtonHidden(true)
    }
}


//#Preview {
//    EditProfileView()
//}
