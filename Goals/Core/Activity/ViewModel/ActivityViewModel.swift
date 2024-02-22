//
//  ActivityViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 21/02/2024.
//

import SwiftUI

@MainActor
class ActivityViewModel: ObservableObject {
    @Published var notifications = [Activity]()
    @Published var isLoading = false
    
    @Published var selectedFilter: ActivityFilterViewModel = .all {
        didSet {
            switch selectedFilter {
            case .all:
                self.notifications = temp
            case .goals:
                temp = notifications
                self.notifications = notifications.filter({ $0.type == .friendGoal || $0.type == .partnerGoal })
            }
        }
    }
    
    private var temp = [Activity]()
    
    init() {
        Task { try await updateNotifications() }
    }
    
    private func fetchNotificationData() async throws {
        self.isLoading = true
        self.notifications = try await ActivityService.fetchUserActivity()
        self.isLoading = false
    }
    
    private func updateNotifications() async throws {
        try await fetchNotificationData()
        
        await withThrowingTaskGroup(of: Void.self, body: { group in
            for notification in notifications {
                group.addTask { try await self.updateNotificationMetadata(notification: notification) }
            }
        })
    }
    
    private func updateNotificationMetadata(notification: Activity) async throws {
        guard let indexOfNotification = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        
        async let notificationUser = try await UserService.fetchUser(withUid: notification.senderUid)
        var user = try await notificationUser
        
        if notification.type == .friend {
            async let isFriend = await UserService.checkIfUserIsFriendWithUid(notification.senderUid)
            user.isFriend = await isFriend
        }
        
        self.notifications[indexOfNotification].user = user
        
        if let goalId = notification.goalId {
            async let goalSnapshot = await FirestoreConstants.GoalsCollection.document(goalId).getDocument()
            self.notifications[indexOfNotification].goal = try? await goalSnapshot.data(as: Goal.self)
        }
    }
}
