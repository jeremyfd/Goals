//
//  ContentViewModel.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

import Combine
import FirebaseAuth

class ContentViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isLoading = true // Add this line to track loading state

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        AuthService.shared.$userSession
            .receive(on: DispatchQueue.main) // Ensure updates are received on the main thread
            .sink { [weak self] session in
                guard let self = self else { return } // Safely unwrap self
                self.userSession = session
                self.isLoading = true
                if let userID = session?.uid {
                    Task {
                        await self.fetchUserData(userID: userID)
                        await MainActor.run { // Ensure UI updates are on the main thread
                            self.isLoading = false
                        }
                    }
                } else {
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
    
    var isUserProfileComplete: Bool {
        // Check if current user exists and username is non-nil and not empty
        guard let username = currentUser?.username, !username.isEmpty else {
            return false
        }
        return true
    }
    
    @MainActor
    private func fetchUserData(userID: String) async {
        do {
            let user = try await UserService.fetchUser(withUid: userID)
            self.currentUser = user
        } catch {
            print("Error fetching user: \(error)")
            self.currentUser = nil
        }
    }
}

