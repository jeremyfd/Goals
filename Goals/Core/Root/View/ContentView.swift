//
//  ContentView.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        Group {
            if viewModel.userSession == nil || !viewModel.isUserProfileComplete {
                LoginView()
            } else {
                FeedView()
            }
        }
    }
}

#Preview {
    ContentView()
}
