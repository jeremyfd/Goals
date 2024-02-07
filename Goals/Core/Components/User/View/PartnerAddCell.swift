//
//  PartnerAddCell.swift
//  Goals
//
//  Created by Jeremy Daines on 07/02/2024.
//

import SwiftUI

struct PartnerAddCell: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12) {
                CircularProfileImageView(user: user, size: .small)
                
                VStack(alignment: .leading) {
                    Text(user.username)
                        .bold()
                    
                    Text(user.fullName ?? "")
                }
                .font(.footnote)
                
                Spacer()
                
            }
            .padding(.horizontal)
            
            Divider()
        }
        .padding(.vertical, 4)
        .foregroundColor(Color.theme.primaryText)
    }
}

//#Preview {
//    PartnerAddCell(user: user)
//}
