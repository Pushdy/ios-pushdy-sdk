//
//  Pushdy+Request.swift
//  Pushdy
//
//  Created by quandt on 8/5/19.
//

import Foundation

public extension Pushdy {
    internal static var isCreatingPlayer:Bool = false
    internal static var isEditingPlayer:Bool = false
    internal static var isFetchingAttributes:Bool = false
    
    static func createPlayer(params: [String : Any]?, completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
        if let key = _clientKey {
            let player = PDYPlayer(clientKey:key, deviceID: _deviceID)
            try player.add(params: params, completion: completion, failure: failure)
        }
        else {
            throw clientKeyNotSetError()
        }
    }
    
    static func editPlayer(playerID:String, params: [String : Any], completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
        if let key = _clientKey {
            let player = PDYPlayer(clientKey:key, deviceID: _deviceID)
            try player.edit(playerID: playerID, params: params, completion: completion, failure: failure)
        }
        else {
            throw clientKeyNotSetError()
        }
    }
    
    static func newSession(playerID:String, completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
        if let key = _clientKey {
            let player = PDYPlayer(clientKey:key, deviceID: _deviceID)
            try player.newSession(playerID: playerID, completion: completion, failure: failure)
        }
        else {
            throw clientKeyNotSetError()
        }
    }
    
    internal static func addAttribute(name:String, type:String, label:String?, completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
        if let key = _clientKey {
            let attribute = PDYAttribute(clientKey:key)
            try attribute.add(name: name, type: type, label: label, completion: completion, failure: failure)
        }
        else {
            throw clientKeyNotSetError()
        }
    }
    
    internal static func editAttribute(name:String, newName:String, label:String?, completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
        if let key = _clientKey {
            let attribute = PDYAttribute(clientKey:key)
            try attribute.edit(name: name, newName: newName, label: label, completion: completion, failure: failure)
        }
        else {
            throw clientKeyNotSetError()
        }
    }

  // Moved to Pushdy+Tracking.swift
//    @objc static func trackOpened(playerID:String?, notificationID:String, completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
//        if let key = _clientKey {
//            let notification = PDYNotification(clientKey:key, deviceID: _deviceID)
//            try notification.trackOpened(playerID: playerID, notificationID: notificationID, completion: completion, failure: failure)
//        }
//        else {
//            throw clientKeyNotSetError()
//        }
//    }
    
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
//                NSLog("[Pushdy] Create player successfully")
                isCreatingPlayer = false
                if let dict = response as? [String:Any], let result = dict["success"] as? Bool, result == true {
                    if let playerID = dict["id"] as? String {
                        setPlayerID(playerID)
                        getDelegate()?.onPlayerAdded?(playerID)
                        
                        if attributesHasChanged() {
                            editPlayer()
                        }
                    }
                }
                
                var shouldEditPlayer = false
                if let _ = getDeviceToken(), hasTokenBefore == false {
                    shouldEditPlayer = true
                }
                
