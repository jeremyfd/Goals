//
//  ExpandedGoalView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI
import Firebase

struct ExpandedGoalView: View {
    let goal: Goal
    @StateObject private var viewModel = ExpandedGoalViewModel()
//    @StateObject private var evidenceViewModel: EvidenceSubViewModel
    @State private var showCalendarView = false
    @State private var isDescriptionExpanded: Bool = false
    @State private var navigateToUser: User? = nil
    @State private var showActionSheet = false
    @State private var showAlert = false
    @State private var showingSubmitEvidenceView = false
    @State private var showNextTierView = false
    @Environment(\.presentationMode) var presentationMode
    
    @State private var submitEvidenceSheetIdentifier: SubmitEvidenceSheetIdentifier?
    
    private var currentUser: User? {
        return viewModel.currentUser
    }
    
    init(goal: Goal) {
        self.goal = goal
        let startDate = goal.timestamp.dateValue()
//        _evidenceViewModel = StateObject(wrappedValue: EvidenceSubViewModel(goalId: goal.id, startDate: startDate, duration: goal.duration, frequency: goal.frequency, targetCount: goal.targetCount))
    }
    
    private func formatDate(_ timestamp: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        //        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: timestamp.dateValue())
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
                
//                EvidenceSubView(goal: goal, viewModel: evidenceViewModel) { weekNumber, dayNumber in
//                    self.submitEvidenceSheetIdentifier = SubmitEvidenceSheetIdentifier(goalID: goal.id, weekNumber: weekNumber, dayNumber: dayNumber)
//                }
                
                .sheet(item: $submitEvidenceSheetIdentifier) { identifier in
//                    SubmitEvidenceView(viewModel: SubmitEvidenceViewModel(goalID: identifier.goalID, weekNumber: identifier.weekNumber, dayNumber: identifier.dayNumber)) {
////                        Task {
////                            await evidenceViewModel.fetchEvidenceForGoal()
////                        }
//                    }
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
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.9)]),
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .sheet(isPresented: $showCalendarView) {
            CalendarView()
        }
        .sheet(isPresented: $showNextTierView) {
            // Present NextTierView as a sheet
            NextTierView(goal: goal)
        }
    }
}


//#Preview {
//    ExpandedGoalView()
//}

//
//LazyVStack {
//    
//    Text("Week 1 - 1st January 2023")
//        .font(.title2)
//        .fontWeight(.bold)
//        .padding(.top, 5)
//    
//    ForEach(0..<3) { _ in
//        HStack {
//            Image("gymphoto")
//                .resizable()
//                .scaledToFill()
//                .frame(width: 110, height: 110)
//                .cornerRadius(40)
//            
//            Image(systemName: "checkmark.circle.fill")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 40, height: 40)
//                .foregroundColor(.green)
//                .background(Color.white)
//                .clipShape(Circle())
//                .offset(x: -40, y: 30)
//            
//            VStack(alignment: .leading) {
//                Text("Monday 7th June")
//                Text("20h13")
//                Text("London")
//            }
//            .font(.subheadline)
//            .padding(.leading, -30)
//            
//            Spacer()
//        }
//    }
//    
//    Text("Week 2 - 8th January 2023")
//        .font(.title2)
//        .fontWeight(.bold)
//        .padding(.top, 5)
//    
//    ForEach(0..<3) { _ in
//        HStack {
//            Image("gymphoto")
//                .resizable()
//                .scaledToFill()
//                .frame(width: 110, height: 110)
//                .cornerRadius(40)
//            
//            Image(systemName: "checkmark.circle.fill")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 40, height: 40)
//                .foregroundColor(.green)
//                .background(Color.white)
//                .clipShape(Circle())
//                .offset(x: -40, y: 30)
//            
//            VStack(alignment: .leading) {
//                Text("Monday 7th June")
//                Text("20h13")
//                Text("London")
//            }
//            .font(.subheadline)
//            .padding(.leading, -30)
//            
//            Spacer()
//        }
//    }
//}
