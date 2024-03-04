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
        print("DEBUG: Configuring Firebase...")
        FirebaseApp.configure()
        
        print("DEBUG: Setting UNUserNotificationCenter and Messaging delegates...")
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // Request notification authorization
        print("DEBUG: Requesting notification authorization...")
        requestNotificationAuthorization(application)
        
        print("DEBUG: Registering for remote notifications...")
        application.registerForRemoteNotifications()
        
        if let token = Messaging.messaging().fcmToken {
                print("FCM token immediately after launch: \(token)")
            }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let apnsToken = tokenParts.joined()
        print("APNS device token: \(apnsToken)")
        Messaging.messaging().apnsToken = deviceToken
    }

    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("DEBUG: Received remote notification.")
        if Auth.auth().canHandleNotification(userInfo) {
            print("DEBUG: Notification handled by Firebase Auth.")
            return
        }
        // Here you can handle other types of remote notifications
        print("DEBUG: Handling custom remote notification.")
    }
    
    private func requestNotificationAuthorization(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("DEBUG: Request notification authorization failed with error: \(error)")
            }
            print("Permission granted: \(granted)")
            guard granted else { return }
            DispatchQueue.main.async {
                print("DEBUG: Permission granted, registering for remote notifications...")
                application.registerForRemoteNotifications()
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        if let fcmToken = fcmToken {
            print("DEBUG: Received FCM token: \(fcmToken)")
        } else {
            print("DEBUG: FCM token is nil.")
        }
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary, send the token to your application server.
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("DEBUG: Failed to register for remote notifications with error: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("DEBUG: Notification will be presented.")
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
