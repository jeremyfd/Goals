//
//  GoalCreationView.swift
//  Goals
//
//  Created by Work on 28/12/2023.
//

import SwiftUI

struct GoalCreationView: View {
    @StateObject var viewModel = GoalCreationViewModel()
    @Environment(\.dismiss) var dismiss
    @Binding var tabIndex: Int
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.9)]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea()
                
                VStack {
                    Text("Create your Goal")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    VStack{
                        HStack {
                            Text("Name:")
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            TextField("Goal name...", text: $viewModel.title)
                                .padding(5)
                            
                        }
                        HStack {
                            Text("Partner:")
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            TextField("Partner username...", text: $viewModel.partnerUID)
                                .padding(5)
                            
                        }
                        HStack {
                            Text("Frequency:")
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Slider(value: $viewModel.frequency, in: 1...7, step: 1)
                                .padding(5)
                            Text("\(Int(viewModel.frequency))x a week")
                        }
                        
                        VStack (alignment: .leading, spacing: 15){
                            Text("You will not be able to delete this goal and your friends will keep you accountable to it.")
                            Text("Please create your goal wisely.")
                        }
                        .padding(.top)
                    }
                    .padding(.horizontal)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.theme.primaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create Goal") {
                        Task {
                            try await viewModel.uploadGoal()
                            dismiss()
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.theme.primaryText)
                }
            }
            .onDisappear { tabIndex = 0 }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//#Preview {
//    GoalCreationView()
//}
