//
//  PartnerSearchViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 07/02/2024.
//

import SwiftUI
import Combine
import Firebase

class PartnerSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [User] = []
    @Published var friends: [User] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchCurrentFriends()
        $searchText
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] in self?.searchUsers(with: $0) }
            .store(in: &cancellables)
    }

    private func searchUsers(with query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            DispatchQueue.main.async {
                self.searchResults = []
            }
            return
        }

        Task {
            do {
                let users = try await UserService.fetchUsers()
                DispatchQueue.main.async {
                    self.searchResults = users.filter { $0.username.lowercased().contains(query.lowercased()) }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error searching for users: \(error)")
                }
            }
        }
    }
    
    func fetchCurrentFriends() {
        Task {
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            let snapshot = try await FirestoreConstants
                .FriendsCollection
                .document(currentUid)
                .collection("user-friends")
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
                self.friends = users
            }
        }
    }
}

