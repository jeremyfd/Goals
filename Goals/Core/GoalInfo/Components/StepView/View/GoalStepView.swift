//
//  GoalStepView.swift
//  Goals
//
//  Created by Jeremy Daines on 09/02/2024.
//

//import SwiftUI
//import Kingfisher
//
//struct GoalStepView: View {
//    let goal: Goal
//    @ObservedObject var viewModel: GoalStepViewModel
//    @State private var isShowingLargeImage: Bool = false
//    @State private var selectedLargeImageURL: String?
//    @Namespace private var animation
//    @State private var showingDeletionAlert = false
//    @State private var alertMessage = ""
//    @State private var deletionSuccess: Bool = false
//    @State private var showingConfirmationAlert = false
//    @State private var evidenceToDelete: Evidence? = nil
//    @State private var selectedStep: Step? // New state variable to track the selected step
//    
//    
//    init(goal: Goal, viewModel: GoalStepViewModel, selectedImageURL: Binding<String?>, isShowingImage: Binding<Bool>) {
//        self.goal = goal
//        self.viewModel = viewModel
//        self._deletionSuccess = State<Bool>(initialValue: viewModel.deletionSuccess)
//    }
//    
//    var body: some View {
//        
//        ZStack {
//            VStack{
//                ScrollView {
//                    VStack{
//                        
//                        ForEach(0..<goal.duration, id: \.self) { weekNumber in
//                            // Extract the steps for the specific week
//                            let stepsForWeek = viewModel.steps(forGoal: goal).filter { $0.weekNumber == weekNumber + 1 }
//                            
//                            // Get the start date for the week
//                            let weekStartsAt = goal.timestamp.dateValue().addingTimeInterval(week: weekNumber, day: 0)
//
////                            Text("Week \(weekNumber + 1): Starts \(weekStartsAt.dayMonthString())")
//                            
//                            ForEach(stepsForWeek, id: \.id) { step in
//                                VStack {
//                                    HStack {
//                                        Text("Day \(step.day)")
//                                            .bold()
//                                        Spacer()
//                                        
//                                        if viewModel.currentUserID == goal.userID { // Check if current user is the goal's user
//                                            switch step.status {
//                                            case .completed:
//                                                if viewModel.evidences.first(where: { $0.weekNumber == step.weekNumber && $0.day == step.day }) == nil {
//                                                    // Do nothing, the evidence is shown through the image loading below
//                                                }
//                                            case .readyToSubmit:
//                                                Text("Submit Evidence")
//                                                    .foregroundColor(.blue)
//                                                    .onTapGesture {
//                                                        selectedStep = step
//                                                    }
//                                            case .notStartedYet:
//                                                Text("This week hasn’t started yet")
//                                                    .foregroundColor(.gray)
//                                            case .failed:
//                                                Text("You failed this step")
//                                                    .foregroundColor(.gray)
//                                            case .completePreviousStep:
//                                                Text("Complete previous step")
//                                                    .foregroundColor(.gray)
//                                                
//                                            }
//                                        } else { // If the user is not the creator of the goal
//                                            switch step.status {
//                                            case .completed:
//                                                if viewModel.evidences.first(where: { $0.weekNumber == step.weekNumber && $0.day == step.day }) == nil {
//                                                    // Do nothing, the evidence is shown through the image loading below
//                                                }
//                                            case .readyToSubmit:
//                                                Text("No evidence yet")
//                                                    .foregroundColor(.gray)
//                                            case .notStartedYet:
//                                                Text("This week hasn’t started yet")
//                                                    .foregroundColor(.gray)
//                                            case .failed:
//                                                Text("They failed this step")
//                                                    .foregroundColor(.gray)
//                                            case .completePreviousStep:
//                                                Text("No evidence yet")
//                                                    .foregroundColor(.gray)
//                                            }
//                                        }
//                                    }
//                                    
//                                    // Filter the evidence for the specific week and day
//                                    let evidenceForStep = viewModel.evidences.first(where: { $0.weekNumber == step.weekNumber && $0.day == step.day })
//                                    
//                                    if let evidence = evidenceForStep {
//                                        HStack {
//                                            Spacer()
//                                            
//                                            ZStack {
//                                                KFImage(URL(string: evidence.imageURL))
//                                                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 30, height: 30))) // Downsampling to the size of the frame
//                                                    .scaleFactor(UIScreen.main.scale) // Match the screen's scale
//                                                    .cacheOriginalImage() // Cache the original image
//                                                    .resizable()
//                                                    .scaledToFill()
//                                                    .frame(width: 70, height: 70)
//                                                    .clipShape(Circle())
//                                                    .onTapGesture {
//                                                        print("Evidences before enlarging: \(viewModel.evidences)")
//                                                        selectedLargeImageURL = evidence.imageURL
//                                                        isShowingLargeImage = true
//                                                    }
//                                                
//                                                if evidence.isVerified {
//                                                    Image(systemName: "checkmark.circle.fill")
//                                                        .resizable()
//                                                        .aspectRatio(contentMode: .fit)
//                                                        .frame(width: 30, height: 30)
//                                                        .foregroundColor(.green)
//                                                        .background(Color.white)
//                                                        .clipShape(Circle())
//                                                        .offset(x: 20, y: 20)
//                                                }
//                                            }
//                                            
//                                            
//                                            Spacer()
//                                            
//                                            Text("\(viewModel.formatDate(evidence.submittedAt.timestamp.dateValue()))")
//                                            
//                                            Spacer()
//                                            
//                                            if !evidence.isVerified && viewModel.currentUserID == goal.partnerID {
//                                                Button(action: {
//                                                    viewModel.verifyEvidence(evidence)
//                                                }) {
//                                                    Text("Verify")
//                                                        .foregroundColor(.white)
//                                                        .padding()
//                                                        .background(Color.green)
//                                                        .cornerRadius(8)
//                                                }
//                                            }
//                                            
//                                            if viewModel.currentUserID == goal.userID {
//                                                Button(action: {
//                                                    evidenceToDelete = evidence
//                                                    showingConfirmationAlert = true
//                                                }) {
//                                                    Image(systemName: "trash")
//                                                        .foregroundColor(.red)
//                                                }
//                                                
//                                            }
//                                        }
//                                    }
//                                }
//                                .padding()
//                            }
//                        }
//                        // Show the SubmitEvidenceView as a sheet when selectedStep is not nil
////                        .sheet(item: $selectedStep) { step in
////                            SubmitEvidenceView(
////                                goalID: goal.id,
////                                onEvidenceSubmitted: {
////                                    // Handle evidence submission
////                                    // Reload the goal or perform other UI updates
////                                    viewModel.loadGoal()
////                                },
////                                weekNumber: step.weekNumber,
////                                day: step.day
////                            )
////                        }
//                        .alert(isPresented: $showingConfirmationAlert) {
//                            Alert(title: Text("Delete Evidence"),
//                                  message: Text("Are you sure you want to delete this evidence?"),
//                                  primaryButton: .destructive(Text("Delete")) {
//                                // Delete the evidence
//                                if let evidence = evidenceToDelete {
//                                    viewModel.deleteEvidence(evidence) { result in
//                                        switch result {
//                                        case .success:
//                                            print("Success")
//                                        case .failure(let error):
//                                            alertMessage = error.localizedDescription
//                                            showingDeletionAlert = true
//                                        }
//                                    }
//                                }
//                            },
//                                  secondaryButton: .cancel())
//                        }
//                        
//                        .onReceive(viewModel.$deletionSuccess) { success in
//                            if success {
//                                // You can reload the view or perform any other UI updates here
//                                viewModel.loadGoal() // Reloading the goal, including evidences
//                            }
//                        }
//                        .onAppear() {
//                            print("Evidence count: \(viewModel.evidences.count)")
//                        }
//                        .navigationTitle("Goal Details") // Optional title
//                        .navigationBarTitleDisplayMode(.inline) // Optional display mode
//                        .padding(.vertical)
//                        //                .matchedGeometryEffect(id: "expandedScroll", in: animation)
//                    }
//                }
//            }
//        }
//        .sheet(isPresented: $isShowingLargeImage) {
//            ImageViewer(imageURL: $selectedLargeImageURL, isPresented: $isShowingLargeImage)
//        }
//    }
//}
//
//extension Date {
//    func addingTimeInterval(week: Int, day: Int) -> Date {
//        let calendar = Calendar.current
//        var dateComponents = DateComponents()
//        dateComponents.day = week * 7 + day
//        return calendar.date(byAdding: dateComponents, to: self) ?? self
//    }
//
//    func dayMonthString() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEEE d MMMM"
//        return formatter.string(from: self)
//    }
//}
//
//private struct FailedStatusView: View {
//    var body: some View {
//        // Code to handle the "Failed" status
//        // Can be as simple as an empty view if no action is needed:
//        EmptyView()
//    }
//}
//
//private struct CompletePreviousStepStatusView: View {
//    var body: some View {
//        // Code to handle the "Complete previous step" status
//        // Can be as simple as an empty view if no action is needed:
//        EmptyView()
//    }
//}

