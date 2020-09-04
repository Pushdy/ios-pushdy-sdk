//
//  Pushdy+Notification.swift
//  Pushdy
//
//  Created by quandt on 8/5/19.
//

import Foundation
import UIKit
import UserNotifications

public extension Pushdy {
    private static var _pendingNotifications:[[String:Any]] = [[String:Any]]()
    
    /**
     Get all pending notifications which is not handled.
     
     - Returns: A array of pending notification.
     */
    @objc static func getPendingNotifications() -> [[String:Any]] {
        return _pendingNotifications
    }
    
    /**
     Get latest pending notification which is not handled.
     
     - Returns: A pending notification.
     */
    @objc static func getPendingNotification() -> [String:Any]? {
        if _pendingNotifications.count > 0 {
            return _pendingNotifications.last
        }
        return nil
    }
    
    /**
     Remove last pending notification from pending notifications.
     
     */
    @objc static func popPendingNotification() {
        _pendingNotifications.removeLast()
    }
    
    /**
     Remove pending notification with specified notification id.
     
     - Parameter notificationID: A notification id
     */
    @objc static func removePendingNotification(_ notificationID:String) {
        if _pendingNotifications.count > 0 {
            var index = -1
            for i in 0..<_pendingNotifications.count {
                let item = _pendingNotifications[i];
                if let itemID = item["_notification_id"] as? String {
                    if notificationID == itemID {
                        index = i
                        break
                    }
                }
            }
            if index >= 0 {
                _pendingNotifications.remove(at: index)
            }
        }
    }
    
    /**
     Push pending notification into pending notification stack.
     
     - Parameter notificationID: A notification id
     */
    @objc static func pushPendingNotification(_ notification:[String:Any]) {
        _pendingNotifications.append(notification)
    }
    
    /**
     Clear all pending notifications.
     */
    @objc static func clearPendingNotifications() {
        _pendingNotifications.removeAll()
    }
    
    @objc static func isLaunchedFromNotification() -> Bool {
        return PDYNotificationHandler.shared.launchedByPush
    }
    
    /**
     Register for receiving push notification. This will trigger a alert view to ask user's permissions.
     */
    @objc static func registerForPushNotifications() {
        PDYNotificationHandler.shared.registerForPushNotifications()
    }
    
    /**
     Check notification is enable or not.
     
     - Parameter resultBlock: A block which return checking result.
     */
    @objc static func checkNotificationEnabled(_ resultBlock : ((Bool)->())? = nil) {
        PDYNotificationHandler.shared.checkNotificationEnabled(resultBlock)
    }
    
    @objc static func setApplicationIconBadgeNumber(_ count: Int) {
        // RCTSharedApplication().applicationIconBadgeNumber = count
        
        // You can "remove" the app badge icon by setting it to 0:
        // Swift < 3.0
        // UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        // Swift 3.0+
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
    @objc static func getApplicationIconBadgeNumber() -> Int {
        // return RCTSharedApplication().applicationIconBadgeNumber
        return UIApplication.shared.applicationIconBadgeNumber
    }
}

