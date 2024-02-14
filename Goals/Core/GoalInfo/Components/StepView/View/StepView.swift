//
//  StepView.swift
//  Goals
//
//  Created by Jeremy Daines on 13/02/2024.
//

import SwiftUI
import Kingfisher
import Firebase

struct StepView: View {
    var step: Step
    @ObservedObject var viewModel: GoalStepViewModel
    let goal: Goal
    @Binding var selectedLargeImageURL: String?
    @Binding var isShowingLargeImage: Bool
    @Binding var evidenceToDelete: Evidence?
    @Binding var showingConfirmationAlert: Bool
    @State private var isShowingSubmitEvidenceView = false
    
    var body: some View {
        VStack {
            stepHeader
            if let evidence = step.evidence, let imageURL = evidence.imageURL {
                evidenceView(evidence, imageURL: imageURL)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var stepHeader: some View {
        HStack {
            Text("Day \(step.day)")
                .bold()
            Spacer()
            statusView
        }
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch step.status {
        case .completed:
            if step.evidence == nil {
                EmptyView()
            }
        case .readyToSubmit:
            submitEvidenceView
        case .notStartedYet, .failed, .completePreviousStep:
            Text(step.status.rawValue)
                .foregroundColor(.gray)
        }
    }
    
    @ViewBuilder
    private var submitEvidenceView: some View {
        if viewModel.currentUserID == goal.ownerUid {
            Button("Submit Evidence") {
                // Set the state to true to present the SubmitEvidenceView
                isShowingSubmitEvidenceView = true
            }
            .foregroundColor(.blue)
            .sheet(isPresented: $isShowingSubmitEvidenceView) {
                // Present the SubmitEvidenceView
                // Pass necessary bindings and initializations
                SubmitEvidenceView(viewModel: SubmitEvidenceViewModel(goalID: goal.id, weekNumber: step.weekNumber, day: step.day))
            }
        } else {
            Text("No evidence yet")
                .foregroundColor(.gray)
        }
    }
    
    @ViewBuilder
    private func evidenceView(_ evidence: Evidence, imageURL: String) -> some View {
        HStack {
            Spacer()
            ZStack {
                KFImage(URL(string: imageURL))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .onTapGesture {
                        selectedLargeImageURL = imageURL
                        isShowingLargeImage = true
                    }
                if evidence.isVerified {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: 20, y: 20)
                }
            }
            Spacer()
            Text(formatDate(evidence.timestamp.dateValue()))
            Spacer()
            verificationButton(evidence)
            if viewModel.currentUserID == goal.ownerUid {
                deletionButton(evidence)
            }
        }
    }
    
    @ViewBuilder
    private func verificationButton(_ evidence: Evidence) -> some View {
        if !evidence.isVerified && viewModel.currentUserID == goal.partnerUid {
            Button("Verify") {
                Task {
                    try await  viewModel.verifyEvidence(evidence)
                }
                
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.green)
            .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private func deletionButton(_ evidence: Evidence) -> some View {
        Button(action: {
            evidenceToDelete = evidence
            showingConfirmationAlert = true
        }) {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
