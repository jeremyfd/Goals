//
//  UserCell.swift
//  Goals
//
//  Created by Work on 11/01/2024.
//

import SwiftUI

struct UserCell: View {
    @ObservedObject var viewModel: UserCellViewModel
    
    private var isFriend: Bool {
        return viewModel.user.isFriend ?? false
    }

    private var isFriendRequestReceived: Bool {
        return viewModel.user.isFriendRequestReceived ?? false
    }

    private var isFriendRequestSent: Bool {
        return viewModel.user.isFriendRequestSent ?? false
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12) {
                CircularProfileImageView(user: viewModel.user, size: .small)
                
                VStack(alignment: .leading) {
                    Text(viewModel.user.username)
                        .bold()
                    
                    Text(viewModel.user.fullName ?? "")
                }
                .font(.footnote)
                
                Spacer()
                
                if !viewModel.user.isCurrentUser {
                    if isFriendRequestReceived {
                        Button(action: {
                            viewModel.acceptFriendRequest()
                        }) {
                            Text("Accept")
                        }
                        Button(action: {
                            viewModel.rejectFriendRequest()
                        }) {
                            Text("Reject")
                        }
                    } else if isFriendRequestSent {
                        Button(action: {
                            viewModel.unsendFriendRequest()
                        }) {
                            Text("Unsend Request")
                        }
                    } else if isFriend {
                        Button(action: {
                            viewModel.removeFriend()
                        }) {
                            Text("Delete")
                        }
                    } else {
                        Button(action: {
                            viewModel.sendFriendRequest()
                        }) {
                            Text("Add")
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
        }
        .padding(.vertical, 4)
        .foregroundColor(Color.theme.primaryText)
    }
    
}

struct UserCell_Previews: PreviewProvider {
    static var previews: some View {
        UserCell(viewModel: UserCellViewModel(user: dev.user))
    }
}
