//
//  AgendaView.swift
//  Goals
//
//  Created by Jeremy Daines on 26/02/2024.
//

//import SwiftUI
//
//struct AgendaView: View {
//    @ObservedObject var viewModel = AgendaViewModel()
//
//    var body: some View {
//        List {
//            // Displaying steps by date
//            ForEach(viewModel.stepsByDate.keys.sorted(by: >), id: \.self) { date in
//                Section(header: Text("\(date, style: .date)")) {
//                    ForEach(viewModel.stepsByDate[date, default: []].map({ StepGoalTuple(step: $0.0, goal: $0.1) }), id: \.id) { stepGoalTuple in
//                        VStack(alignment: .leading) {
//                            Text(stepGoalTuple.goal.title)
//                                .font(.headline)
////                            Text("Step due by: \(stepGoalTuple.step.deadline, style: .time)")
////                                .font(.subheadline)
//                            Text("Week \(stepGoalTuple.step.weekNumber), Day \(stepGoalTuple.step.dayNumber)")
//                                .font(.subheadline)
//                        }
//                    }
//                }
//            }
//        }
//        .onAppear {
//            viewModel.fetchDataForYourFriendsContracts()
//        }
//    }
//}

import SwiftUI

struct AgendaView: View {
    @ObservedObject var viewModel = AgendaViewModel()

    var body: some View {
        List {
            // Get today's date
            let today = Date()
            let calendar = Calendar.current
            // Filter to include only today's date
            let stepsForToday = viewModel.stepsByDate.filter { date, _ in
                calendar.isDate(date, inSameDayAs: today)
            }
            
            ForEach(stepsForToday.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text("\(date, style: .date)")) {
                    ForEach(stepsForToday[date, default: []]
                        .map({ StepGoalTuple(step: $0.0, goal: $0.1) }), id: \.id) { stepGoalTuple in
                        VStack(alignment: .leading) {
                            Text(stepGoalTuple.goal.title)
                                .font(.headline)
                            // Assuming deadline is a Date object and you only want to show future deadlines or deadlines due today.
                            // Uncomment and adjust if needed.
                            // if calendar.isDate(stepGoalTuple.step.deadline, inSameDayAs: today) {
                                Text("Week \(stepGoalTuple.step.weekNumber), Day \(stepGoalTuple.step.dayNumber)")
                                    .font(.subheadline)
                            // }
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
