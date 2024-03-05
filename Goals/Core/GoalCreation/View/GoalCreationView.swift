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
    @State private var showingPartnerSearch = false
    
    var weeksToAchieveGoal: Int {
        return Int(ceil(7.0 / viewModel.frequency))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.9)]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea()
                
                ScrollView {
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
                                    .foregroundColor(Color.theme.primaryText)
                                    .onChange(of: viewModel.title) { newValue in
                                        if newValue.count > 20 {
                                            viewModel.title = String(newValue.prefix(20))
                                        }
                                    }
                            }
                            
                            HStack {
                                Text("Partner:")
                                    .fontWeight(.bold)
                                
                                Button(action: {
                                    showingPartnerSearch.toggle()
                                }, label: {
                                    Text(viewModel.partnerUID.isEmpty ? "Select partner..." : "@\(viewModel.partnerUsername)")
                                        .padding(5)
                                })
                                
                                Spacer()
                                
                            }
                            
                            HStack {
                                Text("Frequency:")
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Slider(value: $viewModel.frequency, in: 2...7, step: 1)
                                    .padding(5)
                                Text("\(Int(viewModel.frequency))x a week")
                            }
                            
                            HStack {
                                Text("Description:")
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                TextField("Explain your goal...", text: $viewModel.description)
                                    .padding(5)
                                    .foregroundColor(Color.theme.primaryText)
                                    .onChange(of: viewModel.description) { newValue in
                                        if newValue.count > 100 {
                                            viewModel.title = String(newValue.prefix(100))
                                        }
                                    }
                            }
                            
                            VStack (alignment: .leading, spacing: 15){
                                Text("Tier 1: Achieve your goal 7 times")
                                    .fontWeight(.bold)
                                Text("It will take \(weeksToAchieveGoal) weeks to achieve the goal 7 times based on the frequency selected")
                                    .fontWeight(.bold)
                                Text("Your friends will keep you accountable to it.")
                                Text("Please create your goal wisely.")
                            }
                            .padding(.top)
                        }
                        .padding(.horizontal)
                    }
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
                    if !viewModel.title.isEmpty && !viewModel.partnerUID.isEmpty {
                        Button("Create Goal") {
                            Task {
                                viewModel.duration = Double(weeksToAchieveGoal)
                                try await viewModel.uploadGoal()
                                dismiss()
                            }
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.theme.primaryText)
                    }
                }
            }
            //            .onDisappear { tabIndex = 0 }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPartnerSearch) {
                PartnerSearchView(selectedUsername: $viewModel.partnerUsername, partnerUID: $viewModel.partnerUID)
            }
        }
    }
}

//#Preview {
//    GoalCreationView()
//}
