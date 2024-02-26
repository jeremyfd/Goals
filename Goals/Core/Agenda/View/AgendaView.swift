//
//  AgendaView.swift
//  Goals
//
//  Created by Jeremy Daines on 26/02/2024.
//
import SwiftUI

struct AgendaView: View {
    @ObservedObject var viewModel = AgendaViewModel()

    var body: some View {
        List {
            // Displaying steps by date
            ForEach(viewModel.stepsByDate.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text("\(date, style: .date)")) {
                    ForEach(viewModel.stepsByDate[date, default: []].map({ StepGoalTuple(step: $0.0, goal: $0.1) }), id: \.id) { stepGoalTuple in
                        VStack(alignment: .leading) {
                            Text(stepGoalTuple.goal.title)
                                .font(.headline)
                            Text("Step due by: \(stepGoalTuple.step.deadline, style: .time)")
                                .font(.subheadline)
                            // Add more details about the step as needed
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchDataForYourFriendsContracts()
        }
    }
}

// Define a new struct to encapsulate a Step and a Goal that conforms to Identifiable
struct StepGoalTuple: Identifiable {
    let step: Step
    let goal: Goal
    var id: UUID { step.id }
}
