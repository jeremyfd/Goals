//
//  FeedView.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

//Color(hex: "#BC5216")


import SwiftUI

//struct FeedView: View {
//    
//    @Namespace var animation
//    @State private var selectedTab: String = "Your Contracts"
//    
//    var body: some View {
//        
//        NavigationStack {
//            LinearGradient(
//                gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.9)]),
//                startPoint: .bottom,
//                endPoint: .top
//            )
//            .ignoresSafeArea()
//            .overlay(
//                ScrollView {
//                    VStack{
//                        HStack{
//                            // Your Contracts tab
//                            Text("My Contracts")
//                                .font(.title3)
//                                .fontWeight(selectedTab == "Your Contracts" ? .bold : .none)
//                                .foregroundColor(selectedTab == "Your Contracts" ? .black : .gray)
//                                .fixedSize(horizontal: true, vertical: false) // Prevent text wrapping
//                                .onTapGesture {
//                                    withAnimation {
//                                        selectedTab = "Your Contracts"
//                                    }
//                                }
//                                .padding(.horizontal)
//                            
//                            
//                            // Friends Contracts tab
//                            Text("Friends Contracts")
//                                .font(.title3)
//                                .fontWeight(selectedTab == "Friends Contracts" ? .bold : .none)
//                                .foregroundColor(selectedTab == "Friends Contracts" ? .black : .gray)
//                                .fixedSize(horizontal: true, vertical: false) // Prevent text wrapping
//                                .onTapGesture {
//                                    withAnimation {
//                                        selectedTab = "Friends Contracts"
//                                    }
//                                }
//                                .padding(.horizontal)
//                        }
//                        .padding(.vertical, 4)
//                        
//                        HStack{
//                            Text("Today")
//                                .font(.title)
//                                .fontWeight(.bold)
//                                .padding(.leading, 55)
//                            Spacer()
//                        }
//                        
//                        LazyVStack(spacing: 30){
//                            ForEach(0 ... 10, id: \.self) { thread in
//                                EvidenceViewFeedView()
//                            }
//                        }
//
//                        Spacer()
//                    }
//                    .navigationTitle("Feed")
//                    .navigationBarTitleDisplayMode(.inline)
//                    
//                }
//            )
//        }
//    }
//}

#Preview {
    FeedView()
}


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
                .navigationTitle("Feed")
                .navigationBarTitleDisplayMode(.inline)
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
