//
//  ActivityRowView.swift
//  Goals
//
//  Created by Jeremy Daines on 21/02/2024.
//

import SwiftUI

struct ActivityRowView: View {
    let model: Activity
    
    private var activityMessage: String {
        switch model.type {
        case .friendGoal:
            return "Started a new goal: \(model.goal?.title ?? "")"
        case .partnerGoal:
            return "Started a new goal: \(model.goal?.title ?? "")"
        case .friend:
            return "Added you as a friend"
        case .react:
            return "Reacted to one of your goals"
        case .evidence:
            return "Submitted an evidence for \(model.goal?.title ?? "")"
        }
    }
    
    private var isFriend: Bool {
        return model.user?.isFriend ?? false
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 16) {
                NavigationLink(value: model.user) {
                    ZStack(alignment: .bottomTrailing) {
                        CircularProfileImageView(user: model.user, size: .medium)
                        ActivityBadgeView(type: model.type)
                            .offset(x: 8, y: 4)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(model.user?.username ?? "")
                            .bold()
                            .foregroundColor(Color.theme.primaryText)
                        
                        Text(model.timestamp.timestampString())
                            .foregroundColor(.gray)
                    }
                    
                    Text(activityMessage)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .font(.footnote)
                
                Spacer()
                
                if model.type == .friend {
                    Button {
                        
                    } label: {
                        Text(isFriend ? "Delete" : "Accept")
                            .foregroundStyle(isFriend ? Color(.systemGray4) : Color.theme.primaryText)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(width: 100, height: 32)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            }
                    }
                }

            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.leading, 80)
        }
    }
}

//struct ActivityRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityRowView(model: dev.activityModel)
//    }
//}
