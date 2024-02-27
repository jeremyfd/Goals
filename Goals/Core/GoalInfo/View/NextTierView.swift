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
        .onChange(of: viewModel.operationSuccessful) { success in
            if success == true {
                Task {
                        await goalViewModel.refreshGoalDetails(goalId: goal.id)
                    }
                if let user = userViewModel.currentUser {
                    userViewModel.refreshUserGoals(for: user)
                }
                dismiss()
            } else if success == false {
                // Handle operation failure here, e.g., showing an alert
            }
        }
    }
}

//#Preview {
//    NextTierView()
//}
