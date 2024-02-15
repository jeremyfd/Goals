//
//  EvidenceService.swift
//  Goals
//
//  Created by Jeremy Daines on 15/02/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct EvidenceService {
    
    static func uploadEvidence(_ evidence: Evidence, image: UIImage) async throws -> Evidence {
        guard let imageUrl = try await ImageUploader.uploadImage(image: image, type: .evidence) else {
            throw NSError(domain: "UploadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to upload evidence image"])
        }
        
        var newEvidence = evidence
        newEvidence.imageUrl = imageUrl
        
        let ref = try await FirestoreConstants.EvidenceCollection.addDocument(from: newEvidence)
        var uploadedEvidence = newEvidence
        uploadedEvidence.evidenceId = ref.documentID // Directly assign to evidenceId
        return uploadedEvidence
    }
    
    static func fetchEvidences(forGoalId goalId: String) async throws -> [Evidence] {
            let querySnapshot = try await FirestoreConstants.EvidenceCollection.whereField("goalID", isEqualTo: goalId).getDocuments()
            print("DEBUG: Query snapshot documents: \(querySnapshot.documents)")
            
            let evidences: [Evidence] = querySnapshot.documents.compactMap { document -> Evidence? in
                try? document.data(as: Evidence.self)
            }
            return evidences
        }
    
    static func updateEvidenceVerification(evidenceId: String, isVerified: Bool) async throws {
        try await FirestoreConstants.EvidenceCollection.document(evidenceId).updateData(["verified": isVerified])
    }
    
    static func deleteEvidence(evidenceId: String) async throws {
        try await FirestoreConstants.EvidenceCollection.document(evidenceId).delete()
    }
}
