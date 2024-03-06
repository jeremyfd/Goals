//
//  GoalsApp.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

import SwiftUI
import FirebaseCore
import Firebase
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        print("DEBUG: Configuring Firebase...")
        FirebaseApp.configure()
        
//        print("DEBUG: Setting UNUserNotificationCenter and Messaging delegates...")
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // Request notification authorization
//        print("DEBUG: Requesting notification authorization...")
        requestNotificationAuthorization(application)
        
//        print("DEBUG: Registering for remote notifications...")
        application.registerForRemoteNotifications()
        
        if let token = Messaging.messaging().fcmToken {
//                print("DEBUG: FCM token immediately after launch: \(token)")
            }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let apnsToken = tokenParts.joined()
//        print("APNS device token: \(apnsToken)")
        Messaging.messaging().apnsToken = deviceToken
    }

    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        print("DEBUG: Received remote notification.")
        if Auth.auth().canHandleNotification(userInfo) {
//            print("DEBUG: Notification handled by Firebase Auth.")
            return
        }
        // Here you can handle other types of remote notifications
//        print("DEBUG: Handling custom remote notification.")
    }
    
    private func requestNotificationAuthorization(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
//                print("DEBUG: Request notification authorization failed with error: \(error)")
            }
//            print("Permission granted: \(granted)")
            guard granted else { return }
            DispatchQueue.main.async {
//                print("DEBUG: Permission granted, registering for remote notifications...")
                application.registerForRemoteNotifications()
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken, let userId = Auth.auth().currentUser?.uid, !userId.isEmpty else {
//            print("Firebase registration token received, but no user is logged in to associate it with.")
            // Optionally, you can store the fcmToken and associate it with the user upon login.
            return
        }
        
        let userRef = FirestoreConstants.UserCollection.document(userId)
        userRef.setData(["fcmToken": fcmToken], merge: true) { error in
            if let error = error {
                print("Error updating FCM token in Firestore: \(error.localizedDescription)")
            } else {
//                print("FCM token successfully updated in Firestore for user \(userId)")
            }
        }
    }


    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("DEBUG: Failed to register for remote notifications with error: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        print("DEBUG: Notification will be presented.")
        completionHandler([.alert, .sound, .badge])
    }
}

@main
struct GoalsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
