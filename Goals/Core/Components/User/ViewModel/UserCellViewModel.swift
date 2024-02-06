//
//  UserCellViewModel.swift
//  Goals
//
//  Created by Work on 14/01/2024.
//

import SwiftUI

@MainActor
class UserCellViewModel: ObservableObject {
    @Published var user: User
    @Published var isLoading = true

    private var userService: UserService
    
    init(user: User, userService:UserService = .shared) {
        self.user = user
        self.userService = userService
        fetchFriendshipStatus()
    }
    
    // Fetch the current state of the friendship
    func fetchFriendshipStatus() {
        isLoading = true // Set to true when fetching starts
        Task {
            do {
                let isFriend = await UserService.checkIfUserIsFriendWithUid(user.id)
                let isFriendRequestSent = try await UserService.checkIfRequestSent(toUid: user.id)
                // Assuming a method to check if a friend request is received
                let isFriendRequestReceived = try await UserService.checkIfRequestReceived(fromUid: user.id)
                
                DispatchQueue.main.async {
                    print("DEBUG: Fetch Friendship Status - isFriend: \(isFriend), isFriendRequestSent: \(isFriendRequestSent), isFriendRequestReceived: \(isFriendRequestReceived)")
                    self.user.isFriend = isFriend
                    self.user.isFriendRequestSent = isFriendRequestSent
                    self.user.isFriendRequestReceived = isFriendRequestReceived
                    self.isLoading = false // Set to false when fetching ends
                }
            } catch {
                print("Error fetching friendship status: \(error)")
            }
        }
    }
    
    func acceptFriendRequest() {
        Task {
            do {
                if user.isFriendRequestReceived ?? false {
                    try await userService.acceptFriendRequest(fromUid: user.id)
                    self.user.isFriend = true
                    fetchFriendshipStatus() // Refresh the friendship status
                }
            } catch {
                print("Error accepting friend request: \(error)")
            }
        }
    }
    
    func unsendFriendRequest() {
        Task {
            do {
                if user.isFriendRequestSent ?? false {
                    try await userService.unsendFriendRequest(toUid: user.id)
                    self.user.isFriendRequestSent = false
                    fetchFriendshipStatus() // Refresh the friendship status
                }
            } catch {
                print("Error accepting friend request: \(error)")
            }
        }
    }
    
    func removeFriend() {
        Task {
            do {
                if user.isFriend ?? false {
                    try await userService.removeFriend(uid: user.id)
                    self.user.isFriend = false
                    fetchFriendshipStatus() // Refresh the friendship status
                }
            } catch {
                print("Error accepting friend request: \(error)")
            }
        }
    }
    
    func sendFriendRequest() {
        Task {
            do {
                try await userService.sendFriendRequest(toUid: user.id)
                self.user.isFriendRequestSent = true
                fetchFriendshipStatus() // Refresh the friendship status
            } catch {
                print("Error accepting friend request: \(error)")
            }
        }
    }
    
    
    
    // Additional methods for other actions like rejecting a friend request
    func rejectFriendRequest() {
        Task {
            do {
                if user.isFriendRequestReceived ?? false {
                    try await userService.rejectFriendRequest(fromUid: user.id)
                    self.user.isFriendRequestReceived = false
                    fetchFriendshipStatus() // Refresh the friendship status
                }
            } catch {
                print("Error rejecting friend request: \(error)")
            }
        }
    }
}
