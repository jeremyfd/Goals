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
    
    static func fetchStep(stepId: String) async throws -> Step {
        let documentSnapshot = try await FirestoreConstants.StepsCollection.document(stepId).getDocument()
        
        let step = try documentSnapshot.data(as: Step.self)
        
        return step
    }

    
    static func updateStepSubmission(stepId: String, isSubmitted: Bool) async throws {
        var updateData: [String: Any] = ["isSubmitted": isSubmitted]

        // If the step is submitted, set the submittedTimestamp to the current server timestamp
        if isSubmitted {
            updateData["submittedTimestamp"] = FieldValue.serverTimestamp()
        } else {
            // If the step is not submitted, remove the submittedTimestamp field
            updateData["submittedTimestamp"] = FieldValue.delete()
        }

        do {
            try await FirestoreConstants.StepsCollection.document(stepId).updateData(updateData)
        } catch {
            print("DEBUG: Failed to update submission status for step with ID: \(stepId). Error: \(error.localizedDescription)")
            throw error
        }
    }

    static func updateStepVerification(stepId: String, isVerified: Bool, goalId: String) async throws {
        do {
            // Update the step's verification status
            try await FirestoreConstants.StepsCollection.document(stepId).updateData(["isVerified": isVerified])
            
            if isVerified {
                // Fetch the goal to increment its currentCount and to send a notification
                let goal = try await GoalService.fetchGoal(goalId: goalId)
                try await GoalService.incrementCurrentCountForGoal(goalId: goalId)

                // Send a notification to the goal owner from the partner
                await ActivityService.uploadNotification(toUid: goal.ownerUid, type: .evidenceVerified, goalId: goal.id)
            }
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
