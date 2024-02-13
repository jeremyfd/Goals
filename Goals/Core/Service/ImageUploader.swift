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
            return Storage.storage().reference(withPath: "/evidence_images/\(filename)")
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
    
    static func deleteImage(atPath path: String) async throws {
        // Create a reference to the file to delete
        let storageRef = Storage.storage().reference(withPath: path)
        
        do {
            // Delete the file
            try await storageRef.delete()
//            print("DEBUG: Successfully deleted image at path \(path)")
        } catch let error {
            // An error occurred!
            print("DEBUG: Error occurred while deleting image: \(error.localizedDescription)")
            throw error
        }
    }
}
