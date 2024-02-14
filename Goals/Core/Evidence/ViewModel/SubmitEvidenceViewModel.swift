//
//  SubmitEvidenceViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 13/02/2024.
//

//import SwiftUI
//import PhotosUI
//
//class SubmitEvidenceViewModel: ObservableObject {
//    
//    private var uiImage: UIImage?
//    @Published var selectedImage: PhotosPickerItem? {
//        didSet { Task { await loadImage(fromItem: selectedImage) } }
//    }
//    
//    @MainActor
//    func loadImage(fromItem item: PhotosPickerItem?) async {
//        guard let item = item else { return }
//        
//        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
//        guard let uiImage = UIImage(data: data) else { return }
//        self.uiImage = uiImage
//    }
//}

//import SwiftUI
//import PhotosUI
//
//class SubmitEvidenceViewModel: ObservableObject {
//    @Published private(set) var uiImage: UIImage?
//    @Published var selectedImage: PhotosPickerItem? {
//        didSet { Task { await loadImage(fromItem: selectedImage) } }
//    }
//    
//    @MainActor
//    func loadImage(fromItem item: PhotosPickerItem?) async {
//        guard let item = item,
//              let data = try? await item.loadTransferable(type: Data.self),
//              let image = UIImage(data: data) else {
//            self.uiImage = nil
//            return
//        }
//        self.uiImage = image
//    }
//}

import SwiftUI
import PhotosUI

class SubmitEvidenceViewModel: ObservableObject {
    @Published private(set) var uiImage: UIImage?
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { await loadImage(fromItem: selectedImage) } }
    }
    
    // Add properties needed for creating an evidence entry
    var goalID: String
    var weekNumber: Int
    var day: Int
    
    // Initialize with the required data
    init(goalID: String, weekNumber: Int, day: Int) {
        self.goalID = goalID
        self.weekNumber = weekNumber
        self.day = day
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
    
    // Add a method to submit the evidence using EvidenceService
    @MainActor
    func submitEvidence(completion: @escaping (Bool) -> Void) async {
        guard let image = uiImage else { return }
        
        let evidenceService = EvidenceService.shared
        
        do {
            try await evidenceService.uploadEvidenceImageAndCreateEvidence(goalID: goalID, weekNumber: weekNumber, day: day, image: image)
            // Call completion handler with true on success
            completion(true)
        } catch {
            // Call completion handler with false on failure
            completion(false)
        }
    }
}
