//
//  Pushdy.swift
//  Pushdy
//
//  Created by quandt on 6/28/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation
import UIKit

public typealias PushdyResultSuccessBlock = (NSDictionary) -> Void
public typealias PushdyFailureBlock = (NSError) -> Void

@objc public protocol PushdyDelegate {
    @objc optional func pushdyHasAlreadyForHandlingNotification() -> Bool
    @objc optional func pushdyOnReceivedNotification(_ notification:[String:Any], fromState:String)
    @objc optional func pushdyOnNotificationOpened(_ notification:[String:Any], fromState:String)
    @objc optional func pushdyOnRegisteredForRemoteNotificationsWithDeviceToken(_ deviceToken:String)
    @objc optional func pushdyOnFailedToRegisterForRemoteNotifications(_ error:NSError)
    @objc optional func pushdyOnAddedPlayerSuccessfully(_ playerID:String)
    @objc optional func pushdyOnFailedToAddPlayer(_ error:NSError)
    @objc optional func pushdyOnBeforeUpdatePlayer()
    @objc optional func pushdyOnEditedPlayerSuccessfully(_ playerID:String)
    @objc optional func pushdyOnFailedToEditPlayer(_ playerID:String, error:NSError)
    @objc optional func pushdyOnCreatedNewSessionSuccessfully(_ playerID:String)
    @objc optional func pushdyOnFailedToCreateNewSession(_ playerID:String, error:NSError)
    @objc optional func pushdyOnTrackedNotificationSuccessfully(_ notification:[String:Any])
    @objc optional func pushdyOnFailedToTrackNotification(_ notification:[String:Any], error:NSError)
    @objc optional func pushdyOnGetAttributesSuccessfully(_ attributes:[[String:Any]])
    @objc optional func pushdyOnFailedToGetAttributes(_ error:NSError)
}

@objc public class AppState : NSObject {
    public static let kNotRunning:String = "not_running"
    public static let kActive:String = "active"
    public static let kInActive:String = "inactive"
    public static let kBackground:String = "background"
    
    private override init() {
        
    }
}

@objc public class Pushdy : NSObject {
    
    internal static var _clientKey:String?
    internal static var _launchOptions:[UIApplication.LaunchOptionsKey: Any]?
    internal static var _playerID:String?
    internal static var _delegate:UIApplicationDelegate?
    
    internal static var _pushdyDelegate:PushdyDelegate? = nil
    
    internal static let UPDATE_ATTRIBUTES_INTERVAL:TimeInterval = 5*60 // 5 minutes
    
    // MARK: Pushdy Init
    private override init() {
        
    }
    
    /**
     Initialize and configure Pushdy with client key, app delegate and launchOptions.
     
     - Parameter clientKey: The client key which is got from Pushdy application.
     - Parameter delegate: An UIApplicationDelegate instance.
     - Parameter launchOptions: An app launching options dictionary.
     
     */
    @objc public static func initWith(clientKey:String, delegate:UIApplicationDelegate, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        _clientKey = clientKey
        _launchOptions = launchOptions
        _delegate  = delegate
        
        // Swizzle application
        UIApplication.swizzle()
        UIApplication.shared.delegate = delegate
        
        // Check and set pushdy delegage
        if let _ = Pushdy.getClassWithProtocolInHierarchy((delegate as AnyObject).classForCoder, protocolToFind: PushdyDelegate.self) {
            _pushdyDelegate = delegate as? PushdyDelegate
        }
        
        // Check launch by push notification
        self.checkLaunchingFromPushNotification()
        
        // Handle pushdy logic
        self.checkFirstTimeOpenApp()
        
        // Observe attributes's change
        self.observeAttributesChanged()
    }
    
    // MARK: Pushdy Getter/Setter
    public static func getClientKey() -> String? {
        return _clientKey
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
    internal static func checkLaunchingFromPushNotification() {
        if let launchOptions = _launchOptions, let notification = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [String : Any] {
            PDYThread.perform(onBackGroundThread: {
                Pushdy.trackOpeningPushNotification(notification)
            }, after: 0.5)
        }
    }
    
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
    
    /**
     Observe attributes's change
     */
    @objc internal static func observeAttributesChanged() {
        Timer.scheduledTimer(timeInterval: UPDATE_ATTRIBUTES_INTERVAL, target: self, selector: #selector(self.updatePlayerIfNeeded), userInfo: nil, repeats: true)
    }
    
    /**
     Update player if attributes have changed.
     */
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
            else {
                getAttributes(completion: { (result:[[String : Any]]?) in
                    // Do no thing
                }, failure: { (errorCode:Int, message:String?) in
                    // Do nothing
                })
            }
        }
    }
    
}
