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
    @State private var snappedItem = 0.0
    @State private var draggingItem = 0.0
    @State private var showReactions = false
    
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
            ZStack {
                ForEach(evidences) { evidence in
                    KFImage(URL(string: evidence.imageUrl))
                        .resizable()
                        .cornerRadius(20)
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .scaleEffect(1.0 - abs(distance(evidence.id)) * 0.2)
                        .opacity(1.0 - abs(distance(evidence.id)) * 0.3)
                        .offset(x: myXOffset(evidence.id), y: 0)
                        .zIndex(1.0 - abs(distance(evidence.id)) * 0.1)
                        .onTapGesture {
                            self.selectedImageURL = evidence.imageUrl
                            self.isImageViewerPresented = true
                        }
                }
            }
            // Apply gesture conditionally
            .if(evidences.count > 1) { view in
                view.gesture(
                    DragGesture()
                        .onChanged { value in
                            draggingItem = snappedItem + value.translation.width / 100
                        }
                        .onEnded { value in
                            withAnimation {
                                draggingItem = snappedItem + value.predictedEndTranslation.width / 100
                                draggingItem = round(draggingItem).remainder(dividingBy: Double(evidences.count))
                                snappedItem = draggingItem
                            }
                        }
                )
            }
//            .frame(height: 300) // Adjust based on your UI needs
            .sheet(isPresented: $isImageViewerPresented) {
                ImageViewer(imageURL: $selectedImageURL, isPresented: $isImageViewerPresented)
            }
            
            
            HStack {
                Text(viewModel.stepDescription ?? "")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                if viewModel.isStepVerified {
                    Text("Step Verified!")
                        .bold()
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(30)
                }
            }
            .padding(.horizontal)
            .padding(.horizontal)
            .padding(.vertical, 5)
            
            if currentUserID == goal.partnerUid && !viewModel.isStepVerified {
                Button {
                    viewModel.verifyStep(stepId: step.id, isVerified: true)
                } label: {
                    HStack{
                        Text("Confirm?")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 40)
                    .background(Color.green.opacity(0.7))
                    .cornerRadius(40) // Rounded corners
                }
                
            }
            
            if showReactions {
                HStack {
                    ReactionButtonsView(goalID: goal.id, ownerUid: goal.ownerUid, viewModel: viewModel)
                }
                .padding(.leading)
                .padding(.vertical, 5)
                .frame(width: UIScreen.main.bounds.width - 40, height: 100)
                .background(Color.white)
                .cornerRadius(30)
            }
            
            NavigationLink {
                ExpandedGoalView(goal: goal)
            } label: {
                HStack{
                    VStack(alignment: .leading){
                        
                        HStack {
                            Text(goal.title)
                                .fontWeight(.bold)
                            Text("@\(goal.user?.username ?? "")")
                        }
                        
                        HStack{
                            Text("Tier \(goal.tier)")
                            Text("Step \(step.dayNumber)")
                        }
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        showReactions.toggle()
                    } label: {
                        Image(systemName: "heart")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                    }
                    
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                .background(Color.white)
                .cornerRadius(40) // Rounded corners
            }
            
            // Other UI elements as needed
        }
        .onAppear {
            viewModel.fetchStepDescriptionAndVerifyStatus(stepID: step.id)
        }
    }
    
    func distance(_ evidenceID: String) -> Double {
        if let index = evidences.firstIndex(where: { $0.id == evidenceID }) {
            return (draggingItem - Double(index)).remainder(dividingBy: Double(evidences.count))
        }
        return 0
    }
    
    func myXOffset(_ evidenceID: String) -> CGFloat {
        if let index = evidences.firstIndex(where: { $0.id == evidenceID }) {
            let angle = Double.pi * 2 / Double(evidences.count) * distance(evidenceID)
            return CGFloat(sin(angle) * 200)
        }
        return 0
    }
    
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}


//#Preview {
//    EvidenceViewFeedView()
//}
