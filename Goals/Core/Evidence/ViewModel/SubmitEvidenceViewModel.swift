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
        
        // Assuming ImageUploader and EvidenceService are set up to handle async operations
        do {
            // Use ImageUploader to upload the image first, then create an Evidence object with the URL
            if let imageUrl = try await ImageUploader.uploadImage(image: image, type: .goal) {
                // Create an Evidence object
                var newEvidence = Evidence(
                    ownerUid: Auth.auth().currentUser?.uid ?? "",
                    partnerUid: "",
                    timestamp: Timestamp(date: Date()),
                    verified: false,
                    weekNumber: weekNumber,
                    dayNumber: dayNumber,
                    imageUrl: imageUrl,
                    description: ""
                )
                
                // Upload the evidence using EvidenceService
                _ = try await EvidenceService.uploadEvidence(newEvidence, image: image)
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Failed to submit evidence: \(error.localizedDescription)")
            completion(false)
        }
    }
}

