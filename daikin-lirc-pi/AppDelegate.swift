//
//  AppDelegate.swift
//  daikin-lirc-pi
//
//  Created by Dang Duong Hung on 13/8/17.
//  Copyright © 2017 Dang Duong Hung. All rights reserved.
//

import UIKit
import Intents
import Firebase
import Bugsnag
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var intentStart: Bool? = nil
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Bugsnag.start(withApiKey: "8b423d692f6d54c0e5378802092be4f5")        
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
            print("Granted: \(granted)")
            print("error: \(String(describing: error))")
        }
        
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let intent = userActivity.interaction?.intent as? INStartWorkoutIntent else {
            guard let intent2 = userActivity.interaction?.intent as?
                INEndWorkoutIntent else {
                    AppDelegate.intentStart = nil
                    print("AppDelegate: Dont know what intent")
                    return false
            }
            print(intent2)
            print("AppDelegate: Stop Workout Intent - TRUE")
            AppDelegate.intentStart = false
            return false
        }
        print("AppDelegate: Start Workout Intent - TRUE")
        print(intent)
        AppDelegate.intentStart = true
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func handleEvent(forRegion region: CLRegion!, didEnter: Bool) {
        let body = didEnter ? "You are reaching home" : "You are leaving home"
        // Show an alert if application is active
//        if UIApplication.shared.applicationState == .active {
//            let message = body
//            window?.rootViewController?.showAlert(withTitle: nil, message: message)
//            return
//        }
        
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "Smart Room", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
            content.sound = UNNotificationSound.default()
            content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber;
            content.categoryIdentifier = "com.am.siri.test"
            
            let trigger2 = UNLocationNotificationTrigger.init(region: region, repeats: false)
            
            let request = UNNotificationRequest.init(identifier: "SmartRoom", content: content, trigger: trigger2)
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
        
    }
        
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if region is CLCircularRegion {
            print("enter \(region.notifyOnEntry), \(region.notifyOnExit)")
            handleEvent(forRegion: region, didEnter: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("exit \(region.notifyOnEntry), \(region.notifyOnExit)")
            handleEvent(forRegion: region, didEnter: false)
        }
    }
}

