//
//  DashboardView.swift
//  Goals
//
//  Created by Jeremy Daines on 06/03/2024.
//


import SwiftUI

struct DashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack{
            LinearGradientView()
                .overlay(
                    VStack(alignment: .leading) {
                        
                        VStack(alignment: .leading) {
                            Text("Rankings")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack{
                                NavigationLink(destination: TierRankingsView()) {
                                    HStack(spacing: 3) {
                                        Text("Tier Rankings")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                    }
                                }
                                
                                //                            Spacer()
                                
                                Text("Evidence Rankings")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.gray)
                                
//                                NavigationLink(destination: RegistrationView().navigationBarBackButtonHidden(true)) {
//                                    HStack(spacing: 3) {
//                                        Text("Evidence Rankings")
//                                            .font(.title2)
//                                            .fontWeight(.bold)
//                                    }
//                                    
//                                }
                            }
                        }
                        .padding(.bottom)
                        
                        VStack(alignment: .leading) {
                            Text("Calendar")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack{
                                NavigationLink(destination: ScheduleView()) {
                                    HStack(spacing: 3) {
                                        Text("CalendarView")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                            
                        }
                        
                    }
                        .navigationTitle("Dashboard")
                        .navigationBarTitleDisplayMode(.inline)
                    
                    
                )
        }
        
    }
}

#Preview {
    DashboardView()
}
