//
//  ScheduleView.swift
//  Goals
//
//  Created by Jeremy Daines on 06/03/2024.
//

import SwiftUI

struct ScheduleView: View {
    @StateObject var viewModel = ScheduleViewModel()
    @Namespace var animation
    @State private var sortAscending: Bool = true
    
    private var sortedStepsByDate: [(date: Date, steps: [Step])] {
        Dictionary(grouping: viewModel.goals.flatMap { $0.steps }) { $0.deadline.startOfDay() }
            .sorted { sortAscending ? $0.key < $1.key : $0.key > $1.key }
            .map { ($0.key, $0.value) }
    }
    
    var body: some View {
        ScrollView {
            FeedFilterView(selectedFilter: $viewModel.selectedFilter)
            
            Button(action: {
                sortAscending.toggle()
            }) {
                HStack {
                    Spacer()
                    
                    Text("Sort")
                        .fontWeight(.bold)
                    Image(systemName: "arrow.up.arrow.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                }
                .padding(.trailing)
            }
            
//            ScrollView {
                contentForYourContracts()
//            }
            .refreshable {
                viewModel.fetchDataForYourFriendsContracts()
            }
        }
        .background(LinearGradientView())
        .navigationTitle("Tier Rankings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchDataForYourFriendsContracts()
        }
    }
    
    func contentForYourContracts() -> some View {
        LazyVStack{
            ForEach(sortedStepsByDate, id: \.date) { date, steps in
                Section(header: Text(date, formatter: DateFormatter.shortDate)) {
                    ForEach(steps, id: \.id) { step in
                        if let goalWithSteps = viewModel.goals.first(where: { $0.goal.id == step.goalID }) {
                            VStack(alignment: .leading) {
                                Text("Goal: \(goalWithSteps.goal.title)")
                                Text("Creator: \(goalWithSteps.goal.user?.username ?? "Unknown")")
                                Text("Tier: \(step.tier)")
                            }
                            .padding(.bottom)
                        }
                    }
                }
            }
        }
    }
}

private extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
}

private extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}


#Preview {
    ScheduleView()
}
