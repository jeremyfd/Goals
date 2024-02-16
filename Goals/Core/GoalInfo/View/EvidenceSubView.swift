//
//  EvidenceSubView.swift
//  Goals
//
//  Created by Jeremy Daines on 15/02/2024.
//

import SwiftUI
import Kingfisher


struct EvidenceSubView: View {
    @ObservedObject var viewModel: EvidenceSubViewModel
    var onSubmitEvidence: (Int, Int) -> Void

    var body: some View {
        ForEach(viewModel.steps, id: \.id) { step in
            VStack {
                Text("Week \(step.weekNumber), Day \(step.dayNumber)")
                stepStatusView(step: step)
            }
            .padding(.vertical, 5)
        }
    }
    

    @ViewBuilder
    private func stepStatusView(step: Step) -> some View {
        switch step.status {
        case .readyToSubmit:
            Button("Submit Evidence") {
                onSubmitEvidence(step.weekNumber, step.dayNumber)
            }
            .buttonStyle(.borderedProminent)
        case .completed:
            completedStepView(step: step)
        case .completePreviousStep:
            Text("Complete Previous Step").foregroundColor(.orange)
        case .failed:
            Text("Failed to complete").foregroundColor(.red)
        case .notStartedYet:
            Text("Upcoming").foregroundColor(.gray)
        }
    }

    @ViewBuilder
    private func completedStepView(step: Step) -> some View {
        if let evidence = step.evidence {
            KFImage(URL(string: evidence.imageUrl))
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .cornerRadius(10)
                .overlay(verificationOverlay(for: evidence))
        } else {
            Text("No Evidence").foregroundColor(.gray)
        }
    }

    @ViewBuilder
    private func verificationOverlay(for evidence: Evidence) -> some View {
        if evidence.verified {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.green)
                .background(Circle().fill(Color.white))
                .offset(x: -5, y: -5)
        } else {
            EmptyView()
        }
    }
}

struct SubmitEvidenceSheetIdentifier: Identifiable {
    let id: UUID = UUID()
    var goalID: String
    var weekNumber: Int
    var dayNumber: Int
}
