//
//  Pushdy+Notification.swift
//  Pushdy
//
//  Created by quandt on 8/5/19.
//

import Foundation
import UIKit
import PushdyCore
import UserNotifications

extension Pushdy {    
    public static func registerForPushNotifications() {
        PDYNotificationHandler.shared.registerForPushNotifications()
    }
    
    func checkNotificationEnabling(_ resultBlock : ((Bool)->())? = nil) {
        PDYNotificationHandler.shared.checkNotificationEnabling(resultBlock)
    }
}

