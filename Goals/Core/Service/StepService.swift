//
//  StepService.swift
//  Goals
//
//  Created by Jeremy Daines on 28/02/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct StepService {
    
    static func uploadStep(_ step: Step) async throws -> Step {
        // Create a new step document in Firestore
        let ref = try await FirestoreConstants.StepsCollection.addDocument(from: step)
        var uploadedStep = step
        uploadedStep.stepId = ref.documentID // Directly assign the stepId
        
        return uploadedStep
    }
    
    static func fetchSteps(forGoalId goalId: String) async throws -> [Step] {
        let querySnapshot = try await FirestoreConstants.StepsCollection.whereField("goalID", isEqualTo: goalId).getDocuments()
        
        let steps: [Step] = querySnapshot.documents.compactMap { document -> Step? in
            try? document.data(as: Step.self)
        }
        return steps
    }
    
    static func updateStepSubmission(stepId: String, isSubmitted: Bool) async throws {
        do {
            try await FirestoreConstants.StepsCollection.document(stepId).updateData(["isSubmitted": isSubmitted])
        } catch {
            print("DEBUG: Failed to update submission status for step with ID: \(stepId). Error: \(error.localizedDescription)")
            throw error
        }
    }

    static func updateStepVerification(stepId: String, isVerified: Bool) async throws {
        do {
            try await FirestoreConstants.StepsCollection.document(stepId).updateData(["isVerified": isVerified])
        } catch {
            print("DEBUG: Failed to update verification status for step with ID: \(stepId). Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    static func deleteStep(stepId: String) async throws {
        do {
            try await FirestoreConstants.StepsCollection.document(stepId).delete()
        } catch let error {
            print("DEBUG: Failed to delete step with ID: \(stepId). Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    static func updateStepDescription(stepId: String, description: String) async throws {
        do {
            try await FirestoreConstants.StepsCollection.document(stepId).updateData(["description": description])
        } catch {
            print("DEBUG: Failed to update description for step with ID: \(stepId). Error: \(error.localizedDescription)")
            throw error
        }
    }
}
