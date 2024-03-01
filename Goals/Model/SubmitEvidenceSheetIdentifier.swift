//
//  SubmitEvidenceSheetIdentifier.swift
//  Goals
//
//  Created by Jeremy Daines on 16/02/2024.
//

import Foundation

struct SubmitEvidenceSheetIdentifier: Identifiable {
    let id: UUID = UUID()
    var goalID: String
    var cycleID: String
    var stepID: String
    var weekNumber: Int
    var dayNumber: Int
}
