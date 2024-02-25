//
//  Timestamp.swift
//  Goals
//
//  Created by Jeremy Daines on 21/02/2024.
//

import Firebase
import Foundation

extension Timestamp {
    func timestampString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: self.dateValue(), to: Date()) ?? ""
    }
    
    func toDateTimeString() -> String {
        let dateFormatter = DateFormatter()
        // Customize the date format according to your needs
        dateFormatter.dateFormat = "HH:mm dd/MM/yy"
        return dateFormatter.string(from: self.dateValue())
    }

}

//extension Date {
//    // Calculate time remaining until this date
//    func countdownString() -> String {
//        let now = Date()
//        if self > now {
//            let formatter = DateComponentsFormatter()
//            formatter.allowedUnits = [.hour, .minute, .second]
//            formatter.unitsStyle = .positional
//            formatter.zeroFormattingBehavior = [.pad]
//            return formatter.string(from: now, to: self) ?? ""
//        } else {
//            return "Deadline has passed"
//        }
//    }
//}

