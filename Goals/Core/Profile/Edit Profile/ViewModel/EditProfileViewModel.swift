//
//  EditProfileViewModel.swift
//  Goals
//
//  Created by Work on 18/01/2024.
//

import SwiftUI
import PhotosUI

class EditProfileViewModel: ObservableObject {
    
    
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { await loadImage(fromItem: selectedImage) } }
    }
    @Published var profileImage: Image?
    private var uiImage: UIImage?
    
    func updateUserData() async throws {
        if let uiImage = uiImage {
            try await updateProfileImage(uiImage)
        }
    }
    
    @MainActor
    func loadImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage
        self.profileImage = Image(uiImage: uiImage)
    }
    
    func updateProfileImage(_ uiImage: UIImage) async throws {
        guard self.uiImage != nil else { return }
        guard let imageUrl = try? await ImageUploader.uploadImage(image: uiImage, type: .profile) else { return }
        try await UserService.shared.updateUserProfileImage(withImageUrl: imageUrl)
    }
    
}