                if isFetchedAttributes() {
                    if shouldEditPlayer {
                        editPlayer()
                    }
                }
                else {
                    getAttributes(completion: { (result:[[String : Any]]?) in
                        if shouldEditPlayer {
                            editPlayer()
                        }
                    }, failure: { (errorCode:Int, message:String?) in
                        if shouldEditPlayer {
                            editPlayer()
                        }
                    })
                }
            }) { (errorCode:Int, message:String?) in
                isCreatingPlayer = false
//                NSLog("[Pushdy] Failed to create player code="+String(errorCode)+", message="+(message ?? ""))
                let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "Failed to create player code="+String(errorCode)+", message="+(message ?? "")])
                getDelegate()?.onPlayerFailedToAdd?(error)
            }
        }
        catch let error {
            isCreatingPlayer = false
//            NSLog("[Pushdy] createPlayer raised an exception \(error)")
            getDelegate()?.onPlayerFailedToAdd?(error as NSError)
        }
    }
    
    internal static func createNewSession() {
        if let playerID = getPlayerID() {
            do {
                try newSession(playerID: playerID, completion: { (result:AnyObject?) in
//                    NSLog("[Pushdy] Create new session successfully")
                    getDelegate()?.onNewSessionCreated?(playerID)
                }, failure: { (errorCode:Int, message:String?) in
//                    NSLog("[Pushdy] Failed to create new session code="+String(errorCode)+", message="+(message ?? ""))
                    let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "[Pushdy] Failed to create new session code="+String(errorCode)+", message="+(message ?? "")])
                    getDelegate()?.onNewSessionFailedToCreate?(playerID, error:error)
                })
            }
            catch let error {
//                NSLog("[Pushdy] newSession raised an exception \(error)")
                getDelegate()?.onNewSessionFailedToCreate?(playerID, error:error as NSError)
            }
        }
        else {
            createPlayer()
        }
    }
    
    /**
     Get player's attributes
     
     - Parameter completion: A completion block.
     - Parameter failure: A failure block.
     
     */
    static func getAttributes(completion:(([[String:Any]]?) -> Void)?, failure:((Int, String?) -> Void)?) {
        isFetchingAttributes = true
        try? getAttributes(completion: { (response:AnyObject?) in
            isFetchingAttributes = false
            print("[Pushdy] getAttributes response \(response)")
            var results:[[String:Any]]? = nil
            if let dict = response as? [String:Any], let result = dict["success"] as? Bool, result == true {
                if let attributes = dict["data"] as? [[String:Any]] {
                    results = attributes
                    setAttributesSchema(attributes)
                    setFetchedAttributes(true)
                    getDelegate()?.onAttributesReceived?(attributes)
                }
            }
            completion?(results)
        }, failure: { (errorCode:Int, message:String?) in
            isFetchingAttributes = false
            failure?(errorCode, message)
            print("[Pushdy] getAttributes error message \(message)")
            let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "[Pushdy] Failed to get attributes code="+String(errorCode)+", message="+(message ?? "")])
            getDelegate()?.onAttributesFailedToReceive?(error)
        })
    }
    
    internal static func editPlayer() {
        if let playerID = getPlayerID(), isEditingPlayer != true {
            getDelegate()?.onBeforeUpdatePlayer?()
            var params = [String:Any]()
            if let deviceToken = getDeviceToken() {
                params[PDYParam.DeviceToken] = deviceToken
            }
            
            if let changedAttrs = getChangedStack() {
                print("[Pushdy] editPlayer changed attributes: \(changedAttrs)")
                params = params.merging(changedAttrs) { (_, new) in new }
            }
            
            do {
                isEditingPlayer = true
//                NSLog("[Pushdy] editPlayer params: \(params.jsonString)")
                try editPlayer(playerID: playerID, params: params, completion: { (response:AnyObject?) in
                    isEditingPlayer = false
//                    NSLog("[Pushdy] Edit player successfully")
                    setLocalAttribValuesAfterSubmitted()
                    clearChangedStack()
                    getDelegate()?.onPlayerEdited?(playerID)
                }) { (errorCode:Int, message:String?) in
                    isEditingPlayer = false
//                    NSLog("[Pushdy] Failed to edit player code="+String(errorCode)+", message="+(message ?? ""))
                    let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "[Pushdy] Failed to edit player code="+String(errorCode)+", message="+(message ?? "")])
                    getDelegate()?.onPlayerFailedToEdit?(playerID, error:error)
                }
            }
            catch let error {
                isEditingPlayer = false
//                NSLog("[Pushdy] editPlayer raised an exception \(error)")
                getDelegate()?.onPlayerFailedToEdit?(playerID, error:error as NSError)
            }
        }
    }
  
  // Moved to Pushdy+Tracking.swift
