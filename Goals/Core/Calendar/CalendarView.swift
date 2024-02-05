//
//  CalendarView.swift
//  Goals
//
//  Created by Work on 29/12/2023.
//

import SwiftUI

import SwiftUI

struct CalendarView: View {
    
    let monthLabels = ["Jan", "", "", "", "Feb", "", "", "", "Mar", "", "", "", "", "Apr", "", "", "", "May", "", "", "", "Jun", "", "", "", "", "Jul", "", "", "", "Aug", "", "", "", "Sep", "", "", "", "Oct", "", "", "", "Nov", "", "", "", "Dec", "", "", ""]
    let goalData: [Int] = [3, 1, 7] + Array(repeating: 0, count: 362)
    var maxGoals: Int {
        goalData.max() ?? 0
    }
    
    var body: some View {
        Text("2024")
            .font(.title)
            .fontWeight(.bold)
            .padding(.top)
        
        Text("Make everyday count")
            .font(.subheadline)
            .fontWeight(.bold)
            .padding(.bottom)
        
        HStack{
            Spacer()
            
            Text("Mon")
                .padding(.trailing, 42)
                .fontWeight(.bold)
            Text("Wed")
                .padding(.trailing, 50)
                .fontWeight(.bold)
            Text("Fri")
                .padding(.trailing, 50)
                .fontWeight(.bold)
            Text("Sun")
                .padding(.trailing, 20)
                .fontWeight(.bold)
        }
        .padding(.bottom, -2)
        
        ScrollView {
            ForEach(0..<52, id: \.self) { week in
                ContributionRow(weekNumber: week, label: week < monthLabels.count ? monthLabels[week] : "", goalData: goalData, maxGoals: maxGoals)
            }
        }
    }
}

struct ContributionRow: View {
    var weekNumber: Int
    var label: String
    var goalData: [Int]
    var maxGoals: Int

    var body: some View {
        HStack {
            Spacer()

            if !label.isEmpty {
                Text(label)
                    .padding(.horizontal)
                    .fontWeight(.bold)
            }
            ForEach(0..<7, id: \.self) { day in
                let cellIndex = weekNumber * 7 + day
                let goals = cellIndex < goalData.count ? goalData[cellIndex] : 0
                ContributionCell(id: "\(weekNumber)-\(day)", goals: goals, maxGoals: maxGoals)
            }
        }
        .padding(.trailing)
        .padding(.bottom, 5)
    }
}

struct ContributionCell: View {
    var id: String
    var goals: Int
    var maxGoals: Int

    var body: some View {
        Rectangle()
            .fill(goalsColor(for: goals, maxGoals: maxGoals))
            .frame(width: 35, height: 25)
            .cornerRadius(20)
            .overlay(
                // Apply a light gray border only if the goals are 0
                goals == 0 ? RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1) : nil
            )
            .onTapGesture {
                print("Cell tapped: \(id) with goals: \(goals)")
            }
    }

    // Function to determine the cell color based on the number of goals
    private func goalsColor(for count: Int, maxGoals: Int) -> Color {
        if count == 0 {
            return Color.white
        } else {
            let intensity = maxGoals > 0 ? Double(count) / Double(maxGoals) : 0
            return Color.orange.opacity(0.5 + 0.5 * intensity) // Adjust the opacity based on intensity
        }
    }
}

#Preview {
    CalendarView()
}
