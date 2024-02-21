//
//  ActivityFilterViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 21/02/2024.
//

import Foundation

enum ActivityFilterViewModel: Int, CaseIterable, Identifiable, Codable {
    case all
    case replies

    var title: String {
        switch self {
        case .all: return "All"
        case .replies: return "Replies"
        }
    }
    
    var id: Int { return self.rawValue }
}
