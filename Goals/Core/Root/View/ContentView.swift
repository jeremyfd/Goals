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
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.userSession == nil || !viewModel.isUserProfileComplete {
                FirstPageView()
            } else {
                GoalsTabView()
            }
        }
    }
}


#Preview {
    ContentView()
}
