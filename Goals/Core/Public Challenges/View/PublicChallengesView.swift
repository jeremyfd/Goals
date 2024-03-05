//
//  PublicChallengesView.swift
//  Goals
//
//  Created by Jeremy Daines on 08/02/2024.
//

import SwiftUI

struct PublicChallengesView: View {
    var body: some View {
//        NavigationStack{
//            
//            LinearGradientView()
//                .ignoresSafeArea()
//                .overlay(
//                    VStack {
//                        Text("")
//                            .padding()
//                        
//                        Text("")
//                            .padding()
//                        
//                        Text("Phylax")
//                            .font(.system(size: 100))
//                            .fontWeight(.bold)
//                            .padding(.vertical)
//                        
//                        Spacer()
//                    }
//                )
//            
//        }
        
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