//    /**
//     Track opening push notification
//
//     - Parameter data: A notification dictionary.
//
//     */
//    static func trackOpeningPushNotification(_ data:[String:Any]) {
//        // Track open push notification
//        if let notificationID = data["_notification_id"] as? String {
//            let playerID = getPlayerID()
//            try? trackOpened(playerID: playerID, notificationID: notificationID, completion: { (response:AnyObject?) in
//                print("[Pushdy] Tracked opening for push \(notificationID) successfully")
//            }, failure: { (errorCode:Int, message:String?) in
//                print("[Pushdy] Failed to track opening for push \(notificationID) with error \(errorCode) : \(message)")
//            })
//        }
//    }
    
    @objc static func getAttributes(completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
        if let key = _clientKey {
            let attribute = PDYAttribute(clientKey:key)
            try attribute.get(completion: completion, failure: failure)
        }
        else {
            throw clientKeyNotSetError()
        }
    }
    
    /**
     Set attribute
     
     - Parameter name: Attribute name
     - Parameter value: Attribute value
     
     */
    @objc static func setAttribute(_ name:String, value:Any) throws {
        try setAttribute(name, value: value, commitImmediately: false)
    }
    
    /**
     Set attribute
     
     - Parameter name: Attribute name
     - Parameter value: Attribute value
     - Parameter commitImmediately: A boolean flag which indicate that the attribute can be submitted immediately or not
     
     */
    @objc static func setAttribute(_ name:String, value:Any, commitImmediately:Bool) throws {
        let changed = isAttributeChanged(name, newValue: value)
        if !changed { return }
        
        var typeStr = ""
        if value is Array<Any> {
            typeStr = AttributeType.kArray
        }
        else if value is String {
            typeStr = AttributeType.kString
        }
        else if value is Bool {
            typeStr = AttributeType.kBoolean
        }
        else if value is Int || value is Double {
            typeStr = AttributeType.kNumber
        }
        
        if PDYAttribute.types.contains(typeStr) {
            if let currentValue = getAttributeValue(name) {
                setPrevAttributeValue(name, value: currentValue)
            }
            setAttributeValue(name, value: value)
            
            pushToChangedStack(name, value: value)

            if commitImmediately {
                editPlayer()
            }
        }
        else {
            let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "Value type is not supported"])
            throw error
        }
    }
    
    /**
     Push attribute with array type
     
     - Parameter name: Attribute name
     - Parameter value: Attribute value
     
     */
    @objc static func pushAttribute(_ name:String, value:Any) throws {
        try pushAttribute(name, value: value, commitImmediately: false)
    }
    
    /**
     Push attribute with array type
     
     - Parameter name: Attribute name
     - Parameter value: Attribute value
     - Parameter commitImmediately: A boolean flag which indicate that the attribute can be submitted immediately or not
     */
    @objc static func pushAttribute(_ name:String, value:Any, commitImmediately:Bool) throws {
        var currentValue:Array<Any>?
        if var values = getAttributeValue(name) as? Array<Any> {
            setPrevAttributeValue(name, value: values)
            values.append(value)
            setAttributeValue(name, value: values)
            currentValue = values
        }
        else {
            currentValue = [value]
            setAttributeValue(name, value: [value])
        }
        
        if let _ = currentValue {
            pushToChangedStack(name, value: currentValue!)
        }
        
        if commitImmediately {
            editPlayer()
        }
    }

    @objc static func subscribeBanner () {
       guard let url = URL(string: "https://api.pushdi.com/application/pushdy/player/96655d2e-ce02-3ec7-a0f6-273e5458fe67/subscribe") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching films: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(response)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do{
                let result = try JSONSerialization.jsonObject(with: data, options: []) as Any
                
                if let resultDict = result as? [String: Any] {
                    if let banners = resultDict["banners"] {
                        print("banners: \(banners)")
                        PDYStorage.set(key: PUSHDY_BANNER_KEY, value: banners)
                    }
                }
                print("Result: \(result)")
            }catch{
                print("Error decoding JSON: \(error)")
            }
           })
           task.resume()
    }
}

