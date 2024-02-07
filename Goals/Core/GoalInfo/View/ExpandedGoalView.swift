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
    @State private var showCalendarView = false
    
    private func formatDate(_ timestamp: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
//        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: timestamp.dateValue())
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            VStack(alignment: .leading) {
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text(goal.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Button(action: {
                        showCalendarView = true
                    },
                           label: {
                        HStack {
                            Image(systemName: "flame.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                            
                            Text("Week 10")
                                .font(.title)
                            
                            Image(systemName: "chevron.down")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                            
                        }
                        .foregroundStyle(Color.black)
                    })
                    
                    
                    HStack{
                        CircularProfileImageView(user: goal.user, size: .small)
                        
                        Text(goal.user?.username ?? "")
                            .font(.title2)
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
                    
                }
                
                Text("Completed 6 times.")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 5)
            }
            .padding(.vertical)
            
            ScrollView {
                
                LazyVStack {
                    
                    Text("Week 1 - 1st January 2023")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 5)
                    
                    ForEach(0..<3) { _ in
                        HStack {
                            Image("gymphoto")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .cornerRadius(40)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.green)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: -40, y: 30)
                            
                            VStack(alignment: .leading) {
                                Text("Monday 7th June")
                                Text("20h13")
                                Text("London")
                            }
                            .font(.subheadline)
                            .padding(.leading, -30)
                            
                            Spacer()
                        }
                    }
                    
                    Text("Week 2 - 8th January 2023")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 5)
                    
                    ForEach(0..<3) { _ in
                        HStack {
                            Image("gymphoto")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .cornerRadius(40)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.green)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: -40, y: 30)
                            
                            VStack(alignment: .leading) {
                                Text("Monday 7th June")
                                Text("20h13")
                                Text("London")
                            }
                            .font(.subheadline)
                            .padding(.leading, -30)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .onAppear {
            if viewModel.partnerUser == nil {
                viewModel.fetchPartnerUser(partnerUid: goal.partnerUid)
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
    }
}


//#Preview {
//    ExpandedGoalView()
//}
