//
//  EvidenceViewFeedView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI
import Kingfisher

struct EvidenceViewFeedView: View {
    var step: Step
    var evidences: [Evidence]
    var goal: Goal
    var currentUser: User?
    
    @StateObject private var viewModel: GoalViewCellViewModel
    @State private var selectedImageURL: String?
    @State private var isImageViewerPresented = false
    
    // Initialize with a goal and optionally a user
    init(step: Step, evidences: [Evidence], goal: Goal, currentUser: User?) {
        self.step = step
        self.evidences = evidences
        self.goal = goal
        self.currentUser = currentUser
        _viewModel = StateObject(wrappedValue: GoalViewCellViewModel(goalId: goal.id))
    }
    
    var currentUserID: String? {
        AuthService.shared.userSession?.uid
    }
    
    var body: some View {
        VStack {
            // Carousel of evidences
            TabView {
                ForEach(evidences, id: \.id) { evidence in
                    KFImage(URL(string: evidence.imageUrl))
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width - 40, height: 250)
                        .tag(evidence.id)
                        .onTapGesture {
                            self.selectedImageURL = evidence.imageUrl
                            self.isImageViewerPresented = true
                        }
                }
            }
            .onAppear{
                print("DEBUG: \(goal.partnerUid)")
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 250) // Adjust based on your UI needs
            .sheet(isPresented: $isImageViewerPresented) {
                ImageViewer(imageURL: $selectedImageURL, isPresented: $isImageViewerPresented)
            }
            
            // Step description and verification
            // Ensure you implement functionality in GoalViewCellViewModel to fetch and update these details
            Text(viewModel.stepDescription ?? "")
            
            
            if viewModel.isStepVerified {
                Text("Step Verified")
                    .foregroundColor(.green)
            }
            
            if currentUserID == goal.partnerUid && !viewModel.isStepVerified {
                // Confirmation button when the step is not verified
                Button("Confirm Verification") {
                    viewModel.verifyStep(stepId: step.id, isVerified: true)
                }
                .foregroundColor(.blue)
                .padding()
            }
            
            // Reactions and other goal-specific functionalities can continue to use GoalViewCellViewModel
            ReactionButtonsView(goalID: goal.id, ownerUid: goal.ownerUid, viewModel: viewModel)
            
            // Other UI elements as needed
        }
        .onAppear {
            viewModel.fetchStepDescriptionAndVerifyStatus(stepID: step.id)
        }
    }
}

//#Preview {
//    EvidenceViewFeedView()
//}
