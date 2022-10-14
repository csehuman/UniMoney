//
//  AppDelegate.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/06.
//

import UIKit
import UserNotifications
import RealmSwift

let initialLaunchKey = "initialLaunchKey"

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let config = Realm.Configuration(schemaVersion: 3)
        Realm.Configuration.defaultConfiguration = config
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
            if granted {
                UNUserNotificationCenter.current().delegate = self
            }
            
            print("granted \(granted)")
        }
        
        if !UserDefaults.standard.bool(forKey: initialLaunchKey) {
            DataPopulation.shared.setUpCategories()
            DataPopulation.shared.setUpPaymentMethods()

            // print("Initial Launch")
            // print(Realm.Configuration.defaultConfiguration.fileURL!)
            
            let content = UNMutableNotificationContent()
            content.title = "오늘의 가계부 작성을 완료하셨나요?"
            content.body = "유니머니로 오늘의 가계부를 작성해보세요."
            
            let calendar = Calendar.current
            
            var dateComponents = DateComponents()
            dateComponents.calendar = calendar
            dateComponents.hour = 21
            dateComponents.minute = 00
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: "everyNightNoti", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("ERROR \(String(describing: error.localizedDescription))")
                }
            }
            
            UserDefaults.standard.set(true, forKey: "notiSet")
            UserDefaults.standard.set(true, forKey: initialLaunchKey)
        }
        
        if !UserDefaults.standard.bool(forKey: "notiSet") {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            print("Removed")
        }
        
        return true
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
    
}
