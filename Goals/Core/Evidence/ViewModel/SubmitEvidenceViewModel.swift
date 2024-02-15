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
    var weekNumber: Int
    var dayNumber: Int  // Renamed for clarity
    
    // Initialize with the required data
    init(goalID: String, weekNumber: Int, dayNumber: Int) {
        self.goalID = goalID
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
    func submitEvidence(completion: @escaping (Bool) -> Void) async {
        guard let image = uiImage else {
            completion(false)
            return
        }

        do {
            // Directly pass image to EvidenceService without uploading it here
            var newEvidence = Evidence(
                goalID: goalID,
                ownerUid: Auth.auth().currentUser?.uid ?? "",
                partnerUid: "",
                timestamp: Timestamp(date: Date()),
                verified: false,
                weekNumber: weekNumber,
                dayNumber: dayNumber,
                imageUrl: "", // Temporarily empty, will be set in EvidenceService
                description: ""
            )
            
            // Upload the evidence (and the image within the service)
            _ = try await EvidenceService.uploadEvidence(newEvidence, image: image)
            completion(true)
        } catch {
            print("Failed to submit evidence: \(error.localizedDescription)")
            completion(false)
        }
    }
}

