//
//  Pushdy+InAppNotification.swift
//  Pushdy
//
//  Created by quandt on 8/6/19.
//

import Foundation
import UIKit

extension Pushdy {
    private static let PUSH_BANNER_HEIGHT:CGFloat = 65
    private static var _notificationView:UIView?
    private static var _defaultNotificationView:PDYNotificationView?
    private static var _customNotificationView:UIView?

    // MARK: - Push Notification View
    internal static func initDefaultNotificationView() {
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            _defaultNotificationView = UIView.instantiate(forClass:PDYNotificationView.self) as? PDYNotificationView
            _defaultNotificationView?.frame = CGRect(x:0.0, y:0.0, width:window.frame.size.width, height:PUSH_BANNER_HEIGHT)
        }
    }

    internal static func showInAppNotification(_ data:[String: Any], onTap:@escaping PDYActionBlock) {
        if _customNotificationView == nil {
            if _notificationView == nil {
                initDefaultNotificationView()
            }
            let newBlock:PDYActionBlock = { () -> Void in
                onTap()
                
                // Track open push notification
                trackOpeningPushNotification(data)
            }
            _defaultNotificationView?.show(data, onTap: newBlock)
            _notificationView = _defaultNotificationView
        }
        else {
            if (class_conformsToProtocol(_customNotificationView!.classForCoder, PDYPushBannerActionProtocol.self as? Protocol)) {
                let newBlock:PDYActionBlock = { () -> Void in
                    onTap()
                    
                    // Track open push notification
                    trackOpeningPushNotification(data)
                }
                (_customNotificationView as! PDYPushBannerActionProtocol).show(data, onTap: newBlock)
                _notificationView = _customNotificationView
            }
        }
    }
    
    public static func setCustomPushBanner(_ customView:UIView) throws {
        if (!class_conformsToProtocol(customView.classForCoder, PDYPushBannerActionProtocol.self as? Protocol)) {
            let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "\(NSStringFromClass(self)):\(#function):: Your custom push banner does not conform to PDYPushBannerActionProtocol. Please apply that protocol to your custom view."])
            throw error
        }
        _customNotificationView = customView
    }
}
