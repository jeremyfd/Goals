//
//  UserReactionsView.swift
//  Goals
//
//  Created by Jeremy Daines on 02/03/2024.
//

//
//import SwiftUI
//import Firebase
//
//struct UserReactionsView: View {
//    let reactions: [Reaction]
//
//    @State private var userReactions: [String: Int] = [:] // Key: userID, Value: count
//    @State private var users: [String: User] = [:] // Key: userID, Value: User object
//
//    var body: some View {
//        NavigationView {
//            List(sortedUsers(), id: \.key) { userID, _ in
//                if let user = users[userID] {
//                    Text("\(user.username) x\(userReactions[userID, default: 0])")
//                }
//            }
//            .navigationBarTitle("Users Who Reacted", displayMode: .inline)
//        }
//        .onAppear {
//            fetchUsers()
//        }
//    }
//
//    private func fetchUsers() {
//        let group = DispatchGroup()
//        reactions.forEach { reaction in
//            userReactions[reaction.userID, default: 0] += 1
//            if users[reaction.userID] == nil {
//                group.enter()
//                FirebaseFirestoreService.shared.fetchUserByID(userID: reaction.userID) { result in
//                    switch result {
//                    case .success(let user):
//                        users[reaction.userID] = user
//                    case .failure(let error):
//                        print("Failed to fetch user with error: \(error)")
//                    }
//                    group.leave()
//                }
//            }
//        }
//        
//        group.notify(queue: .main) {
//            print("All users fetched")
//        }
//    }
//
//    private func sortedUsers() -> [(key: String, value: Int)] {
//        return userReactions.sorted(by: { $0.value > $1.value })
//    }
//}
