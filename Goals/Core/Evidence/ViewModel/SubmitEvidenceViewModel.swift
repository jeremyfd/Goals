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

import SwiftUI
import PhotosUI

class SubmitEvidenceViewModel: ObservableObject {
    @Published private(set) var uiImage: UIImage?
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { await loadImage(fromItem: selectedImage) } }
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
}
