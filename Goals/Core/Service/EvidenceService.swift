//
//  EvidenceService.swift
//  Goals
//
//  Created by Jeremy Daines on 09/02/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

//struct EvidenceService {
//    
////    static func uploadEvidence(_ evidence: Evidence) async throws {
////        guard let evidenceData = try? Firestore.Encoder().encode(evidence) else { return }
////        let _ = try await FirestoreConstants.EvidencesCollection.addDocument(data: evidenceData)
////    }
//    
//    static func fetchEvidences(goalID: String) async throws -> [Evidence] {
//        let snapshot = try await FirestoreConstants
//            .EvidencesCollection
//            .whereField("goalID", isEqualTo: goalID)
//            .getDocuments()
//        
//        return snapshot.documents.compactMap({ try? $0.data(as: Evidence.self) })
//    }
//    
//    static func updateEvidence(_ evidence: Evidence) async throws {
//        let documentRef = FirestoreConstants.EvidencesCollection.document(evidence.id)
//        try await documentRef.updateData(["isVerified": evidence.isVerified])
//    }
//    
////    static func deleteEvidence(_ evidenceID: String) async throws {
////        let documentRef = FirestoreConstants.EvidencesCollection.document(evidenceID)
////        try await documentRef.delete()
////    }
//    
//    static func uploadEvidence(_ evidence: Evidence, image: UIImage? = nil, type: UploadType = .evidence) async throws {
//        var updatedEvidence = evidence
//        
//        // If an image is provided, upload it first
//        if let image = image {
//            guard let imageUrl = try await ImageUploader.uploadImage(image: image, type: type) else {
//                throw NSError(domain: "ImageUploader", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image"])
//            }
//            updatedEvidence.imageURL = imageUrl
//        }
//        
//        // Whether updating existing or creating new, handle appropriately
//        if let id = updatedEvidence.id, !id.isEmpty {
//            let documentRef = FirestoreConstants.EvidencesCollection.document(id)
//            try await documentRef.setData(from: updatedEvidence)
//        } else {
//            let documentRef = try await FirestoreConstants.EvidencesCollection.addDocument(from: updatedEvidence)
//            updatedEvidence.id = documentRef.documentID
//        }
//    }
//    
//    static func deleteEvidence(_ evidence: Evidence) async throws {
//        guard let id = evidence.id else { return }
//        
//        // Delete the Firestore document
//        let documentRef = FirestoreConstants.EvidencesCollection.document(id)
//        try await documentRef.delete()
//        
//        // Delete the associated image, if any
//        if let imageURL = evidence.imageURL {
//            // Assuming you have a way to derive the storage path from the imageURL
//            let imagePath = derivePathFromURL(imageURL)
//            try await ImageUploader.deleteImage(atPath: imagePath)
//        }
//    }
//    
//    // Helper function to derive Firebase Storage path from imageURL
//    private static func derivePathFromURL(_ url: String) -> String {
//        // Implementation depends on the structure of your imageURL
//        // This is just a placeholder
//        return url
//    }
//}

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct EvidenceService {
    
    static let shared = EvidenceService()
    
    private init() {}
    
    func uploadEvidenceImageAndCreateEvidence(goalID: String, weekNumber: Int, day: Int, image: UIImage) async throws {
        // Attempt to upload the image and get a non-optional image URL
        guard let imageURL = try await ImageUploader.uploadImage(image: image, type: .evidence) else {
            throw NSError(domain: "ImageUploader", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image and obtain URL"])
        }
        
        // Now that imageURL is guaranteed to be non-nil, create the evidence document
        try await createEvidence(goalID: goalID, weekNumber: weekNumber, day: day, imageURL: imageURL)
    }

    private func createEvidence(goalID: String, weekNumber: Int, day: Int, imageURL: String) async throws {
        let evidence = Evidence(goalID: goalID, weekNumber: weekNumber, day: day, imageURL: imageURL, timestamp: Timestamp(), isVerified: false)
        
        // Using FirestoreConstants to access the "evidences" collection directly
        try await FirestoreConstants.EvidencesCollection.document(evidence.id).setData(from: evidence)
    }

    // Refactored to use async/await
    func fetchEvidences(goalID: String) async throws -> [Evidence] {
        // Accessing the "evidences" collection using FirestoreConstants
        let querySnapshot = try await FirestoreConstants.EvidencesCollection
            .whereField("goalID", isEqualTo: goalID)
            .getDocuments()
        
        // Map the documents to Evidence objects
        let evidences = querySnapshot.documents.compactMap { document -> Evidence? in
            return try? document.data(as: Evidence.self)
        }
        
        return evidences
    }

    func updateEvidence(_ evidence: Evidence) async throws {
        let evidenceID = evidence.id
        
        do {
            try await FirestoreConstants.EvidencesCollection.document(evidenceID).updateData(["isVerified": evidence.isVerified])
        } catch {
            throw error
        }
    }
    
    func deleteEvidence(_ evidence: Evidence) async throws {
        let evidenceID = evidence.id

        // First, delete the Firestore document
        try await FirestoreConstants.EvidencesCollection.document(evidenceID).delete()

        // Then, attempt to delete the associated image, if applicable
        if let imageURL = evidence.imageURL {
            let imagePath = derivePathFromURL(imageURL: imageURL)
            try await ImageUploader.deleteImage(atPath: imagePath)
        }
    }

    private func derivePathFromURL(imageURL: String) -> String {
        return imageURL
    }
}

