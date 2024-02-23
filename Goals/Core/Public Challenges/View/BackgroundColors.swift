//
//  BackgroundColors.swift
//  Goals
//
//  Created by Jeremy Daines on 22/02/2024.
//

import SwiftUI

struct DynamicSkyBackgroundView: View {
    @State private var gradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [.black, .blue]), startPoint: .top, endPoint: .bottom)
    var simulatedTime: Date?
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        Rectangle()
            .fill(gradient)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                updateGradient()
            }
            .onReceive(timer) { _ in
                // Only update based on the timer if we're not simulating a time
                if simulatedTime == nil {
                    updateGradient()
                }
            }
    }

    func updateGradient() {
        let currentTime = simulatedTime ?? Date() // Use the simulated time if provided
        let hour = Calendar.current.component(.hour, from: currentTime)
        let gradientColors: [Color]

        switch hour {
        case 4..<6: // Pre-dawn
            gradientColors = [.black, .purple, .orange]
        case 6..<8: // Sunrise
            gradientColors = [.orange, .blue, .yellow]
        case 8..<18: // Daytime
            gradientColors = [.blue, .white, .blue]
        case 18..<20: // Sunset
            gradientColors = [.orange, .pink, .purple]
        case 20..<22: // Dusk
            gradientColors = [.purple, .black]
        default: // Night
            gradientColors = [.black, .midnightBlue]
        }

        gradient = LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom)
    }
}

// Assuming `midnightBlue` is a custom color you might want to add for night
extension Color {
    static let midnightBlue = Color(red: 25 / 255, green: 25 / 255, blue: 112 / 255)
}

struct DynamicSkyBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            DynamicSkyBackgroundView(simulatedTime: Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date()))
//                .previewDisplayName("Pre-Dawn")
            
//            DynamicSkyBackgroundView(simulatedTime: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()))
//                .previewDisplayName("Sunrise")
//            
//            DynamicSkyBackgroundView(simulatedTime: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()))
//                .previewDisplayName("Midday")
//            
//            DynamicSkyBackgroundView(simulatedTime: Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()))
//                .previewDisplayName("Sunset")
//            
            DynamicSkyBackgroundView(simulatedTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()))
                .previewDisplayName("Night")
        }
    }
}

