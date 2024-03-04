//
//  EditProfileView.swift
//  Goals
//
//  Created by Work on 14/01/2024.
//

import SwiftUI
import PhotosUI
struct EditProfileView: View {
    let user: User
    @State private var updatedName = "" // New state for the updated name
    @StateObject var viewModel = EditProfileViewModel()
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    PhotosPicker(selection: $viewModel.selectedImage) {
                        if let image = viewModel.profileImage {
                            VStack {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: ProfileImageSize.xxLarge.dimension, height: ProfileImageSize.xxLarge.dimension)
                                    .clipShape(Circle())
                                    .foregroundColor(Color(.systemGray4))
                                Text("Change Profile Picture")
                            }
                            
                        } else {
                            VStack {
                                CircularProfileImageView(user: user, size: .xxLarge)
                                Text("Change Profile Picture")
                            }
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    HStack {
                        Text("Name")
                            .fontWeight(.bold)
                        TextField("Full Name", text: $updatedName) // TextField for name update
                            .autocapitalization(.words)
                            .padding(.leading)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    self.presentation.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    Task {
                        // Pass the updated name to the view model
                        try await viewModel.updateUserData(withNewName: updatedName)
                        self.presentation.wrappedValue.dismiss()
                    }
                }
            )
        }
        .navigationBarBackButtonHidden(true)
        // Pre-fill the TextField with the current full name
        .onAppear {
            self.updatedName = user.fullName ?? ""
        }
    }
}


//#Preview {
//    EditProfileView()
//}
