//
//  FriendsTabViewModel.swift
//  Goals
//
//  Created by Work on 31/12/2023.
//

import SwiftUI
import Combine

class FriendsTabViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [User] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
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
}

