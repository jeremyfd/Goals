//
//  GoalViewCell.swift
//  Goals
//
//  Created by Jeremy Daines on 05/02/2024.
//

import SwiftUI

struct GoalViewCell: View {
    let goal: Goal
    @State private var showReactions = false

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 5) {
                
                Text(goal.title)
                .font(.title)
                .fontWeight(.bold)
            
            HStack{
                CircularProfileImageView(user: goal.user, size: .small)
                
                Text(goal.user?.username ?? "")
                    .font(.title2)
            }
        }
            
            Text("Completed 6 times.")
                .font(.title)
                .fontWeight(.bold)
            
            
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(0..<5) { _ in
                        ZStack {
                            Image("gymphoto")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .cornerRadius(40)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.green)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: 40, y: 30)

                        }
                    }
                }
            }
            
            HStack {
                ExpansionButtonView(isExpanded: $showReactions)
                
                Spacer()
                
                NavigationLink {
                    ExpandedGoalView()
                } label: {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 8)
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(40)
    }
}

//#Preview {
//    GoalViewCell()
//}
