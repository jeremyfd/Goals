//
//  UserProfileView.swift
//  Goals
//
//  Created by Jeremy Daines on 06/02/2024.
//

import SwiftUI

struct UserProfileView: View {
    @State private var showCalendarView = false
    @StateObject private var viewModel: UserProfileViewModel
    
    init(user: User) {
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(user: user))
    }
    
    private var isFriend: Bool {
        viewModel.user.isFriend ?? false
    }
    
    private var user: User {
        viewModel.user
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.9)]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
                .overlay(
                    ScrollView {
                        VStack(alignment: .leading) {
                            profileHeader
                            if isFriend {
                                friendDetails
                                UserContentListView(user: user)
                                    .padding(.horizontal)
                            } else {
                                Text ("This user is not your friend")
                            }
                        }
                        .padding(.leading)
                    }
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
                )
        }
        .onAppear(perform: viewModel.loadUserData)
        .sheet(isPresented: $showCalendarView) {
            CalendarView()
        }
    }
    
    private var profileHeader: some View {
        HStack {
            CircularProfileImageView(user: user, size: .xLarge)
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
            VStack(alignment: .leading) {
                if let fullName = user.fullName {
                    Text(fullName)
                        .font(.title)
                        .fontWeight(.bold)
                }
                Text("@\(user.username)")
                    .font(.body)
            }
            Spacer()
            if isFriend {
                Button(action: { showCalendarView = true }) {
                    Image(systemName: "calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color.theme.primaryText)
                }
            }
        }
        .padding(.trailing)
    }
    
    private var friendDetails: some View {
        VStack(alignment: .leading, spacing: 5) {
            goalDetail("Goals completed:", detail: "5 goals")
            goalDetail("Longest streak:", detail: "Go Gym - Week 10")
            goalDetail("Live Goals:", detail: "10 Goals")
        }
        .padding(.top)
    }
    
    private func goalDetail(_ title: String, detail: String) -> some View {
        HStack {
            Text(title)
                .font(.title2)
                .padding(.top, 5)
            Text(detail)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 5)
        }
    }
}


//#Preview {
//    UserProfile()
//}
