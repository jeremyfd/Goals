//
//  EditProfileView.swift
//  Goals
//
//  Created by Work on 14/01/2024.
//

import SwiftUI

struct EditProfileView: View {
    @State private var newFullName = ""
    @State private var newProfileImage: Image? = nil
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Profile")) {
                    if let profileImage = newProfileImage {
                        profileImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    } else {
                        Image("default_profile_image")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
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
                    // Save logic
                }
            )
        }
        .navigationBarBackButtonHidden(true)
    }
}


//#Preview {
//    EditProfileView()
//}
