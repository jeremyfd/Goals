//
//  SubmitEvidenceViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 15/02/2024.
//

import SwiftUI
import PhotosUI
import Firebase

class SubmitEvidenceViewModel: ObservableObject {
    @Published private(set) var uiImage: UIImage?
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { await loadImage(fromItem: selectedImage) } }
    }
    
    // Properties needed for creating an evidence entry
    var goalID: String
    var cycleID: String
    var stepID: String
    var weekNumber: Int
    var dayNumber: Int
    
    // Initialize with the required data
    init(goalID: String, cycleID: String, stepID: String, weekNumber: Int, dayNumber: Int) {
        self.goalID = goalID
        self.cycleID = cycleID
        self.stepID = stepID
        self.weekNumber = weekNumber
        self.dayNumber = dayNumber
    }
    
    @MainActor
    func loadImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else {
            self.uiImage = nil
            return
        }
        self.uiImage = image
    }
    
    // Method to submit the evidence using EvidenceService
    func submitEvidence(stepDescription: String, completion: @escaping (Bool) -> Void) async {
        guard let image = uiImage else {
            completion(false)
            return
        }

        do {
            // Directly pass image to EvidenceService without uploading it here
            var newEvidence = Evidence(
                goalID: goalID,
                cycleID: cycleID,
                stepID: stepID,
                ownerUid: Auth.auth().currentUser?.uid ?? "",
                partnerUid: "",
                timestamp: Timestamp(date: Date()),
                verified: false,
                weekNumber: weekNumber,
                dayNumber: dayNumber,
                imageUrl: ""
            )
            
            // Upload the evidence (and the image within the service)
            _ = try await EvidenceService.uploadEvidence(newEvidence, image: image)
            
            try await StepService.updateStepDescription(stepId: stepID, description: stepDescription)

            completion(true)
        } catch {
            print("Failed to submit evidence and update step description: \(error.localizedDescription)")
            completion(false)
        }
    }
}

