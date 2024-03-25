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
    @Published private(set) var uiImages: [UIImage] = []
    @Published var selectedImages: [PhotosPickerItem] = [] {
        didSet {
            Task {
                for item in selectedImages {
                    await loadImage(fromItem: item)
                }
            }
        }
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
            return
        }
        self.uiImages.append(image)
    }
    
    func submitEvidence(stepDescription: String, completion: @escaping (Bool) -> Void) async {
        guard !uiImages.isEmpty else {
            completion(false)
            return
        }

        do {
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
                imageUrl: "" // Initially empty, will be set during upload
            )
            
            // Upload the evidence (and the images within the service)
            let _ = try await EvidenceService.uploadEvidence(newEvidence, images: uiImages)
            
            try await StepService.updateStepDescription(stepId: stepID, description: stepDescription)

            completion(true)
        } catch {
            print("Failed to submit evidence and update step description: \(error.localizedDescription)")
            completion(false)
        }
    }
}

