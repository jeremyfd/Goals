//
//  ReactionButtonsView.swift
//  Goals
//
//  Created by Jeremy Daines on 02/03/2024.
//

import SwiftUI

struct ReactionButtonsView: View {
    var goalID: String
    @ObservedObject var viewModel: GoalViewCellViewModel
    @State private var disabledButtons: [String: Bool] = [:]
    
    private let reactions = ["wow!", "almost there!", "never give up!", "you are crushing this!"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(reactions, id: \.self) { reaction in
                    Button(action: {
                        Task {
                            await viewModel.uploadReaction(type: reaction)
                        }
                        withAnimation {
                            disabledButtons[reaction] = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3600) {
                            withAnimation {
                                disabledButtons[reaction] = false
                            }
                        }
                        
                    }) {
                        HStack {
                            Text(reaction)
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                .background(disabledButtons[reaction, default: false] ? Color.gray : Color.blue)
                                .cornerRadius(40)
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(disabledButtons[reaction, default: false])
                }
            }
        }
    }
}
