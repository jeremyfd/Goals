//
//  CycleService.swift
//  Goals
//
//  Created by Jeremy Daines on 01/03/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct CycleService {
    
    static func uploadCycle(_ cycle: Cycle) async throws -> String {
        // Create a new cycle document in Firestore
        let ref = try await FirestoreConstants.CyclesCollection.addDocument(from: cycle)
        return ref.documentID
    }
    
    static func fetchCycles(forGoalId goalId: String) async throws -> [Cycle] {
        // Fetch all cycles associated with a specific goalID
        let querySnapshot = try await FirestoreConstants.CyclesCollection.whereField("goalID", isEqualTo: goalId).getDocuments()
        
        let cycles: [Cycle] = querySnapshot.documents.compactMap { document -> Cycle? in
            try? document.data(as: Cycle.self)
        }
        return cycles
    }
    
    static func deleteCycle(cycleId: String) async throws {
        // Simply delete the cycle document from Firestore
        try await FirestoreConstants.CyclesCollection.document(cycleId).delete()
    }
}