import SwiftUI
import Kingfisher

struct GoalStepView: View {
    let goal: Goal
    @ObservedObject var viewModel: GoalStepViewModel
    @State private var isShowingLargeImage = false
    @State private var selectedLargeImageURL: String?
    @Namespace private var animation
    @State private var showingDeletionAlert = false
    @State private var alertMessage = ""
    @State private var deletionSuccess = false
    @State private var showingConfirmationAlert = false
    @State private var evidenceToDelete: Evidence?
    @State private var selectedStep: Step?
    
    init(goal: Goal, viewModel: GoalStepViewModel) {
        self.goal = goal
        self.viewModel = viewModel
        _deletionSuccess = State<Bool>(initialValue: viewModel.deletionSuccess)
    }
    
    var body: some View {
        ZStack {
            VStack {
                goalStepsScrollView
            }
        }
        .sheet(isPresented: $isShowingLargeImage) {
            ImageViewer(imageURL: $selectedLargeImageURL, isPresented: $isShowingLargeImage)
        }
    }
    
    private var goalStepsScrollView: some View {
        ScrollView {
            VStack {
                ForEach(0..<goal.duration, id: \.self) { weekNumber in
                    weekSection(weekNumber: weekNumber)
                }
            }
            .alert(isPresented: $showingConfirmationAlert) {
                confirmationAlert
            }
            .onReceive(viewModel.$deletionSuccess) { success in
                if success {
                    Task {
                        await viewModel.loadGoal()
                    }
                }
            }
            .onAppear {
                print("Evidence count: \(viewModel.evidences.count)")
            }
            .navigationTitle("Goal Details")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.vertical)
        }
    }
    
    @ViewBuilder
    private func weekSection(weekNumber: Int) -> some View {
        let stepsForWeek = viewModel.steps(forGoal: goal).filter { $0.weekNumber == weekNumber + 1 }
        let weekStartsAt = goal.timestamp.dateValue().addingTimeInterval(week: weekNumber, day: 0)
        
        // Corrected part: Removed unnecessary ForEach loop that was causing repetition
        Text("Week \(weekNumber + 1): Starts \(weekStartsAt.dayMonthString())")
            .bold()
            .font(.title3)
        ForEach(stepsForWeek, id: \.id) { step in
            StepView(step: step, viewModel: viewModel, goal: goal, selectedLargeImageURL: $selectedLargeImageURL, isShowingLargeImage: $isShowingLargeImage, evidenceToDelete: $evidenceToDelete, showingConfirmationAlert: $showingConfirmationAlert)
        }
    }
    
    private var confirmationAlert: Alert {
        Alert(title: Text("Delete Evidence"),
              message: Text("Are you sure you want to delete this evidence?"),
              primaryButton: .destructive(Text("Delete")) {
            if let evidence = evidenceToDelete {
//                viewModel.deleteEvidence(evidence) { result in
//                    switch result {
//                    case .success:
//                        print("Success")
//                    case .failure(let error):
//                        alertMessage = error.localizedDescription
//                        showingDeletionAlert = true
//                    }
//                }
            }
        },
              secondaryButton: .cancel())
    }
}

extension Date {
    func addingTimeInterval(week: Int, day: Int) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.day = week * 7 + day
        return calendar.date(byAdding: dateComponents, to: self) ?? self
    }
    
    func dayMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        return formatter.string(from: self)
    }
}

