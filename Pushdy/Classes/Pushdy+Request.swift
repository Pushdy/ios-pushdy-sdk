//
//  Pushdy+Request.swift
//  Pushdy
//
//  Created by quandt on 8/5/19.
//

import Foundation
import PushdyCore

@objc extension Pushdy {
    internal static var isCreatingPlayer:Bool = false
    internal static var isEditingPlayer:Bool = false
    internal static var isFetchingAttributes:Bool = false
    
    public static func createPlayer(params: [String : Any]?, completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
        if let key = _clientKey {
            let player = PDYPlayer(clientKey:key, deviceID: _deviceID)
            try player.add(params: params, completion: completion, failure: failure)
        }
        else {
            throw clientKeyNotSetError()
        }
    }
    
    public static func editPlayer(playerID:String, params: [String : Any], completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
        if let key = _clientKey {
            let player = PDYPlayer(clientKey:key, deviceID: _deviceID)
            try player.edit(playerID: playerID, params: params, completion: completion, failure: failure)
        }
        else {
            throw clientKeyNotSetError()
        }
    }
    
    public static func newSession(playerID:String, completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
        if let key = _clientKey {
            let player = PDYPlayer(clientKey:key, deviceID: _deviceID)
            try player.newSession(playerID: playerID, completion: completion, failure: failure)
        }
        else {
            throw clientKeyNotSetError()
        }
    }
    
    public static func trackOpened(notificationID:String, completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
        if let key = _clientKey {
            let notification = PDYNotification(clientKey:key, deviceID: _deviceID)
            try notification.trackOpened(notificationID: notificationID, completion: completion, failure: failure)
        }
        else {
            throw clientKeyNotSetError()
        }
    }
    
