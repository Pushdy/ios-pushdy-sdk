//
//  Pushdy.swift
//  Pushdy
//
//  Created by quandt on 6/28/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation
import UIKit
import PushdyCore

@objc public typealias PushdyResultSuccessBlock = (NSDictionary) -> Void
@objc public typealias PushdyFailureBlock = (NSError) -> Void

@objc public protocol PushdyDelegate : NSObject {
    func hasAlreadyForReceivingNotification() -> Bool
    func onReceivedNotification(_ notification:[String:Any], fromState:String)
    func onNotificationOpened(_ notification:[String:Any], fromState:String)
    func onRegisteredForRemoteNotificationsWithDeviceToken(_ deviceToken:String)
    func onFailedToRegisterForRemoteNotifications(_ error:NSError)
    func onAddedPlayerSuccessfully(_ playerID:String)
    func onFailedToAddPlayer(_ error:NSError)
    func onEditedPlayerSuccessfully(_ playerID:String)
    func onFailedToEditPlayer(_ playerID:String, error:NSError)
    func onCreatedNewSessionSuccessfully(_ playerID:String)
    func onFailedToCreateNewSession(_ playerID:String, error:NSError)
    func onTrackedNotificationSuccessfully(_ notification:[String:Any])
    func onFailedToTrackNotification(_ notification:[String:Any], error:NSError)
}

// A trick to force a protocol to optional protocol
public extension PushdyDelegate {
    func hasAlreadyForReceivingNotification() -> Bool {
        return true
    }
    func onReceivedNotification(_ notification:[String:Any], fromState:String) {
        
    }
    func onNotificationOpened(_ notification:[String:Any], fromState:String) {
        
    }
    func onRegisteredForRemoteNotificationsWithDeviceToken(_ deviceToken:String) {
        
    }
    func onFailedToRegisterForRemoteNotifications(_ error:NSError) {
        
    }
    func onAddedPlayerSuccessfully(_ playerID:String) {
        
    }
    func onFailedToAddPlayer(_ error:NSError) {
        
    }
    func onEditedPlayerSuccessfully(_ playerID:String) {
        
    }
    func onFailedToEditPlayer(_ playerID:String, error:NSError) {
        
    }
    func onCreatedNewSessionSuccessfully(_ playerID:String) {
        
    }
    func onFailedToCreateNewSession(_ playerID:String, error:NSError) {
        
    }
    func onTrackedNotificationSuccessfully(_ notification:[String:Any]) {
        
    }
    func onFailedToTrackNotification(_ notification:[String:Any], error:NSError) {
        
    }
}

@objc public class Pushdy : NSObject {
    
    @objc public class AppState {
        public static let kNotRunning:String = "not_running"
        public static let kActive:String = "active"
        public static let kInActive:String = "inactive"
        public static let kBackground:String = "background"
    }
    
    internal static var _clientKey:String?
    internal static var _launchOptions:[UIApplication.LaunchOptionsKey: Any]?
    internal static var _deviceID:String?
    internal static var _playerID:String?
    internal static var _delegate:UIApplicationDelegate?
    
    internal static var _pushdyDelegate:PushdyDelegate? = nil
    
    internal static let UPDATE_ATTRIBUTES_INTERVAL:TimeInterval = 5*60 // 5 minutes
    
    // MARK: Pushdy Init
    private override init() {
        
    }
    
    public static func initWith(clientKey:String, delegate:UIApplicationDelegate, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        _clientKey = clientKey
        _launchOptions = launchOptions
        _delegate  = delegate
        
        // Swizzle application
        UIApplication.swizzle()
        UIApplication.shared.delegate = delegate
        
        // Check and set pushdy delegage
        if (!class_conformsToProtocol((delegate as AnyObject).classForCoder, PushdyDelegate.self as? Protocol)) {
            _pushdyDelegate = delegate as? PushdyDelegate
        }
        
        // Handle pushdy logic
        self.checkFirstTimeOpenApp()
        
        // Observe properties changed
        self.observePropertiesChanged()
    }
    
    // MARK: Pushdy Getter/Setter
    public static func getClientKey() -> String? {
        return _clientKey
    }
    
    public static func setDeviceID(_ deviceID:String) {
        _deviceID = deviceID
    }
    
    public static func getDelegate() -> PushdyDelegate? {
        return _pushdyDelegate
    }
    
    //MARK: Pusdy Error/Exception
    internal static func clientKeyNotSetError() -> Error {
        let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "\(NSStringFromClass(self)):\(#function):: client-key not set. Please set configuration first"])
        return error
    }
    
    
    //MARK: Internal Handler
    internal static func checkFirstTimeOpenApp() {
        let firstTimeOpenApp = isFirstTimeOpenApp()
        // If first time open app, then create player
        if firstTimeOpenApp {
            createPlayer()
        }
        else { // Else if not, then track new session
            createNewSession()
        }
        
        setFirstTimeOpenApp(false)
    }
    
    @objc internal static func observePropertiesChanged() {
        Timer.scheduledTimer(timeInterval: UPDATE_ATTRIBUTES_INTERVAL, target: self, selector: #selector(self.updatePlayerIfNeeded), userInfo: nil, repeats: true)
    }
    
    @objc internal static func updatePlayerIfNeeded() {
        if !isCreatingPlayer && !isEditingPlayer {
            var shouldUpdate = false
            if attributesHasChanged() {
                shouldUpdate = true
            }
            
            if shouldUpdate {
                if isFetchedAttributes() {
                    editPlayer()
                }
                else {
                    getAttributes(completion: { (result:[[String : Any]]?) in
                        editPlayer()
                    }, failure: { (errorCode:Int, message:String?) in
                        editPlayer()
                    })
                }
            }
        }
    }
    
}
