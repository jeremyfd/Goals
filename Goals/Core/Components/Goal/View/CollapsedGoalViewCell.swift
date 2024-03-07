//
//  CollapsedGoalViewCell.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI

struct CollapsedGoalViewCell: View {
    let goal: Goal
    
    var body: some View {
        
        NavigationLink {
            ExpandedGoalView(goal: goal)
        } label: {
            HStack{
                VStack(alignment: .leading, spacing: 5){
                    
                    Text(goal.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                    HStack{
                        CircularProfileImageView(user: goal.user, size: .small)
                        
                        Text(goal.user?.username ?? "")
                    }
                    .onAppear{
                        print("CircularProfileImageView appeared with user: \(String(describing: goal.user))")
                        print("User image URL: \(String(describing: goal.user?.profileImageUrl))")
                    }
                        
                }
                .foregroundColor(.black)
                .padding()
                
                Spacer()
                
                HStack {
                    Text("Day \(goal.currentCount + 1)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.trailing)
                    
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                    
                }
                .padding(.horizontal)
                
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            .frame(width: UIScreen.main.bounds.width - 40)
            .background(Color.white)
            .cornerRadius(30)
        }
        .padding(.horizontal)
        
    }
}

//#Preview {
//    CollapsedGoalViewCell()
//}