    internal static func createPlayer() {
        var params = [String:Any]()
        var hasTokenBefore = false
        if let deviceToken = getDeviceToken() {
            params[PDYParam.DeviceToken] = deviceToken
            hasTokenBefore = true
        }
        
        do {
            isCreatingPlayer = true
            try createPlayer(params: params, completion: { (response:AnyObject?) in
                NSLog("[Pushdy] Create player successfully")
                isCreatingPlayer = false
                if let dict = response as? [String:Any], let result = dict["success"] as? Bool, result == true {
                    if let playerID = dict["id"] as? String {
                        setPlayerID(playerID)
                        getDelegate()?.onAddedPlayerSuccessfully(playerID)
                    }
                }
                
                NSLog("getDeviceToken() = \(getDeviceToken()), hasTokenBefore = \(hasTokenBefore)")
                if let _ = getDeviceToken(), hasTokenBefore == false {
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
            }) { (errorCode:Int, message:String?) in
                isCreatingPlayer = false
                NSLog("[Pushdy] Failed to create player code="+String(errorCode)+", message="+(message ?? ""))
                let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "Failed to create player code="+String(errorCode)+", message="+(message ?? "")])
                getDelegate()?.onFailedToAddPlayer(error)
            }
        }
        catch let error {
            isCreatingPlayer = false
            NSLog("[Pushdy] createPlayer raised an exception \(error)")
            getDelegate()?.onFailedToAddPlayer(error as NSError)
        }
    }
    
    internal static func createNewSession() {
        if let playerID = getPlayerID() {
            do {
                try newSession(playerID: playerID, completion: { (result:AnyObject?) in
                    NSLog("[Pushdy] Create new session successfully")
                    getDelegate()?.onCreatedNewSessionSuccessfully(playerID)
                }, failure: { (errorCode:Int, message:String?) in
                    NSLog("[Pushdy] Failed to create new session code="+String(errorCode)+", message="+(message ?? ""))
                    let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "[Pushdy] Failed to create new session code="+String(errorCode)+", message="+(message ?? "")])
                    getDelegate()?.onFailedToCreateNewSession(playerID, error:error)
                })
            }
            catch let error {
                NSLog("[Pushdy] newSession raised an exception \(error)")
                getDelegate()?.onFailedToCreateNewSession(playerID, error:error as NSError)
            }
        }
        else {
            createPlayer()
        }
    }
    
    internal static func getAttributes(completion:(([[String:Any]]?) -> Void)?, failure:((Int, String?) -> Void)?) {
        isFetchingAttributes = true
        try? getAttributes(completion: { (response:AnyObject?) in
            isFetchingAttributes = false
            var results:[[String:Any]]? = nil
            if let dict = response as? [String:Any], let result = dict["success"] as? Bool, result == true {
                if let attributes = dict["data"] as? [[String:Any]] {
                    print("[Pushdy] getAttributes attributes \(attributes)")
                    results = attributes
                    setAttributesSchema(attributes)
                    setFetchedAttributes(true)
                }
            }
            completion?(results)
        }, failure: { (errorCode:Int, message:String?) in
            isFetchingAttributes = false
            failure?(errorCode, message)
        })
    }
    
    internal static func editPlayer() {
        if let playerID = getPlayerID(), isEditingPlayer != true {
            var params = [String:Any]()
            if let deviceToken = getDeviceToken() {
                params[PDYParam.DeviceToken] = deviceToken
            }
            
            if let attrParams = convertAttributesToParams() {
                params = params.merging(attrParams) { (_, new) in new }
            }
            
            do {
                isEditingPlayer = true
                try editPlayer(playerID: playerID, params: params, completion: { (response:AnyObject?) in
                    isEditingPlayer = false
                    NSLog("[Pushdy] Edit player successfully")
                    getDelegate()?.onEditedPlayerSuccessfully(playerID)
                }) { (errorCode:Int, message:String?) in
                    isEditingPlayer = false
                    NSLog("[Pushdy] Failed to edit player code="+String(errorCode)+", message="+(message ?? ""))
                    let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "[Pushdy] Failed to edit player code="+String(errorCode)+", message="+(message ?? "")])
                    getDelegate()?.onFailedToEditPlayer(playerID, error:error)
                }
            }
            catch let error {
                isEditingPlayer = false
                NSLog("[Pushdy] editPlayer raised an exception \(error)")
                getDelegate()?.onFailedToEditPlayer(playerID, error:error as NSError)
            }
        }
    }
    
    
    internal static func trackOpeningPushNotification(_ data:[String:Any]) {
        // Track open push notification
        if let notificationID = data["_notification_id"] as? String {
            try? trackOpened(notificationID: notificationID, completion: { (response:AnyObject?) in
                print("[Pushdy] Tracked opening for push \(notificationID) successfully")
            }, failure: { (errorCode:Int, message:String?) in
                print("[Pushdy] Failed to track opening for push \(notificationID) with error \(errorCode) : \(message)")
            })
        }
    }
    
    public static func getAttributes(completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
        if let key = _clientKey {
            let attribute = PDYAttribute(clientKey:key)
            try attribute.get(completion: completion, failure: failure)
        }
        else {
            throw clientKeyNotSetError()
        }
    }
    
    public static func setAttribute(_ name:String, value:Any) {
        if let currentValue = PDYStorage.get(key: ATTTRIBUTE_PREFIX) {
            PDYStorage.set(key: PREV_ATTTRIBUTE_PREFIX+name, value: currentValue)
        }
        PDYStorage.set(key: ATTTRIBUTE_PREFIX+name, value: value)
        
        editPlayer()
    }
    
    public static func pushAttribute(_ name:String, value:Any) {
        if var currentValue = PDYStorage.get(key: ATTTRIBUTE_PREFIX) as? Array<Any> {
            PDYStorage.set(key: PREV_ATTTRIBUTE_PREFIX+name, value: currentValue)
            currentValue.append(value)
            PDYStorage.set(key: ATTTRIBUTE_PREFIX+name, value: currentValue)
        }
        else {
            PDYStorage.set(key: ATTTRIBUTE_PREFIX+name, value: [value])
        }
        
        editPlayer()
    }
}
