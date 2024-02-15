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
        guard let imageUrl = try await ImageUploader.uploadImage(image: image, type: .goal) else {
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
        let snapshot = try await FirestoreConstants.EvidenceCollection
            .whereField("goalId", isEqualTo: goalId)
            .getDocuments()
        
        let evidences: [Evidence] = snapshot.documents.compactMap { try? $0.data(as: Evidence.self) }
        return evidences
    }
    
    static func updateEvidenceVerification(evidenceId: String, isVerified: Bool) async throws {
        try await FirestoreConstants.EvidenceCollection.document(evidenceId).updateData(["verified": isVerified])
    }
    
    static func deleteEvidence(evidenceId: String) async throws {
        try await FirestoreConstants.EvidenceCollection.document(evidenceId).delete()
    }
}
