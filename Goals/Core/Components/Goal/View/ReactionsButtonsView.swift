//
//  ReactionButtonsView.swift
//  Goals
//
//  Created by Jeremy Daines on 02/03/2024.
//

import SwiftUI

struct ReactionButtonsView: View {
    var goalID: String
    var ownerUid: String
    @ObservedObject var viewModel: GoalViewCellViewModel
    @State private var disabledButtons: [String: Bool] = [:]
    
    private let reactions = ["Wow!", "Almost there!", "Don't give up!", "You are crushing this!"]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(reactions, id: \.self) { reactionType in
                        
                        Button(action: {
                            Task {
                                await viewModel.uploadReaction(type: reactionType)
                                await viewModel.fetchReactionsForGoal() // Ensure reactions and usernames are up-to-date
                            }
                            withAnimation {
                                disabledButtons[reactionType] = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3600) {
                                withAnimation {
                                    disabledButtons[reactionType] = false
                                }
                            }
                            
                        }) {
                            VStack {
                                Text(reactionType)
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                    .background(disabledButtons[reactionType, default: false] ? Color.gray : Color.blue)
                                    .cornerRadius(40)
                                    .foregroundColor(.white)
                                
                            }
                            .overlay(
                                // Overlay with the number of reactions
                                Text("\((viewModel.reactionCounts[reactionType]?.values.reduce(0, +)) ?? 0)")
                                    .font(.caption)
                                    .padding(5)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10),
                                alignment: .topTrailing
                            )
                            .padding(.top)
                            
                        }
                        .disabled(disabledButtons[reactionType, default: false])
                    }
                }
                
            }
            .onAppear {
                Task {
                    await viewModel.fetchReactionsForGoal()
                }
            }
            
            HStack {
                NavigationLink(destination: AllReactionsDetailView(viewModel: viewModel)) {
                    Text("See who reacted..")
                        .foregroundColor(.blue)
                        .padding()
                }
                Spacer()
            }
            .padding(.top, -10)
        }
    }
}


struct AllReactionsDetailView: View {
    @ObservedObject var viewModel: GoalViewCellViewModel
    
    var body: some View {
        // In AllReactionsDetailView
        List {
            ForEach(viewModel.reactionCounts.keys.sorted(), id: \.self) { reactionType in
                if let userCounts = viewModel.reactionCounts[reactionType], !userCounts.isEmpty {
                    Section(header: Text(reactionType)) {
                        // Sort users by their reaction counts, descending
                        ForEach(userCounts.sorted(by: { $0.value > $1.value }), id: \.key) { username, count in
                            Text("\(username) x\(count)")
                        }
                    }
                }
            }
        }
        .navigationTitle("Reactions")

    }
}
