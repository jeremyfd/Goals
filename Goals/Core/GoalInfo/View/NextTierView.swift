//
//  NextTierView.swift
//  Goals
//
//  Created by Jeremy Daines on 27/02/2024.
//

import SwiftUI

struct NextTierView: View {
    var goal: Goal
    @StateObject private var viewModel = NextTierViewModel()
    @StateObject private var goalViewModel = ExpandedGoalViewModel()
    @StateObject private var userViewModel = CurrentUserProfileViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            if viewModel.isProcessing {
                ProgressView()
            } else {
                Text("Congratulations on accomplishing Tier 1!")
                Text("You can now start progressing towards Tier 2!")
                Text("It is however important to take breaks sometimes. Reflect on this past tier and how you are feeling.")
                Button("Start Today") {
                    viewModel.incrementTargetCount(goalId: goal.id)
                    viewModel.addNewCycle(goalId: goal.id, newTier: goal.tier)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Start Later") {
                    dismiss()
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
    }
}

//#Preview {
//    NextTierView()
//}
