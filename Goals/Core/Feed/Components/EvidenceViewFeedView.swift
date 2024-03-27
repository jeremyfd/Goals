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
    @State private var showReactions = false
    @State private var currentIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0
    
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
                ForEach(Array(evidences.enumerated()), id: \.element.id) { (index, evidence) in
                    KFImage(URL(string: evidence.imageUrl))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 250, height: 250, alignment: .center)
                        .contentShape(Rectangle())
                        .clipped()
                        .cornerRadius(20)
                        .opacity(self.currentIndex == index ? 1.0 : 0.5)
                        .scaleEffect(self.currentIndex == index ? 1.2 : 0.8)
                        .offset(x: CGFloat(index - self.currentIndex) * 250 + self.dragOffset, y: 0)
                        .zIndex(self.currentIndex == index ? 1 : 0)
                        .onTapGesture {
                            self.selectedImageURL = evidence.imageUrl
                            self.isImageViewerPresented = true
                        }
                }
            }
            .if(evidences.count > 1) { view in
                view.gesture(
                    DragGesture()
                        .updating($dragOffset, body: { (value, state, _) in
                            state = value.translation.width
                        })
                        .onEnded({ value in
                            let threshold: CGFloat = 100 // Threshold to determine if the drag should result in an index change
                            if value.translation.width > threshold {
                                currentIndex = max(0, currentIndex - 1)
                            } else if value.translation.width < -threshold {
                                currentIndex = min(evidences.count - 1, currentIndex + 1)
                            }
                        })
                )
            }
            .frame(width: 500, height: 300) // Here we use fixed dimensions for the ZStack
            .background(Color.clear) // Apply a clear background to prevent images from showing through
            .sheet(isPresented: $isImageViewerPresented) {
                ImageViewer(imageURL: $selectedImageURL, isPresented: $isImageViewerPresented)
            }
            .padding(.vertical)
            
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
            
        }
        .padding(.bottom)
        .onAppear {
            viewModel.fetchStepDescriptionAndVerifyStatus(stepID: step.id)
        }
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

//
//VStack {
//    ZStack {
//        ForEach(0..<images.count, id: \.self) { index in
//            Image(images[index])
//                .frame(width: 300, height: 500)
//                .cornerRadius(25)
//                .opacity(currentIndex == index ? 1.0 : 0.5)
//                .scaleEffect(currentIndex == index ? 1.2 : 0.8)
//                .offset(x: CGFloat(index - currentIndex) * 300 + dragOffset, y: 0)
//        }
//    }
//    .gesture(
//        DragGesture()
//            .onEnded({ value in
//                let threshold: CGFloat = 50
//                if value.translation.width > threshold {
//                    withAnimation {
//                        currentIndex = max(0, currentIndex - 1)
//                    }
//                } else if value.translation.width < -threshold {
//                    withAnimation {
//                        currentIndex = min(images.count - 1, currentIndex + 1)
//                    }
//                }
//            })
//    )
//}
//.navigationTitle("Image carousel")
