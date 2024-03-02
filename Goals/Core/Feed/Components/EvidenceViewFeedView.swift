//
//  EvidenceViewFeedView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI
import Kingfisher

struct EvidenceViewFeedView: View {
    @State private var isShowingExpandedGoalView = false
    @State private var isImageViewerPresented = false
    @State private var selectedImageURL: String?
    var evidence: Evidence
    var goal: Goal
    var currentUser: User?
    @State private var isEvidenceVerified: Bool
    
    // Initialize isEvidenceVerified with evidence.verified in the initializer
    init(evidence: Evidence, goal: Goal, currentUser: User?) {
        self.evidence = evidence
        self.goal = goal
        self.currentUser = currentUser
        _isEvidenceVerified = State(initialValue: evidence.verified)
    }
    
    var currentUserID: String? {
            AuthService.shared.userSession?.uid
        }

    var body: some View {
        VStack{
            
            ZStack(alignment: .bottom) {
                KFImage(URL(string: evidence.imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height/2)
                    .cornerRadius(20)
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .center, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
                    )
                    .onTapGesture {
                        self.selectedImageURL = evidence.imageUrl
                        self.isImageViewerPresented = true
                    }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("London")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        Text(evidence.timestamp.toDateTimeString())
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    if isEvidenceVerified {
                        Text("Verified!")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                    }
                }
                .padding()
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height/2)
            .cornerRadius(40)
            .sheet(isPresented: $isImageViewerPresented) {
                ImageViewer(imageURL: $selectedImageURL, isPresented: $isImageViewerPresented)
            }
            
            
            NavigationLink {
                ExpandedGoalView(goal: goal)
            } label: {
                HStack{
                    VStack(alignment: .leading){
                        Text(goal.title)
                            .fontWeight(.bold)
                        
                        HStack{
                            Text(goal.user?.username ?? "")
                            Text("Week 2")
                        }
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Image(systemName: "heart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
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
            .padding(.horizontal)
            
            if currentUserID == goal.partnerUid && !isEvidenceVerified {
                Button {
                    // Use Task to perform asynchronous action
                    Task {
                        do {
                            // Assuming evidenceId and goalId are correctly set up in your evidence object
                            let evidenceId = evidence.id
                            let goalId = evidence.goalID
                            
                            // Call updateEvidenceVerification to verify the evidence
                            try await EvidenceService.updateEvidenceVerification(evidenceId: evidenceId, isVerified: true, goalId: goalId)
                            
                            // Now the button will disappear after being clicked and the operation succeeds
                            isEvidenceVerified = true
                        } catch {
                            // Handle any errors appropriately
                            print("Failed to verify evidence: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    HStack{
                        Text("Confirm?")
                            .font(.title2)
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 40)
                    .background(Color.green.opacity(0.7))
                    .cornerRadius(40) // Rounded corners
                }
                .padding(.horizontal)
            }

        }
    }
}

//#Preview {
//    EvidenceViewFeedView()
//}
