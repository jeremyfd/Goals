//
//  CurrentUserProfileViewModel.swift
//  Goals
//
//  Created by Work on 18/01/2024.
//

import Foundation
import Combine

class CurrentUserProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers(){
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.currentUser = user
//            print ("DEBUG: User in view model from combine is \(user)")
        }.store(in: &cancellables)
    }
}
