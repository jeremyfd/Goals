//
//  SimpleImageView.swift
//  Goals
//
//  Created by Jeremy Daines on 14/02/2024.
//

import SwiftUI
import Kingfisher

struct SimpleImageView: View {
    let imageURLString = "https://firebasestorage.googleapis.com:443/v0/b/goals-8509a.appspot.com/o/evidence_images%2FDDB9BC65-8F88-4F44-AD57-1381BDF30D2A?alt=media&token=79fb2d05-6fa6-4b76-b3ae-dbf2b1fc61ab"

    var body: some View {
        VStack {
            if let url = URL(string: imageURLString) {
                KFImage(url)
                    .resizable()
                    .onFailure { error in
                        print("DEBUG: Failed to load image with error: \(error.localizedDescription)")
                    }
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    
            } else {
                Text("Invalid URL")
            }
        }
    }
}

struct SimpleImageView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleImageView()
    }
}
