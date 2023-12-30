//
//  SettingsView.swift
//  Goals
//
//  Created by Work on 29/12/2023.
//

import SwiftUI


import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading) {
                Divider()
                
                Button("Log Out") {
                    AuthService.shared.signOut()
                }
                .font(.subheadline)
                .listRowSeparator(.hidden)
                .padding(.top)

            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
