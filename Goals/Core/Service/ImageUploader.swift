//
//  ImageUploader.swift
//  Goals
//
//  Created by Work on 18/01/2024.
//


import Foundation
import Firebase
import FirebaseStorage

enum UploadType {
    case profile
    case evidence
    
    var filePath: StorageReference {
        let filename = NSUUID().uuidString
        switch self {
        case .profile:
            return Storage.storage().reference(withPath: "/profile_images/\(filename)")
        case .evidence:
            return Storage.storage().reference(withPath: "/evidences_images/\(filename)")
        }
    }
}

struct ImageUploader {
    static func uploadImage(image: UIImage, type: UploadType) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.25) else { return nil }
        let ref = type.filePath
        
        do {
            let _ = try await ref.putDataAsync(imageData)
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            print("DEBUG: Failed to upload image \(error.localizedDescription)")
            return nil
        }
    }
    
    static func deleteImage(withURL urlString: String) async throws {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "ImageUploaderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        
        do {
            try await ref.delete()
//            print("DEBUG: Successfully deleted image")
        } catch let error {
            print("DEBUG: Failed to delete image \(error.localizedDescription)")
            throw error
        }
    }
}
