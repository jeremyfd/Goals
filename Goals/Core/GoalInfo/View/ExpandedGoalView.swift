//
//  ExpandedGoalView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI
import Firebase
import Kingfisher

struct ExpandedGoalView: View {
    let goal: Goal
    
    @StateObject private var viewModel = ExpandedGoalViewModel()
    @State private var showCalendarView = false
    @State private var isDescriptionExpanded: Bool = false
    @State private var navigateToUser: User? = nil
    @State private var showActionSheet = false
    @State private var showAlert = false
    @State private var showingSubmitEvidenceView = false
    @State private var showNextTierView = false
    @State private var isImageViewerPresented = false
    @State private var selectedImageURL: String?
    var onSubmitEvidence: ((Int, Int) -> Void)?
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var submitEvidenceSheetIdentifier: SubmitEvidenceSheetIdentifier?
    
    private var currentUser: User? {
        return viewModel.currentUser
    }
    
    init(goal: Goal) {
        self.goal = goal
    }
    
    private func formatDate(_ timestamp: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: timestamp.dateValue())
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading) {
                
                VStack(alignment: .leading) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        HStack {
                            Text(goal.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.bottom, -5)
                        
                        HStack{
                            CircularProfileImageView(user: goal.user, size: .small)
                            
                            Text(goal.user?.username ?? "")
                                .font(.title3)
                            
                            Spacer()
                            
                            Button(action: {
                                showCalendarView = true
                            }, label: {
                                HStack {
                                    Image(systemName: "calendar")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25)
                                    
                                    Text("Tier \(goal.tier)")
                                        .font(.title3)
                                    
                                    Image(systemName: "chevron.down")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 15, height: 15)
                                    
                                }
                                .foregroundStyle(Color.black)
                            })
                            
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Started:")
                                .font(.title2)
                                .padding(.top, 5)
                            
                            Text(formatDate(goal.timestamp))
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top, 5)
                        }
                        
                        HStack {
                            Text("Partner:")
                                .font(.title2)
                                .padding(.top, 5)
                            
                            // Display partner username once it's fetched
                            if let partnerUser = viewModel.partnerUser {
                                Text("@\(partnerUser.username)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.top, 5)
                                    .onTapGesture {
                                        navigateToUser = partnerUser
                                    }
                            } else {
                                Text("Partner: Loading...")
                                    .font(.title2)
                                    .padding(.top, 5)
                            }
                        }
                        
                        HStack {
                            Text("Frequency:")
                                .font(.title2)
                                .padding(.top, 5)
                            
                            Text("\(goal.frequency)x a week")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top, 5)
                        }
                        
                        
                        
                        if let description = goal.description, !description.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Description:")
                                    .font(.title2)
                                    .padding(.top, 5)
                                
                                Text(description)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.top, -5)
                                    .lineLimit(isDescriptionExpanded ? nil : 1) // Dynamically change line limit
                                    .fixedSize(horizontal: false, vertical: true) // Allow text to expand vertically
                                
                                Button(action: {
                                    isDescriptionExpanded.toggle()
                                }) {
                                    Text(isDescriptionExpanded ? "Less" : "More")
                                        .font(.headline)
                                }
                            }
                        }
                        
                    }
                    
                    Text("Completed \(goal.currentCount) times.")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 5)
                }
                .padding(.vertical)
                
                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if viewModel.cycles.isEmpty {
                        Text("No cycles available for this goal.")
                    } else {
                        ForEach(viewModel.cycles) { cycle in
                            LazyVStack(alignment: .leading) {
                                VStack(alignment: .leading) {
                                    Text("Tier \(cycle.tier)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Text("Start Date: \(formatDate(cycle.startDate))")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .padding(.bottom)
                                
                                ForEach(viewModel.steps.filter { $0.cycleID == cycle.id }.sorted(by: { $0.deadline < $1.deadline })) { step in
                                    HStack {
                                        stepStatusView(step: step, allSteps: viewModel.steps)
                                            .frame(width: 150, height: 175)
                                        
                                        VStack(alignment: .leading) {
                                            Text("Day \(step.dayNumber)")
                                                .fontWeight(.bold)
                                            Text("Week \(step.weekNumber)")
                                                .fontWeight(.bold)
                                            Text("Deadline: \(formatDate(step.deadline))")
                                        }
                                        .padding(.bottom)
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    viewModel.goal = goal
                    viewModel.fetchCyclesForCurrentGoal()
                    viewModel.fetchStepsForCurrentGoal()
                    viewModel.fetchEvidencesForCurrentGoal()
                    print("DEBUG: View appeared, fetching cycles...")
                }
                .sheet(item: $submitEvidenceSheetIdentifier, onDismiss: {
                    viewModel.fetchEvidencesForCurrentGoal()
                }) { identifier in
                    SubmitEvidenceView(viewModel: SubmitEvidenceViewModel(goalID: identifier.goalID, cycleID: identifier.cycleID, stepID: identifier.stepID, weekNumber: identifier.weekNumber, dayNumber: identifier.dayNumber)) {
                    }
                }
            }
            
            NavigationLink(destination: navigateToUser.map { UserProfileView(user: $0) }, isActive: Binding<Bool>(
                get: { navigateToUser != nil },
                set: { if !$0 { navigateToUser = nil } }
            )) {
                EmptyView()
            }
            
        }
        .scrollIndicators(.hidden)
        .navigationBarItems(trailing: Menu {
            if goal.user?.id == Auth.auth().currentUser?.uid {
                Button(action: {
                    showAlert = true
                }) {
                    Label("Delete Goal", systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .imageScale(.large)
        })
        
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete Goal"),
                message: Text("Are you sure you want to delete this goal? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    // Call the deleteGoal function from the viewModel
                    viewModel.deleteGoal(goalId: goal.id) { result in
                        switch result {
                        case .success():
                            // Handle successful deletion, e.g., dismiss the current view or show a success message
                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            // Handle the error, e.g., show an error message
                            print("Error deleting goal: \(error.localizedDescription)")
                            // You might want to use another @State variable to trigger an error alert/message
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .refreshable {
            Task {
                await viewModel.refreshGoalDetails(goalId: goal.id)
            }
        }
        
        .onAppear {
            if viewModel.partnerUser == nil {
                viewModel.fetchPartnerUser(partnerUid: goal.partnerUid)
            }
            if goal.currentCount == goal.targetCount && viewModel.currentUser?.id == goal.ownerUid {
                showNextTierView = true
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, -10)
        .background(
            LinearGradientView()
        )
        .sheet(isPresented: $showCalendarView) {
            CalendarView()
        }
        .sheet(isPresented: $showNextTierView, onDismiss: {
            viewModel.fetchCyclesForCurrentGoal();
            viewModel.fetchStepsForCurrentGoal()
        }) {
            // Present NextTierView as a sheet
            NextTierView(goal: goal)
        }
    }
    
    @ViewBuilder
    private func stepStatusView(step: Step, allSteps: [Step]) -> some View {
        let isEvidenceSubmitted = viewModel.evidences.contains(where: { $0.stepID == step.id })
        let isPastDeadline = Date() > step.deadline
        let previousSteps = allSteps.filter { $0.deadline < step.deadline }
        let arePreviousStepsCompleted = previousSteps.allSatisfy { previousStep in
            viewModel.evidences.contains(where: { $0.stepID == previousStep.id })
        }
        
        if viewModel.currentUserID == goal.ownerUid {
            
            if isEvidenceSubmitted {
                // Show completed step view
                completedStepView(step: step)
            } else if !arePreviousStepsCompleted {
                // If previous steps are not all completed, indicate that
                Text("Complete previous step").foregroundColor(.gray)
            } else if isPastDeadline {
                // Show failed step if the deadline is past and no evidence submitted
                Text("You failed this step").foregroundColor(.gray)
            } else {
                // This step is ready to submit evidence
                Button("Submit Evidence") {
                    self.submitEvidenceSheetIdentifier = SubmitEvidenceSheetIdentifier(goalID: goal.id, cycleID: step.cycleID, stepID: step.id, weekNumber: step.weekNumber, dayNumber: step.dayNumber)
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            if isEvidenceSubmitted {
                // Show completed step view
                completedStepView(step: step)
            } else if !arePreviousStepsCompleted {
                // If previous steps are not all completed, indicate that
                Text("No evidence yet").foregroundColor(.gray)
            } else if isPastDeadline {
                // Show failed step if the deadline is past and no evidence submitted
                Text("They failed this step").foregroundColor(.gray)
            } else {
                Text("No evidence yet").foregroundColor(.gray)
            }
        }
    }
    
    
    
    @ViewBuilder
    private func completedStepView(step: Step) -> some View {
        if let evidence = viewModel.evidences.first(where: { $0.stepID == step.id }) {
            VStack {
                KFImage(URL(string: evidence.imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 110)
                    .cornerRadius(40)
                    .onTapGesture {
                        self.selectedImageURL = evidence.imageUrl
                        self.isImageViewerPresented = true
                    }
                    .overlay(verificationOverlay(for: evidence))
                
                // Delete button for evidence
                if viewModel.currentUserID == goal.ownerUid {
                    Button("Delete Evidence") {
                        viewModel.deleteEvidence(evidenceId: evidence.evidenceId ?? "")
                    }
                    .foregroundColor(.red)
                    .buttonStyle(.bordered)
                }
                
                // Verify button for the goal's partner
                if viewModel.currentUserID == goal.partnerUid && !evidence.verified {
                    Button("Verify") {
                        viewModel.verifyEvidence(evidenceId: evidence.evidenceId ?? "")
                    }
                    .foregroundColor(.green)
                    .buttonStyle(.borderedProminent)
                }
                
            }
            .sheet(isPresented: $isImageViewerPresented) {
                ImageViewer(imageURL: $selectedImageURL, isPresented: $isImageViewerPresented)
            }
        } else {
            Text("No Evidence").foregroundColor(.gray)
        }
    }
    
    @ViewBuilder
    private func verificationOverlay(for evidence: Evidence) -> some View {
        if evidence.verified {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.green)
                .background(Color.white)
                .clipShape(Circle())
                .offset(x: 40, y: 30)
        } else {
            EmptyView()
        }
    }
}





//#Preview {
//    ExpandedGoalView()
//}
