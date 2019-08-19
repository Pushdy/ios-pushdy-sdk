//
//  UIApplication+Pushdy.swift
//  Pushdy
//
//  Created by quandt on 6/28/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation
import UIKit

public extension UIApplication {
    @objc func pushdyApplication(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let newDeviceToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        var notEqual = false
        if let oldDeviceToken = Pushdy.getDeviceToken() {
            notEqual = oldDeviceToken != newDeviceToken
        }
        else {
            notEqual = true
        }
        
        // Set new device token
        Pushdy.setDeviceToken(newDeviceToken)
        
        // Update new token if need
        if notEqual && !Pushdy.isEditingPlayer {
            Pushdy.editPlayer()
        }
        
        // Forward to delegate
        Pushdy.getDelegate()?.pushdyOnRegisteredForRemoteNotificationsWithDeviceToken?(newDeviceToken)
        
        // Call origin method
        if self.responds(to: #selector(UIApplication.pushdyApplication(_:didRegisterForRemoteNotificationsWithDeviceToken:))) {
            self.pushdyApplication(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }
    
    @objc func pushdyDidFailRegisterForRemoteNotifications(_ app : UIApplication, error : NSError) {
        // Forward to delegate
        Pushdy.getDelegate()?.pushdyOnFailedToRegisterForRemoteNotifications?(error)
        
        // Call origin method
        if self.responds(to: #selector(UIApplication.pushdyDidFailRegisterForRemoteNotifications(_:error:))) {
            self.pushdyDidFailRegisterForRemoteNotifications(app, error: error)
        }
    }
//
//    @objc @available(iOS 8.0, *)
//    public func pushdyDidRegisterUserNotifications(_ application : UIApplication, settings notificationSettings : UIUserNotificationSettings) {
//
//        if self.responds(to: #selector(UIApplication.pushdyDidRegisterUserNotifications(_:settings:))) {
//            self.pushdyDidRegisterUserNotifications(application, settings: notificationSettings)
//        }
//    }
    
//    @objc public func pushdyRemoteSilentNotification(_ application : UIApplication, userInfo : NSDictionary, fetchCompletionHandler completionHandler : (UIBackgroundFetchResult) -> Void) {
//
//        if self.responds(to: #selector(UIApplication.pushdyRemoteSilentNotification(_:userInfo:fetchCompletionHandler:))) {
//            self.pushdyRemoteSilentNotification(application, userInfo: userInfo, fetchCompletionHandler: completionHandler)
//        }
//        else {
//            completionHandler(UIBackgroundFetchResult.newData)
//        }
//    }
//
//    @objc public func pushdyLocalNotificationOpened(_ application : UIApplication, handleActionWithIdentifier identifier : NSString, forLocalNotification notification : UILocalNotification, completionHandler : ()-> Void) {
//
//        if self.responds(to: #selector(UIApplication.pushdyLocalNotificationOpened(_:handleActionWithIdentifier:forLocalNotification:completionHandler:))) {
//            self.pushdyLocalNotificationOpened(application, handleActionWithIdentifier: identifier, forLocalNotification: notification, completionHandler: completionHandler)
//        }
//        else {
//            completionHandler()
//        }
//    }
    
//    @objc public func pushdyLocalNotificationOpened(_ application : UIApplication, notification : UILocalNotification) {
//
//        if self.responds(to: #selector(UIApplication.pushdyLocalNotificationOpened(_:notification:))) {
//            self.pushdyLocalNotificationOpened(application, notification: notification)
//        }
//    }
    
    @objc func pushdyApplicationWillResignActive(_ application : UIApplication) {
        PDYNotificationHandler.shared.handleWhenAppWillResignActive()
        if self.responds(to: #selector(UIApplication.pushdyApplicationWillResignActive(_:))) {
            self.pushdyApplicationWillResignActive(application)
        }
    }
    
    @objc func pushdyApplicationDidbecomeActive(_ application : UIApplication) {
        PDYNotificationHandler.shared.handleWhenAppDidBecomeActive()
        if self.responds(to: #selector(UIApplication.pushdyApplicationDidbecomeActive(_:))) {
            self.pushdyApplicationDidbecomeActive(application)
        }
    }
    
    @objc func pushdyApplicationDidEnterBackground(_ application: UIApplication) {
        PDYNotificationHandler.shared.handleWhenAppDidEnterBackground()
        if self.responds(to: #selector(UIApplication.pushdyApplicationDidEnterBackground(_:))) {
            self.pushdyApplicationDidEnterBackground(application)
        }
    }
    
    @objc func pushdyApplication(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        let lessThan10 = UIDevice.current.systemVersion.compare("10",
                                               options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending
        if lessThan10 == true, let notification = userInfo as? [String:Any] {
            PDYNotificationHandler.shared.handleNotification(notification, inApplication: application, withCompletion: nil)
        }
        if self.responds(to: #selector(UIApplication.pushdyApplication(_:didReceiveRemoteNotification:))) {
            self.pushdyApplication(application, didReceiveRemoteNotification: userInfo)
        }
    }
    
    @objc func pushdyApplication(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let lessThan10 = UIDevice.current.systemVersion.compare("10",
                                                                options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending
        if lessThan10 == true, let notification = userInfo as? [String:Any] {
            PDYNotificationHandler.shared.handleNotification(notification, inApplication: application, withCompletion: completionHandler)
        }
        
        if self.responds(to: #selector(UIApplication.pushdyApplication(_:didReceiveRemoteNotification:fetchCompletionHandler:))) {
            self.pushdyApplication(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        }
    }
    
    @nonobjc static var appDelegateClass : AnyClass? = nil
    
    internal static func swizzle() {
        if NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_6_0 { return }
        //struct Static { static var token: Int = 0 }
        if self !== UIApplication.self { return } /* Make sure this isn't a subclass */
        
        
        //Exchange UIApplications's setDelegate with Pushdy's
        let originalSelector = NSSelectorFromString("setDelegate:")
        let swizzledSelector = #selector(UIApplication.setPushdyDelegate(_:))
        
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        let originalMethod = class_getInstanceMethod(self,originalSelector)
        let didAddMethod = class_addMethod(self, swizzledSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        }
        else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    @objc internal func setPushdyDelegate(_ delegate : UIApplicationDelegate) {
        if UIApplication.appDelegateClass != nil {
            self.setPushdyDelegate(delegate)
            return
        }
        
        UIApplication.appDelegateClass = Pushdy.getClassWithProtocolInHierarchy((delegate as AnyObject).classForCoder, protocolToFind: UIApplicationDelegate.self)
        
        if UIApplication.appDelegateClass == nil { return }
        
        // Inject application delegate's selectors
//        Pushdy.injectSelector(self.classForCoder, newSel: #selector(UIApplication.pushdyRemoteSilentNotification(_:userInfo:fetchCompletionHandler:)), addToClass: UIApplication.appDelegateClass!, makeLikeSel: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
//
//        Pushdy.injectSelector(self.classForCoder, newSel: #selector(UIApplication.pushdyLocalNotificationOpened(_:handleActionWithIdentifier:forLocalNotification:completionHandler:)), addToClass: UIApplication.appDelegateClass!, makeLikeSel: #selector(UIApplicationDelegate.application(_:handleActionWithIdentifier:for:completionHandler:)))
        
//        Pushdy.injectSelector(self.classForCoder, newSel: #selector(UIApplication.pushdyDidRegisterUserNotifications(_:settings:)), addToClass: UIApplication.appDelegateClass!, makeLikeSel: #selector(UIApplicationDelegate.application(_:didRegister:)))
//
        Pushdy.injectSelector(self.classForCoder, newSel: #selector(UIApplication.pushdyDidFailRegisterForRemoteNotifications(_:error:)), addToClass: UIApplication.appDelegateClass!, makeLikeSel: #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:)))
        
        
        Pushdy.injectSelector(self.classForCoder, newSel: #selector(UIApplication.pushdyApplication(_:didRegisterForRemoteNotificationsWithDeviceToken:)), addToClass: UIApplication.appDelegateClass!, makeLikeSel: #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)))
        
//        Swizzling.injectSelector(self.classForCoder, newSel: #selector(UIApplication.pushdyLocalNotificationOpened(_:notification:)), addToClass: UIApplication.appDelegateClass!, makeLikeSel: #selector(UIApplicationDelegate.application(_:didReceive:)))
        
        Pushdy.injectSelector(self.classForCoder, newSel: #selector(UIApplication.pushdyApplicationWillResignActive(_:)), addToClass: UIApplication.appDelegateClass!, makeLikeSel: #selector(UIApplicationDelegate.applicationWillResignActive(_:)))
        
        Pushdy.injectSelector(self.classForCoder, newSel: #selector(UIApplication.pushdyApplicationDidbecomeActive(_:)), addToClass: UIApplication.appDelegateClass!, makeLikeSel: #selector(UIApplicationDelegate.applicationDidBecomeActive(_:)))
        
        Pushdy.injectSelector(self.classForCoder, newSel: #selector(UIApplication.pushdyApplicationDidEnterBackground(_:)), addToClass: UIApplication.appDelegateClass!, makeLikeSel: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)))
        
        Pushdy.injectSelector(self.classForCoder, newSel: #selector(UIApplication.pushdyApplication(_:didReceiveRemoteNotification:)), addToClass: UIApplication.appDelegateClass!, makeLikeSel: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:)))
        
        Pushdy.injectSelector(self.classForCoder, newSel: #selector(UIApplication.pushdyApplication(_:didReceiveRemoteNotification:fetchCompletionHandler:)), addToClass: UIApplication.appDelegateClass!, makeLikeSel: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
        
        self.setPushdyDelegate(delegate)
    }
}

