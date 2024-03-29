//
//  PDYNotificationHandler.swift
//  Pushdy
//
//  Created by quandt on 10/31/17.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import UIKit
import AudioToolbox
import UserNotifications
import UserNotificationsUI

@objc class PDYNotificationHandler: NSObject {
    public typealias CompletionBlock = (_ result: UIBackgroundFetchResult?) -> Void
    
    var fromInActiveState:Bool = false
    var enteredBackground:Bool = true
    var launchedByPush:Bool = false
    
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
    
    func checkNotificationEnabled(_ resultBlock : ((Bool)->())? = nil){
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
    func handleNotification(_ notification:[String : Any], inApplication application:UIApplication, withCompletion completion:((UIBackgroundFetchResult) -> Void)?) {
        
        if let completionHandler = completion {
            completionHandler(UIBackgroundFetchResult.newData)
        }
        
        // Check ready state
//        var readyForReceivingNotification = true
//        if let pusdyDelegate = Pushdy.getDelegate(), let already = pusdyDelegate.readyForHandlingNotification?() {
//            readyForReceivingNotification = already
//        }
        let readyForReceivingNotification = Pushdy.readyForHandlingNotification()
        
        NSLog("[Pushdy] handleNotification 1: %@, inApplication:withCompletion:, readyForReceivingNotification: %ld", notification, readyForReceivingNotification)
        if !readyForReceivingNotification {
            if let _ = notification["_notification_id"] as? String {
                var pendingNotification = notification
                pendingNotification["is_pending_notification"] = true
                Pushdy.pushPendingNotification(pendingNotification)
            }
            return
        }
        
        if(application.applicationState == UIApplication.State.inactive) {
            // --- Handle push in inactive state ---
            self.handleNotificationInInactiveState(notification)
        } else if (application.applicationState == UIApplication.State.background) {
            // --- Handle push in background state --- //
            self.handleNotificationInBackgroundState(notification)
        } else {
            // --- Handle push in active state --- //
            let topViewController = UIViewController.topViewController()
            if topViewController != nil {
                if topViewController!.isVisible() {
                    self.handleNotificationInActiveState(notification)
                }
                else {
                    self.handleNotificationInInactiveState(notification)
                }
            }
        }
    }
    
    /*
     Triggered when:
     - FG > Receive push
     - ...
     */
    func handleNotification(_ notification:[String : Any], inActiveState activeState:Bool) {
        // Check ready state
//        var readyForReceivingNotification = true
//        if let pusdyDelegate = Pushdy.getDelegate(), let already = pusdyDelegate.readyForHandlingNotification?() {
//            readyForReceivingNotification = already
//        }
        let readyForReceivingNotification = Pushdy.readyForHandlingNotification()
        
        NSLog("[Pushdy] handleNotification 2: %@, inActiveState: %ld, readyForReceivingNotification: %ld", notification, activeState, readyForReceivingNotification)
        
        if !readyForReceivingNotification {
            if let _ = notification["_notification_id"] as? String {
                var pendingNotification = notification
                pendingNotification["is_pending_notification"] = true
                Pushdy.pushPendingNotification(pendingNotification)
            }
            return
        }
        
        if (activeState) {

            let topViewController = UIViewController.topViewController();
            if (topViewController != nil) {
                if topViewController!.isVisible() {
                    if (UIApplication.shared.applicationState == UIApplication.State.inactive) {
                        AudioServicesPlaySystemSound(1002);
                        self.handleNotificationInInactiveState(notification)
                    }
                    else {
                        self.handleNotificationInActiveState(notification)
                    }
                }
            }
        }
        else {
            // Handle push in background state
            if (self.fromInActiveState) {
                self.handleNotificationInInactiveState(notification)
                self.fromInActiveState = false
            }
            else {
                self.handleNotificationInBackgroundState(notification)
            }
        }
    }
    
    func handleNotificationInActiveState(_ notification:[String : Any]) {
        //if (self.launchedByPush || !Pushdy.getBadgeOnForeground()) {
        if (self.launchedByPush){
            NSLog("[Pushdy] handleNotificationInActiveState true")
            self.launchedByPush = false
            self.processNotificationPayload(notification, needBanner:false, fromAppState:AppState.kNotRunning)
        }else
        {
            if (Pushdy.getBadgeOnForeground()){
                NSLog("[Pushdy] handleNotificationInActiveState false 1")
                self.processNotificationPayload(notification, needBanner:true, fromAppState:AppState.kActive)
            } else {
                NSLog("[Pushdy] handleNotificationInActiveState false 2")
                self.processNotificationPayload(notification, needBanner:false, fromAppState:AppState.kActive)
            }
        }
    }
    
    func handleNotificationInBackgroundState(_ notification:[String : Any]) {
        self.processNotificationPayload(notification, needBanner:false, fromAppState:AppState.kBackground)
    }
    
    func handleNotificationInInactiveState(_ notification:[String : Any]) {
        self.processNotificationPayload(notification, needBanner:false, fromAppState:AppState.kInActive)
    }
    
    /// It's was triggered when:
    /// - FG: Received push
    /// - BG: Open push
    /// - Please see above funtions to know all the cases
    ///
    /// Test case: cause lag app:
    /// - Drag status bar to go Inactive State, then receive push  ==> No push was shown or handled ?  ==> App lag
    func processNotificationPayload(_ notification:[String : Any], needBanner:Bool, fromAppState appState:String) {
        NSLog("processNotificationPayload: appState: " + appState)
        if let pushdyDelegate = Pushdy.getDelegate(), appState == AppState.kActive {
            // Only fire onNotificationReceived when our app is in active state,
            // If app is not active, notification was handled by OS or rich-push-notification extension
            pushdyDelegate.onNotificationReceived?(notification, fromState: appState)
        }
        
        // Should show notification when app is active?
        var shouldHandle = true
        if appState == AppState.kActive {
            if needBanner {
                shouldHandle = false
                // showInAppNotification behavior depend on _useCustomInAppBanner
                Pushdy.showInAppNotification(notification, onTap: {
//                    NSLog("[Pushdy] Push Banner onTap: %@", notification);
                    if let pushdyDelegate = Pushdy.getDelegate() {
//                        NSLog("[Pushdy] onNotificationOpened: %@, fromState: %@", notification, appState);
                        pushdyDelegate.onNotificationOpened?(notification, fromState: appState)
                    }
                    self.removePendingNotification(notification)
                })
            }
        }
        
        // If it's not Foreground state, do tracking + remove from pending
        if shouldHandle {
            if let pushdyDelegate = Pushdy.getDelegate() {
//                NSLog("[Pushdy] onNotificationOpened: %@, fromState: %@", notification, appState);
                pushdyDelegate.onNotificationOpened?(notification, fromState: appState)
            }
            self.removePendingNotification(notification)
            
            PDYThread.perform(onBackGroundThread: {
                // track Opening PushNotification already perform a delay task, we should not put a delay task into a delay task I don't know why it didnt work
                Pushdy.trackOpeningPushNotification(notification)
            }, after: 0.5)
        }
    }
    
    
    func removePendingNotification(_ notification:[String:Any]) {
        // Remove pending notifiction after opened
        if let isPending = notification["is_pending_notification"] as? Bool {
            if isPending, let notificationID = notification["_notification_id"] as? String {
                Pushdy.removePendingNotification(notificationID)
            }
        }
    }
}
