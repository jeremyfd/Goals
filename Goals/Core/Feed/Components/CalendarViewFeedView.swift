//
//  CalendarViewFeedView.swift
//  Goals
//
//  Created by Jeremy Daines on 22/02/2024.
//

import SwiftUI
import Kingfisher

struct CalendarViewFeedView: View {
    var goal: Goal
    var currentUser: User?
    
    init(goal: Goal, currentUser: User?) {
        self.goal = goal
        self.currentUser = currentUser
    }
    
    var body: some View {
            
            NavigationLink {
                ExpandedGoalView(goal: goal)
            } label: {
                HStack{
                    
//                    CircularProfileImageView(user: goal.user, size: .small)
                    
                    Text(goal.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
//                    Spacer()
                    
                }
//                .padding(.horizontal, 8)
//                .padding(.vertical, 1)
                .frame(height: 40)
                .background(Color.white)
                .cornerRadius(40)
            }
        
    }
}

//                .frame(width: UIScreen.main.bounds.width - 175, height: 40)
