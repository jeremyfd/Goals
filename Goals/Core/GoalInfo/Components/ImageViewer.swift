//
//  ImageViewer.swift
//  Goals
//
//  Created by Jeremy Daines on 16/02/2024.
//

import SwiftUI
import Kingfisher

struct ImageViewer: View {
    @Binding var imageURL: String?
    @Binding var isPresented: Bool

    var body: some View {
        GeometryReader { geometry in
            Color.black.opacity(0.8) // Apply the background color here

            VStack {
                if let urlString = imageURL, let url = URL(string: urlString) {
                    KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: max(geometry.size.width - 40, 0),
                            height: max((geometry.size.width - 40) * 4 / 3, 0)
                        )
                        .cornerRadius(8)
                        .clipped() // Clip the image to the frame's bounds
                        .padding(.horizontal, 20)
                }

                Button(action: {
                    self.isPresented = false
                }) {
                    Text("Close")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.bottom, 20)
            }
            .onTapGesture {
                self.isPresented = false
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: isPresented) { newValue in
            if !newValue {
                deleteImageFromCache()
            }
        }
    }

    private func deleteImageFromCache() {
        guard let urlString = imageURL, let url = URL(string: urlString) else { return }

        // Delete image from Kingfisher cache
        KingfisherManager.shared.cache.removeImage(forKey: url.cacheKey)

        // Optionally, if you're storing the image on disk, delete it from there as well
        // Use FileManager to delete the file from disk storage
    }
}
