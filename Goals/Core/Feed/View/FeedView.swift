//
//  FeedView.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

//Color(hex: "#BC5216")

import SwiftUI

struct FeedView: View {
    
    @Namespace var animation
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.9)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            .overlay(
                VStack {
                    Picker("", selection: $selectedTab) {
                        Text("My Contracts").tag(0)
                        Text("Friends Contracts").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    TabView(selection: $selectedTab) {
                        ScrollView {
                            contentForYourContracts()
                        }
                        .tag(0)
                        
                        ScrollView {
                            contentForFriendsContracts()
                        }
                        .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            )
        }
    }

    func contentForYourContracts() -> some View {
        VStack {
            
            HStack{
                Text("Today")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 55)
                Spacer()
            }
            
            LazyVStack(spacing: 30){
                ForEach(0 ... 10, id: \.self) { thread in
                    EvidenceViewFeedView()
                }
            }
        }
    }

    func contentForFriendsContracts() -> some View {
        VStack {
            
            HStack{
                Text("Today")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 55)
                Spacer()
            }
            
            LazyVStack(spacing: 30){
                ForEach(0 ... 10, id: \.self) { thread in
                    EvidenceViewFeedView()
                }
            }
        }
    }
}

#Preview {
    FeedView()
}
