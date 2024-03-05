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
                                        
                    Text(goal.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.leading)
                    
                    Text("-")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("Day \(goal.currentCount + 1)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.trailing)
                                        
                }
                .frame(height: 40)
                .background(Color.white)
                .cornerRadius(40)
            }
        
    }
}
