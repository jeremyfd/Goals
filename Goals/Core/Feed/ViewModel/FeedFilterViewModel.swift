//
//  FeedFilterViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 23/02/2024.
//

import Foundation

enum FeedFilterViewModel: Int, CaseIterable, Identifiable, Codable {
    case all
    case partner

    var title: String {
        switch self {
        case .all: return "All Goals"
        case .partner: return "Partner Goals"
        }
    }
    
    var id: Int { return self.rawValue }
}
