//
//  PDYNotificationHandler.swift
//  PushdyCore
//
//  Created by quandt on 10/31/17.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import UIKit
import AudioToolbox
import PushdyCore
import UserNotifications
import UserNotificationsUI

@objc class PDYNotificationHandler: NSObject {
   @objc public typealias CompletionBlock = (_ result: UIBackgroundFetchResult?) -> Void
    
    var fromInActiveState:Bool = false
    var enteredBackground:Bool = true
    var launchedByPush:Bool = false
    
    var pendingPush:[AnyHashable : Any]?
    var needBanner:Bool = false
    var autoDismiss:Bool = true
    
    static let shared: PDYNotificationHandler = {
        let instance = PDYNotificationHandler()
        return instance
    }()
    
    // MARK: - Push helper
    func registerForPushNotifications() {
        let application = UIApplication.shared
        if #available(iOS 10.0, *) {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.delegate = self
            notificationCenter.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted:Bool, error:Error?) in
                if error == nil, granted == true {
                    PDYThread.perform(onUIThread: {
                        application.registerForRemoteNotifications()
                    })
                }
            })
        }
        else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    func checkNotificationEnabling(_ resultBlock : ((Bool)->())? = nil){
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
                switch setttings.authorizationStatus {
                case .authorized:
                    resultBlock?(true)
                case .denied:
                    resultBlock?(false)
                case .notDetermined:
                    resultBlock?(false)
                default:
                    resultBlock?(false)
                }
            }
        } else {
            let enabled = UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert)
            if enabled == true {
                resultBlock?(true)
            } else {
                resultBlock?(false)
            }
        }
    }
    
    // MARK: - Lifecycler
    func handleWhenAppWillResignActive() {
        self.enteredBackground = false
    }
    
    func handleWhenAppDidEnterBackground() {
        self.enteredBackground = true
    }
    
    func handleWhenAppDidBecomeActive() {
        if (self.enteredBackground == false) {
            self.fromInActiveState = self.enteredBackground;
        }
    }
    
    //MARK: - Handle Push Notification
    func handleNotification(userInfo:[AnyHashable : Any], inApplication application:UIApplication, withCompletion completion:((UIBackgroundFetchResult) -> Void)?) {
        if(application.applicationState == UIApplication.State.inactive) {
            // --- Handle push in inactive state ---
            if let completionHandler = completion {
                completionHandler(UIBackgroundFetchResult.newData)
            }
            self.handleNotificationInInactiveState(userInfo: userInfo)
        } else if (application.applicationState == UIApplication.State.background) {
            // --- Handle push in background state --- //
            if let completionHandler = completion {
                completionHandler(UIBackgroundFetchResult.newData);
            }
            self.handleNotificationInBackgroundState(userInfo:userInfo)
        } else {
            // --- Handle push in active state --- //
            if let completionHandler = completion {
                completionHandler(UIBackgroundFetchResult.newData)
            }
            let topViewController = UIViewController.topViewController()
            if topViewController.isVisible() {
                self.handleNotificationInActiveState(userInfo: userInfo)
            }
            else {
                self.handleNotificationInInactiveState(userInfo: userInfo)
            }
        }
    }
    
    func handleNotification(userInfo:[AnyHashable : Any], inActiveState activeState:Bool) {
        if (activeState) {
            let topViewController = UIViewController.topViewController();
            if topViewController.isVisible() {
                if (UIApplication.shared.applicationState == UIApplication.State.inactive) {
                    AudioServicesPlaySystemSound(1002);
                    self.handleNotificationInInactiveState(userInfo: userInfo)
                }
                else {
                    self.handleNotificationInActiveState(userInfo: userInfo)
                }
            }
        }
        else {
            // Handle push in background state
            if (self.fromInActiveState) {
                self.handleNotificationInInactiveState(userInfo: userInfo)
                self.fromInActiveState = false
            }
            else {
                self.handleNotificationInBackgroundState(userInfo: userInfo)
            }
        }
    }
    
    func handleNotificationInActiveState(userInfo:[AnyHashable : Any]) {
        if (self.launchedByPush) {
            self.launchedByPush = false
            self.handleNotificationPayload(userInfo, needBanner:false, fromAppState:Pushdy.AppState.kNotRunning)
        }else
        {
            self.handleNotificationPayload(userInfo, needBanner:true, fromAppState:Pushdy.AppState.kActive)
        }
    }
    
    func handleNotificationInBackgroundState(userInfo:[AnyHashable : Any]) {
        self.handleNotificationPayload(userInfo, needBanner:false, fromAppState:Pushdy.AppState.kBackground)
    }
    
    func handleNotificationInInactiveState(userInfo:[AnyHashable : Any]) {
        self.handleNotificationPayload(userInfo, needBanner:false, fromAppState:Pushdy.AppState.kInActive)
    }
    
    func handleNotificationPayload(_ userInfo:[AnyHashable : Any], needBanner:Bool, fromAppState appState:String) {
        // Check ready state
        var readyForReceivingNotification = true
        if let ready = Pushdy.getDelegate()?.hasAlreadyForReceivingNotification() {
            readyForReceivingNotification = ready
        }
        if !readyForReceivingNotification {
            return
        }
        
        if let notification = userInfo as? [String:Any] {
            Pushdy.getDelegate()?.onReceivedNotification(notification, fromState: appState)
            
            if appState == Pushdy.AppState.kActive {
                if needBanner {
                    Pushdy.showInAppNotification(notification, onTap: {
                        Pushdy.getDelegate()?.onNotificationOpened(notification, fromState: appState)
                    })
                }
                else {
                    Pushdy.getDelegate()?.onNotificationOpened(notification, fromState: appState)
                }
            }
            else {
                Pushdy.getDelegate()?.onNotificationOpened(notification, fromState: appState)
            }
        }
    }
}
