//
//  PartnerSearchView.swift
//  Goals
//
//  Created by Jeremy Daines on 07/02/2024.
//

import SwiftUI

struct PartnerSearchView: View {
    @StateObject private var viewModel = PartnerSearchViewModel()
    @FocusState private var isTextFieldFocused: Bool
    @Binding var selectedUsername: String
    @Binding var partnerUID: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradientView()
                .ignoresSafeArea()
                
                VStack {
                    HStack {
                        TextField("Search for a partner", text: $viewModel.searchText)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($isTextFieldFocused)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        if !viewModel.searchText.isEmpty {
                            Button("Cancel") {
                                viewModel.searchText = ""
                                isTextFieldFocused = false
                            }
                            .padding(.horizontal)
                            .transition(.move(edge: .trailing))
                            .animation(.default, value: viewModel.searchText)
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if viewModel.searchText.isEmpty {
                        
                        ForEach(viewModel.friends, id: \.id) { friend in
                            Button(action: {
                                self.selectedUsername = friend.username
                                self.partnerUID = friend.id
                                dismiss()
                            }) {
                                PartnerAddCell(user: friend)
                            }
                        }
                        
                        Spacer()
                        
                    } else {
                        
                        ScrollView {
                            LazyVStack {
                                ForEach(viewModel.searchResults, id: \.id) { user in
                                    Button(action: {
                                        self.selectedUsername = user.username
                                        self.partnerUID = user.id
                                        dismiss()
                                    }) {
                                        PartnerAddCell(user: user)
                                    }
                                }
                                
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            
        }
        
    }
}


//#Preview {
//    PartnerSearchView()
//}
