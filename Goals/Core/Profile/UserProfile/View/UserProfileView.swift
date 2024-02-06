//
//  UserProfileView.swift
//  Goals
//
//  Created by Jeremy Daines on 06/02/2024.
//

import SwiftUI

struct UserProfileView: View {
    @State private var showCalendarView = false
    @StateObject var viewModel: UserProfileViewModel
    
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: UserProfileViewModel(user: user))
    }
    
    private var isFriend: Bool {
        return viewModel.user.isFriend ?? false
    }
    
    private var user: User {
        return viewModel.user
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.9)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            .overlay(
                ScrollView {
                    VStack(alignment: .leading){
                        HStack{
                            CircularProfileImageView(user: user, size: .xLarge)
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            
                            VStack(alignment: .leading){
                                
                                if (user.fullName) != nil{
                                    Text(user.fullName ?? "")
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                                
                                Text("@\(user.username)")
                                    .font(.body)
                            }
                            
                            Spacer()
                            
                            if isFriend {
                                
                                Button(action: {
                                    showCalendarView = true
                                },
                                       label: {
                                    Image(systemName: "calendar")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(Color.theme.primaryText)
                                })
                                
                            }
                        }
                        .padding(.trailing)
                        
                        if isFriend {
                            VStack(alignment: .leading, spacing: 5) {
                                
                                HStack {
                                    Text("Goals completed:")
                                        .font(.title2)
                                        .padding(.top, 5)
                                    
                                    Text("5 goals")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.top, 5)
                                }
                                
                                HStack {
                                    Text("Longest streak:")
                                        .font(.title2)
                                        .padding(.top, 5)
                                    
                                    Text("Go Gym - Week 10")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.top, 5)
                                }
                                
                                HStack {
                                    Text("Live Goals:")
                                        .font(.title2)
                                        .padding(.top, 5)
                                    
                                    Text("10 Goals")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.top, 5)
                                }
                                
                            }
                            .padding(.top)
                            
                            UserContentListView(
                                user: user
                            )
                            .padding(.horizontal)
                            
                        }
                    }
                    .padding(.leading)
                }
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
            )
        }
        .onAppear {
            viewModel.loadUserData()
        }
        .sheet(isPresented: $showCalendarView) {
            CalendarView()
        }
    }
}


//#Preview {
//    UserProfile()
//}
