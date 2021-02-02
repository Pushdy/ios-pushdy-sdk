//
//  Pushdy+InAppNotification.swift
//  Pushdy
//
//  Created by quandt on 8/6/19.
//

import Foundation
import UIKit

public extension Pushdy {
    private static let PUSH_BANNER_HEIGHT:CGFloat = 65
    private static var _notificationView:UIView?
    private static var _defaultNotificationView:PDYNotificationView?
    private static var _customNotificationView:UIView?

    /*
     _useSdkHandler == true: Pushdy will use built-in InAppBanner to handle how inappbanner show and it's interaction
     _useSdkHandler == false: Pushdy will pass data into another handler, that handler will handle in app banner UI, but interaction still handled by SDK. Eg: Use JS thread to show banner on react-native
     */
    private static var _useSdkHandler: Bool = true
    private static var _customBannerData: [String: Any] = [:]
    private static var _customBannerActions: PDYActionBlock? = nil
    
    
    // MARK: - Push Notification View
    internal static func initDefaultNotificationView() {
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            _defaultNotificationView = UIView.instantiate(forClass:PDYNotificationView.self) as? PDYNotificationView
            _defaultNotificationView?.frame = CGRect(x:0.0, y:0.0, width:window.frame.size.width, height:PUSH_BANNER_HEIGHT)
        }
    }

    /// showInAppNotification depend on
    @objc static func showInAppNotification(_ data:[String: Any], onTap:@escaping PDYActionBlock) {
        if !_useSdkHandler {
            let newBlock:PDYActionBlock = { () -> Void in
                onTap()
                
                // Track open push notification
                trackOpeningPushNotification(data)
            }
            
            // Store data to execute it later
            _customBannerData = data
            _customBannerActions = newBlock
            
            // Schedule to clean
            cleanCustomBannerData(delay: 0.1 + Pushdy.getPushBannerDismissDuration())
            
            // Stop execution
            return
        }
        
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
            if let _ = Pushdy.getClassWithProtocolInHierarchy(_customNotificationView!.classForCoder, protocolToFind: PDYPushBannerActionProtocol.self) {
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
    
    /**
     Set custom push banner (in app banner)
     
     - Parameter customView: A custom view.
     
     - Throws: An exception if your custom view does not conform to PDYPushBannerActionProtocol
     
     */
    @objc static func setCustomPushBanner(_ customView:UIView) throws {
        if let _ = Pushdy.getClassWithProtocolInHierarchy(customView.classForCoder, protocolToFind: PDYPushBannerActionProtocol.self) {
            _customNotificationView = customView
        }
        else {
            let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "\(NSStringFromClass(self)):\(#function):: Your custom push banner does not conform to PDYPushBannerActionProtocol. Please apply that protocol to your custom view."])
            throw error
        }
    }
    
    static func useSDKHandler(_ enabled: Bool) -> Void {
        _useSdkHandler = enabled
    }
    
    static func handleCustomInAppBannerPressed(_ notificationId: String) -> Void {
        // trigger actions
        _customBannerActions?()
        
        // clean
        cleanCustomBannerData(delay: 0.1)
    }
    
    static func cleanCustomBannerData(delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            _customBannerData = [:]
            _customBannerActions = nil
        }
    }
}
