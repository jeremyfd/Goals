//
//  PublicChallengesView.swift
//  Goals
//
//  Created by Jeremy Daines on 08/02/2024.
//

import SwiftUI

struct PublicChallengesView: View {
    var body: some View {
        
        VStack{
            Text("Public Challenges")
                .font(.title)
                .fontWeight(.bold)
            Text("Coming soon!")
                .padding(.bottom)
            
            Text("Go to the Gym")
            Text("Wake up at 6am")
            Text("David Goggins Challenge")
            Text("SimplyPiano Challenge")
        }
    }
}

#Preview {
    PublicChallengesView()
}
