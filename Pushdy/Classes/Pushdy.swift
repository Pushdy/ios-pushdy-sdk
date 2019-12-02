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
    @objc optional func readyForHandlingNotification() -> Bool
    @objc optional func onNotificationReceived(_ notification:[String:Any], fromState:String)
    @objc optional func onNotificationOpened(_ notification:[String:Any], fromState:String)
    @objc optional func onRemoteNotificationRegistered(_ deviceToken:String)
    @objc optional func onRemoteNotificationFailedToRegister(_ error:NSError)
    @objc optional func onPlayerAdded(_ playerID:String)
    @objc optional func onPlayerFailedToAdd(_ error:NSError)
    @objc optional func onBeforeUpdatePlayer()
    @objc optional func onPlayerEdited(_ playerID:String)
    @objc optional func onPlayerFailedToEdit(_ playerID:String, error:NSError)
    @objc optional func onNewSessionCreated(_ playerID:String)
    @objc optional func onNewSessionFailedToCreate(_ playerID:String, error:NSError)
    @objc optional func onNotificationTracked(_ notification:[String:Any])
    @objc optional func onNotificationFailedToTrack(_ notification:[String:Any], error:NSError)
    @objc optional func onAttributesReceived(_ attributes:[[String:Any]])
    @objc optional func onAttributesFailedToReceive(_ error:NSError)
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
    internal static var _delegate:UIApplicationDelegate?
    
    internal static var _pushdyDelegate:PushdyDelegate? = nil
    
    internal static let UPDATE_ATTRIBUTES_INTERVAL:TimeInterval = 5*60 // 5 minutes
    internal static var _badge_on_foreground:Bool? = false
    
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

    public static func getBadgeOnForeground() -> Bool {
        return _badge_on_foreground!
    }

    public static func setBadgeOnForeground(badge_on_foreground:Bool) {
        _badge_on_foreground = badge_on_foreground
    }
    
    //MARK: Pusdy Error/Exception
    internal static func clientKeyNotSetError() -> Error {
        let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "\(NSStringFromClass(self)):\(#function):: client-key not set. Please set configuration first"])
        return error
    }
    
    
    //MARK: Internal Handler
    internal static func checkLaunchingFromPushNotification() {
        if let launchOptions = _launchOptions, let notification = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [String : Any] {
            if let pushdyDelegate = getDelegate()  {
                if let ready = pushdyDelegate.readyForHandlingNotification?(), ready == true {
                    NSLog("[Pushdy] run 1")
                    pushdyDelegate.onNotificationOpened?(notification, fromState: AppState.kNotRunning)
                    
                    PDYThread.perform(onBackGroundThread: {
                        Pushdy.trackOpeningPushNotification(notification)
                    }, after: 0.5)
                }
                else {
                    NSLog("[Pushdy] run 2")
                    Pushdy.pushPendingNotification(notification)
                }
            }
            else {
                NSLog("[Pushdy] run 3")
                PDYThread.perform(onBackGroundThread: {
                    Pushdy.trackOpeningPushNotification(notification)
                }, after: 0.5)
            }
        }
    }
    
    internal static func checkFirstTimeOpenApp() {
        let firstTimeOpenApp = isFirstTimeOpenApp()
        // If first time open app, then create player
        if firstTimeOpenApp {
            createPlayer()
        }
        else { // Else if not, then track new session
            if let _ = getPlayerID() {
                createNewSession()
            }
            else {
                createPlayer()
            }
        }
        
        setFirstTimeOpenApp(false)
    }
    
    /**
     Observe attributes's change
     */
    @objc internal static func observeAttributesChanged() {
        let timer = Timer.scheduledTimer(timeInterval: UPDATE_ATTRIBUTES_INTERVAL, target: self, selector: #selector(self.updatePlayerIfNeeded), userInfo: nil, repeats: true)
        timer.fire()
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
