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
    internal static var _applicationId: String = getApplicationId()
    
    internal static var _pushdyDelegate:PushdyDelegate? = nil
    
    internal static let UPDATE_ATTRIBUTES_INTERVAL:TimeInterval = 5*60 // 5 minutes
    internal static var _badge_on_foreground:Bool? = true
    
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
        
        self.restorePrimaryDataFromStorage()
        
        // Check launch by push notification
        self.checkLaunchingFromPushNotification()
        
        // Handle pushdy logic this function may lead to wrong trigger session when app is using by user.
        // Some case make appDidFinishLauchingWithOptions call without opening the app.
        // self.checkFirstTimeOpenApp()
        
        // Observe attributes's change
        self.observeAttributesChanged()
      
        self.restoreSecondaryDataFromStorage()
    }

    @objc public static func initWith(clientKey:String, delegate:UIApplicationDelegate, delegaleHandler:AnyObject, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        _clientKey = clientKey
        _launchOptions = launchOptions
        _delegate  = delegate
        // Swizzle application
        UIApplication.swizzle()
        UIApplication.shared.delegate = delegate
        // Check and set pushdy delegage
        if let _ = Pushdy.getClassWithProtocolInHierarchy((delegaleHandler as AnyObject).classForCoder, protocolToFind: PushdyDelegate.self) {
            _pushdyDelegate = delegaleHandler as? PushdyDelegate
        }
        // _pushdyDelegate = delegaleHandler
        
        self.restorePrimaryDataFromStorage()
        
        // Check launch by push notification
        self.checkLaunchingFromPushNotification()
        // Handle pushdy logic
        self.checkFirstTimeOpenApp()
        // Observe attributes's change
        self.observeAttributesChanged()
      
        self.restoreSecondaryDataFromStorage()
        
        self.subscribe()
    }
    
    
    /**
     Module react-native-pushdy need to initWith without Handler at function RNPushy.registerSdk
     so that we need to set delegate handler later.
     */
    @objc public static func setDelegateHandler(delegateHandler: AnyObject) {
        if let _ = Pushdy.getClassWithProtocolInHierarchy((delegateHandler as AnyObject).classForCoder, protocolToFind: PushdyDelegate.self) {
            _pushdyDelegate = delegateHandler as? PushdyDelegate
        }
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

    public static func subscribe() {
        return self._subscribe();
    }
    
    public static func getAllBanners() -> [NSObject] {
        return getBanners();
    }
    
    public static func trackBanner(bannerId: String, type: String ) {
        NSLog("[Pushdy] trackBanner: bannerId: \(bannerId), type \(type)")
        var playerID = getPlayerID();
        var applicationId = _applicationId ;
        // FIXME: remove this line; for testing only
//        playerID = "96655d2e-ce02-3ec7-a0f6-273e5458fe67";
//        applicationId = "pushdy"
        
        if(playerID != nil) {
            if let key = _clientKey {
                var player = PDYPlayer(clientKey:key, deviceID: _deviceID)
                NSLog("[Pushdy] trackBanner: player: \(player)")
                var bannerTrackingData = getBannerObject(id: bannerId) ?? Dictionary();
                switch type {
                    case "impression":
                    var impressionCount = bannerTrackingData["imp"] ?? 0 ;
                        let timestamp = Int64(NSDate().timeIntervalSince1970)
                        bannerTrackingData["imp"] = impressionCount as! Int + 1;
                        bannerTrackingData["last_imp_ts"] = timestamp
                    break;
                    case "click":
                    var clickCount = bannerTrackingData["click"] ?? 0 ;
                        let timestamp = Int64(NSDate().timeIntervalSince1970)
                        bannerTrackingData["click"] = clickCount as! Int + 1;
                        bannerTrackingData["last_click_ts"] = timestamp
                    break;
                    case "close":
                    var closeCount = bannerTrackingData["close"] ?? 0 ;
                        let timestamp = Int64(NSDate().timeIntervalSince1970)
                        bannerTrackingData["close"] = closeCount as! Int + 1;
                        bannerTrackingData["last_close_ts"] = timestamp
                    break;
                    case "loaded":
                    var loadedCount = bannerTrackingData["loaded"] ?? 0 ;
                        let timestamp = Int64(NSDate().timeIntervalSince1970)
                        bannerTrackingData["loaded"] = loadedCount as! Int + 1;
                        bannerTrackingData["last_loaded_ts"] = timestamp
                    break;
                default:
                    break;
                }
                
                setBannerObject(id: bannerId, bannerObject: bannerTrackingData as NSDictionary)
                
                NSLog("[Pushdy] trackBanner: bannerTrackingData final: \(bannerTrackingData)")
                let dataParams: [String: Any]  = [
                    "imp": [
                        "b": [
                            bannerId: bannerTrackingData["imp"] ?? 0
                        ]
                    ],
                    "click": [
                        "b": [
                           bannerId: bannerTrackingData["click"] ?? 0
                       ]
                    ],
                    "close": [
                        "b": [
                       bannerId: bannerTrackingData["close"] ?? 0
                    ]],
                    "loaded": [
                        "b": [
                           bannerId: bannerTrackingData["loaded"] ?? 0
                       ]
                    ],
                ]
                print("[Pushdy] dataParams:  \(dataParams)")

               try? player.trackBanner(applicationId: applicationId, playerID: playerID, data: dataParams, completion: { (response:AnyObject?) in
                   print("[Pushdy] Successfully to Tracking  \(response)")
               }, failure: { (errorCode:Int, message:String?) in
                   print("[Pushdy] Failed to Tracking  \(applicationId) with error \(errorCode) : \(String(describing: message))")
               })            }
        }
    }
    
    public static func getBannerData(bannerId: String) -> Dictionary<String, Any>? {
        return getBannerObject(id: bannerId);
    }
    
    //MARK: Pusdy Error/Exception
    internal static func clientKeyNotSetError() -> Error {
        let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "\(NSStringFromClass(self)):\(#function):: client-key not set. Please set configuration first"])
        return error
    }
    
    internal static func readyForHandlingNotification() -> Bool {
        if let pushdyDelegate = Pushdy.getDelegate()  {
            if let ready = pushdyDelegate.readyForHandlingNotification?() {
                return ready
            }
        }

        // by default this case should be false cause delegate handle may be not set at start.
        return false
    }
    
    //MARK: Internal Handler
    internal static func checkLaunchingFromPushNotification() {
        if let launchOptions = _launchOptions, let notification = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [String : Any] {
            if let pushdyDelegate = getDelegate()  {
                // let ready = self.readyForHandlingNotification() // my new code: ready is true if no delegation defined, but I don't know why we cannot go to dest page when open app by push.
                let ready = pushdyDelegate.readyForHandlingNotification?()   // original code: I don't know why we must check delegate without default value, but it work.
                if ready == true {
                    NSLog("[Pushdy] run 1: onNotificationOpened")
                    pushdyDelegate.onNotificationOpened?(notification, fromState: AppState.kNotRunning)
                    
                     PDYThread.perform(onBackGroundThread: {
                        Pushdy.trackOpeningPushNotification(notification)
                     }, after: 0.5)
                }
                else {
                    /*
                                In case of pending notification:
                                1. User will manually get pending notification from queue
                                2. Remove it from queue
                                3. TODO: Tracking open push
                                */
                    NSLog("[Pushdy] run 2: not ready > pushPendingNotification to exete later")
                    Pushdy.pushPendingNotification(notification)
                    
                    /*
                                I dont know why the single tracking version (PushdySDK@0.0.10) can track when we open push from closed state
                                In this version (PushdySDK@0.2.0) we need to force call it here
                                But be careful it can lead to duplication in notification ID, because I'm not clear why previos version can do track successfully in this case.
                                */
                    // Consider launching from push is also open push
                     PDYThread.perform(onBackGroundThread: {
                        Pushdy.trackOpeningPushNotification(notification)
                     }, after: 0.5)
                }
            }
            else {
                NSLog("[Pushdy] run 3: do nothing but track")
                /**
                 Because new react native pushdy need to intilize at appDidFinishLauchingWithOptions
                 so that will have a case that doesn't having delegateHandler yet.
                 We need to push this imcoming notificationOpened to pending Opened notification.
                 */
                Pushdy.pushPendingNotification(notification);
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
  
    // These data is important data and need to be prepared to ensure Pushdy work correctly
    @objc internal static func restorePrimaryDataFromStorage() {
        self.restorePendingTrackingOpenedItems()
    }

    // If your data is not important or can be loaded later, use this fn to restore to ensure Pushdy starting time
    @objc internal static func restoreSecondaryDataFromStorage() {
        
    }
  
    @objc internal static func restorePendingTrackingOpenedItems() {
        let items: [String] = getPendingTrackOpenNotiIds()
        if (items.count > 0) {
            NSLog("[Pushdy] restorePendingTrackingOpenedItems: Restored items: " + items.joined(separator: ","))
            pendingTrackingOpenedItems.append(contentsOf: items)
        } else {
            NSLog("[Pushdy] restorePendingTrackingOpenedItems: No pending tracking open")
        }
    }
    
    /**
     Update player if attributes have changed.
     */
    @objc internal static func updatePlayerIfNeeded() {
        if !isCreatingPlayer && !isEditingPlayer {
            // Force edit player
            editPlayer()
        }
    }

    /**
     Banner Function
     */
    internal static func _subscribe() {
         let playerID = getPlayerID();
         let applicationId = _applicationId ;


        // FIXME: remove this line; for testing only
//        playerID = "96655d2e-ce02-3ec7-a0f6-273e5458fe67";
//        applicationId = "pushdy"
        
        NSLog("[Pushdy] _subscribe: PLAYER ID: \(playerID)")
        NSLog("[Pushdy] _subscribe: applicationId: \(applicationId)")
        
        if(playerID != nil) {
            NSLog("[Pushdy] _subscribe: _clientKey: \(_clientKey)")
            if let key = _clientKey {
                let player = PDYPlayer(clientKey:key, deviceID: _deviceID)
                try? player.subscribe(applicationID: applicationId, playerID: playerID, completion: {
                    (response:AnyObject?) in
                    if let banners = response?["banners"] as? [NSObject] {
                        print("[Pushdy] subscribe banners: \(banners) \(type(of: banners))");
                          setBanners(banners: banners)
                    }
                }, failure: { (errorCode:Int, message:String?) in
                    print("[Pushdy] Failed to Subcrible \(applicationId) with error \(errorCode) : \(String(describing: message))")
                  })
            }
            // try ? player.subscribe(applicationId:applicationId, playerID: playerID)
        }
    }
}
