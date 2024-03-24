//
//  ActivityBadgeView.swift
//  Goals
//
//  Created by Jeremy Daines on 21/02/2024.
//

import SwiftUI

struct ActivityBadgeView: View {
    let type: ActivityType
    
    private var badgeColor: Color {
        switch type {
        case .react: return Color.theme.pink
        case .friend: return Color.theme.purple
        case .friendGoal: return Color(.systemBlue)
        case .partnerGoal: return Color(.systemBlue)
        case .evidence: return Color(.systemBlue)
        case .evidenceVerified: return Color(.systemBlue)
        case .friendRequestAccepted: return Color(.systemBlue)
        case .nextTierReached: return Color(.systemBlue)
        case .selfNextTierReached: return Color(.systemBlue)
        }
    }
    
    private var badgeImageName: String {
        switch type {
        case .react: return "heart.fill"
        case .friend: return "person.fill"
        case .friendGoal: return "plus.circle"
        case .partnerGoal: return "plus.circle"
        case .evidence: return "plus.circle"
        case .evidenceVerified: return "plus.circle"
        case .friendRequestAccepted: return "plus.circle"
        case .nextTierReached: return "plus.circle"
        case .selfNextTierReached: return "plus.circle"
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.theme.primaryBackground)
            
            ZStack {
                Circle()
                    .fill(badgeColor)
                    .frame(width: 18, height: 18)

                
                Image(systemName: badgeImageName)
                    .font(.caption2)
                    .foregroundColor(.white)
            }
        }
    }
}

//struct ActivityBadgeView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityBadgeView(type: .react)
//    }
//}
