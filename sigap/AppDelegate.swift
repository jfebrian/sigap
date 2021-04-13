//
//  AppDelegate.swift
//  sigap
//
//  Created by Rony Fhebrian on 31/03/21.
//

import UIKit
import UserNotifications
import CloudKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
            if error != nil {
                print("error: \(error!.localizedDescription)")
            } else if authorized {
              DispatchQueue.main.async(execute: {
                application.registerForRemoteNotifications()
              })
            }
        })
        
        
        return true
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let areaInfoID = UserDefaults.standard.value(forKey: "areaInfoID") as? String
        guard let area = areaInfoID else { return }
        let record = CKRecord(recordType: "Areas", recordID: CKRecord.ID(recordName: area))
        let reference = CKRecord.Reference(recordID: record.recordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "area == %@", reference)
        let subscription = CKQuerySubscription(recordType: "Announcements", predicate: predicate, options: .firesOnRecordCreation)
        
        let info = CKSubscription.NotificationInfo()
        
        info.titleLocalizationKey = "%1$@"
        info.titleLocalizationArgs = ["title"]
        
        info.alertLocalizationKey = "%1$@"
        info.alertLocalizationArgs = ["content"]
        
        info.shouldBadge = true
        info.soundName = "default"
        
        subscription.notificationInfo = info
        
        CKContainer.default().publicCloudDatabase.save(subscription, completionHandler: { subscription, error in
            if error != nil {
                print("error: \(error!.localizedDescription)")
            }
        })
        
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        return completionHandler([.banner, .badge, .sound])
      }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse, withCompletionHandler
        completionHandler: @escaping () -> Void) {

        print(response.notification.request.content.userInfo)

        return completionHandler()
    }
}
