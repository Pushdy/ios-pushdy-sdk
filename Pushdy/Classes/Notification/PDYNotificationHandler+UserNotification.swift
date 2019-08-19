//
//  PDYNotificationHandler.swift
//  PushdyCore
//
//  Created by quandt on 10/31/17.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

@available(iOS 10.0, *)
@objc extension PDYNotificationHandler: UNUserNotificationCenterDelegate {
    
    // MARK: - UNUserNotificationCenterDelegate
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let notif = notification.request.content.userInfo as? [String:Any] {
            self.handleNotification(notif, inActiveState: true)
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let notif = response.notification.request.content.userInfo as? [String:Any] {
            self.handleNotification(notif, inActiveState: false)
        }
    }
}
