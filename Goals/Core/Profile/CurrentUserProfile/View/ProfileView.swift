//
//  CurrentUserProfileView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI

struct CurrentUserProfileView: View {
    var body: some View {
        VStack{
            
            Text("This is your Profile")
            
            Button("Log Out") {
                AuthService.shared.signOut()
            }
            .font(.subheadline)
            .padding(.top)
        }
    }
}

#Preview {
    CurrentUserProfileView()
}
