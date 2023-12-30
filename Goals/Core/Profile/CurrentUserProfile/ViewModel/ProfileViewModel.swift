//
//  ProfileViewModel.swift
//  Goals
//
//  Created by Work on 30/12/2023.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscribers()
    }

    private func setupSubscribers() {
        UserService.shared.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
                print("DEBUG: User in view model from combine is \(String(describing: user))")
            }.store(in: &cancellables)
    }
}
