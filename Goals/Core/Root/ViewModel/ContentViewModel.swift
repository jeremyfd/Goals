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
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        AuthService.shared.$userSession
            .sink { [weak self] session in
                self?.userSession = session
                if let userID = session?.uid {
                    // Fetch the user data whenever the session updates
                    Task { [weak self] in
                        await self?.fetchUserData(userID: userID)
                    }
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
