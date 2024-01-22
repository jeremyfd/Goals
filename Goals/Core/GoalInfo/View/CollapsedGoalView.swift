//
//  CollapsedGoalView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI

struct CollapsedGoalView: View {
    let goal: Goal
    
    var body: some View {
        
        Button {
            
        } label: {
            HStack{
                VStack(alignment: .leading, spacing: 5){
                    
                    Text(goal.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack{
                        CircularProfileImageView(user: goal.user, size: .small)
                        
                        Text(goal.user?.username ?? "")
                    }
                        
                }
                .foregroundColor(.black)
                .padding()
                
                Spacer()
                
                HStack {
                    Text("Week 2")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.trailing)
                    
                    Image(systemName: "chevron.down")
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
            .cornerRadius(40) // Rounded corners
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    CollapsedGoalView()
//}
