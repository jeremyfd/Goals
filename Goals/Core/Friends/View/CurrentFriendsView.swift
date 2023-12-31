//
//  CurrentFriendsView.swift
//  Goals
//
//  Created by Work on 30/12/2023.
//

import SwiftUI

struct CurrentFriendsView: View {
    var body: some View {
        ScrollView {
            
            VStack {
            
                HStack {
                    Text("My Friends (40)")
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                
                ForEach(0 ... 10, id: \.self) { friend in
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text("Arno")
                                .font(.headline)
                            Text("@aarnofrenay")
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Action to remove friend
                        }) {
                            Image(systemName: "minus.circle.fill")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
            }
        }
    }
}

#Preview {
    CurrentFriendsView()
}
