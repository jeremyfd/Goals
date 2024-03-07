//
//  EvidenceRankingsViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 06/03/2024.
//
//
//import Foundation
//import Combine
//import SwiftUI
//import Firebase
//
//@MainActor
//class EvidenceRankingsViewModel: ObservableObject {
//    @Published var currentUser: User?
//    @Published var goals = [Goal]()
//    @Published var isLoading = false
//    private var cancellables = Set<AnyCancellable>()
//
//    init() {
//        setupSubscribers()
//        fetchDataForYourFriendsContracts() // Automatically fetch all goals on init
//    }
//
//    private func setupSubscribers() {
//        UserService.shared.$currentUser
//            .sink { [weak self] user in
//                self?.currentUser = user
//            }
//            .store(in: &cancellables)
//    }
//
//    func fetchDataForYourFriendsContracts() {
//        guard let uid = currentUser?.id else { return }
//
//        Task {
//            do {
//                let goalIDs = try await GoalService.fetchFriendGoalIDs(uid)
//                var fetchedGoals = [Goal]()
//                for goalID in goalIDs {
//                    var goal = try await GoalService.fetchGoalDetails(goalId: goalID)
//                    // Fetch the user data for this goal.
//                    if let ownerUser = try? await UserService.fetchUser(withUid: goal.ownerUid) {
//                        goal.user = ownerUser
//                    }
//                    fetchedGoals.append(goal)
//                }
//                
//                self.goals = fetchedGoals.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
//            } catch {
//                print("Error fetching goals: \(error)")
//            }
//        }
//    }
//}
