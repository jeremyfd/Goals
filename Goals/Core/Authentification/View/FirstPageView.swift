//
//  FirstPageView.swift
//  Goals
//
//  Created by Jeremy Daines on 06/03/2024.
//

import SwiftUI

struct FirstPageView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack{
            LinearGradientView()
                .overlay(
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
//                            HStack {
//                                Text("Welcome to")
//                                    .font(.title)
//                                    .fontWeight(.bold)
//                                Spacer()
//                            }
                            HStack {
                                Text("Phylax")
                                    .font(.system(size: 50))
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading) {
                                Text("From Ancient Greek φύλαξ (phúlax):")
                                    .font(.title3)
                                    .italic()
                                Text("Watcher, guard, sentinel, guardian, keeper, protector")
                                    .font(.title3)
                                    .italic()
                            }
                            .padding(.bottom)
                            
                            VStack(alignment: .leading) {
                                Text("Principles:")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 5)
                                Text("1. Create a Goal")
                                    .font(.title2)
                                Text("2. Add a Phylax to your Goal")
                                    .font(.title2)
                                Text("3. Crush your Goals")
                                    .font(.title2)
                            }
                            .padding(.bottom)
                            
                            VStack(alignment: .leading) {
                                Text("Sprints of 7 days:")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 5)

                                Text("Tier 1: Completed 7 times")
                                    .font(.title2)
                                Text("Tier 2: Completed 14 times")
                                    .font(.title2)
                                Text("Tier 3: Completed 21 times")
                                    .font(.title2)
                                Text("etc...")
                                    .font(.title2)
                            }
                            .padding(.bottom)
                            
                            Spacer()
                            
                            HStack(alignment: .center){
                                Spacer()
                                VStack {
                                    NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true)) {
                                        HStack(spacing: 3) {
                                            Text("Log In")
                                                .font(.title2)
                                                .fontWeight(.bold)
//                                                .padding(.vertical, 10)
                                                .padding(.horizontal)
                                        }
                                        .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                                        .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                                        .background(colorScheme == .light ? Color.black : Color.white)
                                        .cornerRadius(30)
                                    }
                                    
                                    NavigationLink(destination: RegistrationView().navigationBarBackButtonHidden(true)) {
                                        HStack(spacing: 3) {
                                            Text("Sign Up")
                                                .font(.title2)
                                                .fontWeight(.bold)
//                                                .padding(.vertical, 10)
                                                .padding(.horizontal)
                                        }
                                        .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                                        .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                                        .background(colorScheme == .light ? Color.gray : Color.white)
                                        .cornerRadius(30)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding()
                            
                        }
                            
                        
                        Spacer()
                    }
                    .padding()
                    .padding(.horizontal)
                )
        }
    }
}

#Preview {
    FirstPageView()
}
