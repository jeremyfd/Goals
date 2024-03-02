//
//  ReactionButtonsView.swift
//  Goals
//
//  Created by Jeremy Daines on 02/03/2024.
//
//
//import SwiftUI
//
//struct ReactionButtonsView: View {
//    @ObservedObject var viewModel: GoalViewModel
//    @State private var isDisabled = false
//
//    var reactions = ["wow!", "almost there!", "never give up!", "you are crushing this!"]
//
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 10) {
//                ForEach(reactions, id: \.self) { reaction in
//                    ReactionButton(viewModel: viewModel, reactionType: reaction, goal: viewModel.goal!, isDisabled: $isDisabled)
//                        .disabled(isDisabled)
//                }
//            }
//            .padding(.top, 10)
//            .padding(.trailing, 10)
//        }
//    }
//}
//
//struct ReactionButton: View {
//    @ObservedObject var viewModel: GoalViewModel
//    let reactionType: String
//    let goal: Goal
//    @Binding var isDisabled: Bool
//    @State private var isShowingUsersList = false
//
//    var body: some View {
//        Button(action: {
//            if viewModel.currentUserID == goal.userID {
//                isShowingUsersList = true
//            } else {
//                viewModel.addReaction(reactionType: reactionType)
//                withAnimation {
//                    isDisabled = true
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3600) {
//                    withAnimation {
//                        isDisabled = false
//                    }
//                }
//            }
//        }) {
//            ZStack(alignment: .topTrailing) {
//                HStack {
//                    Text(reactionType.capitalized)
//                        .padding(.horizontal)
//                        .padding(.vertical, 10)
//                        .background(isDisabled ? Color.gray : Color.blue)
//                        .cornerRadius(10)
//                        .foregroundColor(.white)
//                }
//
//                if viewModel.reactionCounts[reactionType, default: 0] > 0 {
//                    Text("\(viewModel.reactionCounts[reactionType, default: 0])")
//                        .font(.footnote)
//                        .foregroundColor(.white)
//                        .padding(5)
//                        .background(Circle().fill(Color.red))
//                        .offset(x: 10, y: -10)
//                }
//            }
//        }
//        .sheet(isPresented: $isShowingUsersList) {
//            UserReactionsView(reactions: viewModel.goal?.reactions?.filter { $0.reactionType == reactionType } ?? [])
//        }
//    }
//}
