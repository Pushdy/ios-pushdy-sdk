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
extension PDYNotificationHandler: UNUserNotificationCenterDelegate {
    
    // MARK: - UNUserNotificationCenterDelegate
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Not called after update xcode 10 & swift 4.2
        self.handleNotification(userInfo: notification.request.content.userInfo, inActiveState: true)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Not called after update xcode 10 & swift 4.2
        self.handleNotification(userInfo: response.notification.request.content.userInfo, inActiveState: false)
    }
}
