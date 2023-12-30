//
//  SelfCollapsedGoalView.swift
//  Goals
//
//  Created by Work on 29/12/2023.
//

import SwiftUI

struct SelfCollapsedGoalView: View {
    var body: some View {
        
        Button {
            
        } label: {
            HStack{
                VStack(alignment: .leading, spacing: 5){
                    
                    Text("Go Gym")
                        .font(.title2)
                        .fontWeight(.bold)
                        
                }
                .foregroundColor(.black)
                .padding()
                                
                HStack {
                    Text("Last day!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
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
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(40) // Rounded corners
        }
    }
}

#Preview {
    SelfCollapsedGoalView()
}
