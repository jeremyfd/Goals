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
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.9)]),
                    startPoint: .bottom,
                    endPoint: .top
                )
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
                        
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.searchResults, id: \.id) { user in
                                NavigationLink(value: user) {
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


#Preview {
    PartnerSearchView()
}
