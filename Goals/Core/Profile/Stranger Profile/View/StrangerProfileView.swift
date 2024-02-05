//
//  StrangerProfileView.swift
//  Goals
//
//  Created by Work on 17/01/2024.
//

import SwiftUI

struct StrangerProfileView: View {
    let user: User
    @State private var showCalendarView = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.9)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            .overlay(
                VStack(alignment: .leading){
                    HStack{
                        CircularProfileImageView(user: user, size: .xLarge)
                        
                        VStack(alignment: .leading){
                            
                            if (user.fullName) != nil{
                                Text(user.fullName ?? "")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            
                            Text("@\(user.username)")
                                .font(.body)
                        }
                        
                        Spacer()
                        
                    }
                    .padding(.leading)
                    
                    HStack{
                        Text("You have 5 friends in common")
                            .fontWeight(.bold)
                    }
                    .padding(.leading)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
                
            )
        }
    }
}

#Preview {
    StrangerProfileView(user: DeveloperPreview.shared.user)
}
