//
//  CurrentUserProfileView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI

struct CurrentUserProfileView: View {
    @State private var showCalendarView = false
    @State private var navigateToEditProfile = false
    @StateObject var viewModel = CurrentUserProfileViewModel()
    
    
    private var currentUser: User? {
        return viewModel.currentUser
    }
    
    
    var body: some View {
        NavigationStack {
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
                            CircularProfileImageView(user: currentUser, size: .xLarge)
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            
                            VStack(alignment: .leading){
                                
                                if (currentUser?.fullName) != nil{
                                    Text(currentUser?.fullName ?? "")
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                                
                                Text("@\(currentUser?.username ?? "")")
                                    .font(.body)
                            }
                            
                            Spacer()
                            
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
                            
                            NavigationLink {
                                SettingsView()
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color.theme.primaryText)
                            }
                        }
                        .padding(.trailing)
                        
                        NavigationLink(destination: Group {
                            if let user = currentUser {
                                EditProfileView(user: user)
                            } else {
                                // Provide an alternative view if currentUser is nil
                                Text("User not found")
                            }
                        },
                                       isActive: $navigateToEditProfile) {
                            EmptyView()
                        }
                                       .hidden()
                        
                        
                        Button {
                            navigateToEditProfile = true
                        } label: {
                            HStack{
                                Text("Edit profile")
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(Color.white)
                            .cornerRadius(40)
                        }
                        .padding(.top)
                        
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
                        
                        if let user = currentUser {
                            UserContentListView(user: user)
                            .padding(.horizontal)
                        }
                        
                    }
                    .padding(.leading)
                }
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
            )
        }
        
        .sheet(isPresented: $showCalendarView) {
            CalendarView()
        }
    }
}

struct CurrentUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentUserProfileView()
    }
}

