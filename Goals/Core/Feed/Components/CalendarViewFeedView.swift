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
        VStack{
            
            NavigationLink {
                ExpandedGoalView(goal: goal)
            } label: {
                HStack{
                    
                    CircularProfileImageView(user: goal.user, size: .small)
                    
                    Text(goal.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("24:19 left")
                        .padding(.leading)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 1)
                .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                .background(Color.white)
                .cornerRadius(40)
            }
        }
    }
}
