//
//  UserReactionsView.swift
//  Goals
//
//  Created by Jeremy Daines on 02/03/2024.
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
//    }
//
//}
