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
        
        // Save the evidence document in Firestore
        let ref = try await FirestoreConstants.EvidencesCollection.addDocument(from: newEvidence)
        var uploadedEvidence = newEvidence
        uploadedEvidence.evidenceId = ref.documentID // Directly assign to evidenceId
        
        // Fetch the associated goal using the goalID from the evidence
        let goal = try await GoalService.fetchGoal(goalId: evidence.goalID)
        
        // Now that you have the goal, you can get the partnerUid and use it for the notification
        await ActivityService.uploadNotification(toUid: goal.partnerUid, type: .evidence, goalId: goal.id)
        
        try await StepService.updateStepSubmission(stepId: evidence.stepID, isSubmitted: true)
        
        return uploadedEvidence
    }
    
    static func fetchEvidences(forGoalId goalId: String) async throws -> [Evidence] {
            let querySnapshot = try await FirestoreConstants.EvidencesCollection.whereField("goalID", isEqualTo: goalId).getDocuments()
//            print("DEBUG: Query snapshot documents: \(querySnapshot.documents)")
            
            let evidences: [Evidence] = querySnapshot.documents.compactMap { document -> Evidence? in
                try? document.data(as: Evidence.self)
            }
            return evidences
        }
    
    static func updateEvidenceVerification(evidenceId: String, isVerified: Bool, goalId: String) async throws {
        // Update the evidence's verified status
        try await FirestoreConstants.EvidencesCollection.document(evidenceId).updateData(["verified": isVerified])
        
        if isVerified {
            // Fetch the evidence to get the stepID
            let documentSnapshot = try await FirestoreConstants.EvidencesCollection.document(evidenceId).getDocument()
            guard let evidence = try? documentSnapshot.data(as: Evidence.self) else {
                throw NSError(domain: "VerificationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch evidence for verification."])
            }
            
            // Update the isVerified for the corresponding step to true
            try await StepService.updateStepVerification(stepId: evidence.stepID, isVerified: true)

            // If the evidence is being verified, increment the goal's currentCount
            try await GoalService.incrementCurrentCountForGoal(goalId: goalId)
        }
    }

    
    static func deleteEvidence(evidenceId: String) async throws {
        // Fetch the document to get the imageUrl
        let documentSnapshot = try await FirestoreConstants.EvidencesCollection.document(evidenceId).getDocument()
        
        guard let evidence = try? documentSnapshot.data(as: Evidence.self) else {
            throw NSError(domain: "DeleteEvidenceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch evidence for deletion."])
        }
        
        // Since imageUrl is non-optional, you can directly use it
        do {
            try await ImageUploader.deleteImage(withURL: evidence.imageUrl)
//            print("DEBUG: Successfully deleted image from storage")
        } catch {
            print("DEBUG: Failed to delete image from storage, \(error.localizedDescription)")
            // Handle the error as needed. Depending on your requirements, you might log this error or throw it.
        }
        
        // Proceed to delete the evidence document from Firestore
        try await FirestoreConstants.EvidencesCollection.document(evidenceId).delete()
        
        try await StepService.updateStepSubmission(stepId: evidence.stepID, isSubmitted: false)
        try await StepService.updateStepVerification(stepId: evidence.stepID, isVerified: false)
       
    }
}
