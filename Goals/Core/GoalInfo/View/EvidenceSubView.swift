//////
//////  EvidenceSubView.swift
//////  Goals
//////
//////  Created by Jeremy Daines on 15/02/2024.
//////
////
////import SwiftUI
////import Kingfisher
////
////
////struct EvidenceSubView: View {
////    let goal: Goal
////    @ObservedObject var viewModel: EvidenceSubViewModel
////    var onSubmitEvidence: (Int, Int) -> Void
////    @State private var countdowns: [UUID: String] = [:] // Assuming step.id is of type UUID
////    
////    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
////    @State private var timeNow = Date()
////    
////    @State private var isImageViewerPresented = false
////    @State private var selectedImageURL: String?
////    
////    var body: some View {
////        ForEach(viewModel.steps, id: \.id) { step in
////            VStack {
////                // Separate the countdown text into its own view for clarity
////                if step.status != .completed {
////                    countdownTextView(stepId: step.id, weekNumber: step.weekNumber, dayNumber: step.dayNumber, deadline: step.deadline)
////                } else {
////                    // If the step is completed, show a simplified text without the countdown
////                    Text("Week \(step.weekNumber), Day \(step.dayNumber) - Deadline: \(formatDate(step.deadline))")
////                }
////
////                stepStatusView(step: step)
////            }
////            .padding(.vertical, 5)
////        }
////    }
////    
////    @ViewBuilder
////    private func countdownTextView(stepId: UUID, weekNumber: Int, dayNumber: Int, deadline: Date) -> some View {
////        Text("Week \(weekNumber), Day \(dayNumber) - Deadline: \(formatDate(deadline)) - Countdown: \(countdowns[stepId, default: "Calculating..."])")
////            .onReceive(timer) { _ in
////                self.timeNow = Date() // Updating the timeNow, though it might be unnecessary if only used for countdown
////                // This loop could potentially be moved outside or optimized to not run for every step view
////                for step in viewModel.steps where step.status != .completed {
////                    countdowns[step.id] = countdownString(to: step.deadline)
////                }
////            }
////    }
////
////    
//    @ViewBuilder
//    private func stepStatusView(step: Step) -> some View {
//        if viewModel.currentUserID == goal.ownerUid {
//            switch step.status {
//            case .completed:
//                completedStepView(step: step)
//            case .readyToSubmit:
//                Button("Submit Evidence") {
//                    onSubmitEvidence(step.weekNumber, step.dayNumber)
//                }
//                .buttonStyle(.borderedProminent)
//            case .notStartedYet:
//                Text("This week hasn’t started yet")
//                    .foregroundColor(.gray)
//            case .failed:
//                Text("You failed this step")
//                    .foregroundColor(.gray)
//            case .completePreviousStep:
//                Text("Complete previous step")
//                    .foregroundColor(.gray)
//                
//            }
//        } else { // If the user is not the creator of the goal
//            switch step.status {
//            case .completed:
//                completedStepView(step: step)
//            case .readyToSubmit:
//                Text("No evidence yet")
//                    .foregroundColor(.gray)
//            case .notStartedYet:
//                Text("This week hasn’t started yet")
//                    .foregroundColor(.gray)
//            case .failed:
//                Text("They failed this step")
//                    .foregroundColor(.gray)
//            case .completePreviousStep:
//                Text("No evidence yet")
//                    .foregroundColor(.gray)
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private func completedStepView(step: Step) -> some View {
//        if let evidence = step.evidence {
//            VStack {
//                KFImage(URL(string: evidence.imageUrl))
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 110, height: 110)
//                    .cornerRadius(40)
//                    .onTapGesture {
//                        self.selectedImageURL = evidence.imageUrl
//                        self.isImageViewerPresented = true
//                    }
//                    .overlay(verificationOverlay(for: evidence))
//                
//                // Delete button for evidence
//                if viewModel.currentUserID == goal.ownerUid {
//                    Button("Delete Evidence") {
//                        viewModel.deleteEvidence(evidenceId: evidence.evidenceId ?? "")
//                    }
//                    .foregroundColor(.red)
//                    .buttonStyle(.bordered)
//                }
//                
//                // Verify button for the goal's partner
//                if viewModel.currentUserID == goal.partnerUid && !evidence.verified {
//                    Button("Verify") {
//                        viewModel.verifyEvidence(evidenceId: evidence.evidenceId ?? "")
//                    }
//                    .foregroundColor(.green)
//                    .buttonStyle(.borderedProminent)
//                }
//                
//            }
//            .sheet(isPresented: $isImageViewerPresented) {
//                ImageViewer(imageURL: $selectedImageURL, isPresented: $isImageViewerPresented)
//            }
//        } else {
//            Text("No Evidence").foregroundColor(.gray)
//        }
//    }
////    
////    func formatDate(_ date: Date) -> String {
////        let formatter = DateFormatter()
////        formatter.dateStyle = .medium
////        formatter.timeStyle = .short
////        return formatter.string(from: date)
////    }
////
//    @ViewBuilder
//    private func verificationOverlay(for evidence: Evidence) -> some View {
//        if evidence.verified {
//            Image(systemName: "checkmark.circle.fill")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 40, height: 40)
//                .foregroundColor(.green)
//                .background(Color.white)
//                .clipShape(Circle())
//                .offset(x: 40, y: 30)
//        } else {
//            EmptyView()
//        }
//    }
//}
////
////extension EvidenceSubView {
////    func countdownString(to deadline: Date) -> String {
////        let now = Date()
////        if deadline > now {
////            let timeInterval = deadline.timeIntervalSince(now)
////            let hours = Int(timeInterval) / 3600
////            let minutes = Int(timeInterval) / 60 % 60
////            let seconds = Int(timeInterval) % 60
////            let countdownString = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
////            return countdownString
////        } else {
////            return "Deadline has passed"
////        }
////    }
////
////}
////
//////struct EvidenceSubView_Previews: PreviewProvider {
//////    static var previews: some View {
//////        
//////        let mockGoalId = "mockGoalId"
//////               let mockStartDate = Date() // Use current date for simplicity
//////               let mockDuration = 30 // 30 days
//////               let mockFrequency = 3 // 3 times a week
//////               let mockTargetCount = 9 // 9 completions
//////        
//////        let viewModel = EvidenceSubViewModel(goalId: mockGoalId, startDate: mockStartDate, duration: mockDuration, frequency: mockFrequency, targetCount: mockTargetCount)
//////
//////        let goal = DeveloperPreview.shared.goal
//////        
//////        let onSubmitEvidence: (Int, Int) -> Void = { weekNumber, dayNumber in
//////            print("Submit evidence for week \(weekNumber), day \(dayNumber)")
//////        }
//////        
//////        // Return the EvidenceSubView configured with the preview data
//////        EvidenceSubView(goal: goal, viewModel: viewModel, onSubmitEvidence: onSubmitEvidence)
//////            .environmentObject(DeveloperPreview.shared) // If your view relies on EnvironmentObjects, set them here.
//////    }
//////}
