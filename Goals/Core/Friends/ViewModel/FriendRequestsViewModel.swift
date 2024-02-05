//
//  FriendRequestsViewModel.swift
//  Goals
//
//  Created by Work on 14/01/2024.
//

import SwiftUI
import Firebase

class FriendRequestsViewModel: ObservableObject {
    @Published var receivedRequests: [User] = []

    init() {
        fetchReceivedFriendRequests()
    }

    func fetchReceivedFriendRequests() {
        Task {
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            let snapshot = try await FirestoreConstants
                .FriendRequestsCollection
                .document(currentUid)
                .collection("received-requests")
                .getDocuments()

            let users = try await withThrowingTaskGroup(of: User?.self, body: { group in
                var tempUsers: [User] = []
                for document in snapshot.documents {
                    group.addTask {
                        try? await UserService.fetchUser(withUid: document.documentID)
                    }
                }
                for try await user in group {
                    if let user = user {
                        tempUsers.append(user)
                    }
                }
                return tempUsers
            })

            // Dispatch to main thread
            DispatchQueue.main.async {
                self.receivedRequests = users
            }
        }
    }

}
