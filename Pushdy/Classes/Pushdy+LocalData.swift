//
//  Pushdy+LocalData.swift
//  Pushdy
//
//  Created by quandt on 8/7/19.
//

import Foundation

public extension Pushdy {
    internal static let ATTTRIBUTE_PREFIX = "PUSHDY_ATTR_"
    internal static let PREV_ATTTRIBUTE_PREFIX = "PUSHDY_PREV_ATTR_"
    
    internal static var _deviceID:String?
    
    internal static func isFirstTimeOpenApp() -> Bool {
        var firstTimeOpenApp = true
        if let firstTime = PDYStorage.getBool(key: "PUSHDY_FIRST_TIME_OPEN_APP") {
            firstTimeOpenApp = firstTime
        }
        return firstTimeOpenApp
    }
    
    internal static func setFirstTimeOpenApp(_ firstTime:Bool) {
        PDYStorage.setBool(key: "PUSHDY_FIRST_TIME_OPEN_APP", value: firstTime)
    }
    
    /**
     Get player id
     
     - Returns: A player id string.
     */
    static func getPlayerID() -> String? {
        if let playerID = PDYStorage.getString(key: "PUSHDY_PLAYER_ID") {
            return playerID
        }
        return nil
    }
    
    internal  static func setPlayerID(_ playerID:String) {
        PDYStorage.setString(key: "PUSHDY_PLAYER_ID", value: playerID)
    }
    
    /**
     Get device id
     
     - Returns: A device id string.
     */
    @objc static func getDeviceID() -> String? {
        if let _ = _deviceID {
            return _deviceID!
        }
        if let deviceID = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+"device_id") {
            return deviceID
        }
        return PDYDeviceInfo.deviceID()
    }
    
    /**
     Set device id instead of Pushdy's device id
     
     */
    @objc static func setDeviceID(_ deviceID:String) {
        NSLog("deviceID %@", deviceID);
        _deviceID = deviceID
        if let prevDeviceID = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+"device_id") {
            PDYStorage.setString(key: PREV_ATTTRIBUTE_PREFIX+"device_id", value: prevDeviceID)
        }
        PDYStorage.setString(key: ATTTRIBUTE_PREFIX+"device_id", value: deviceID)
    }
    
    /**
     Set device token
     
     */
    internal static func setDeviceToken(_ token:String) {
        NSLog("deviceToken %@", token);
        if let prevToken = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+"device_token") {
            PDYStorage.setString(key: PREV_ATTTRIBUTE_PREFIX+"device_token", value: prevToken)
        }
        PDYStorage.setString(key: ATTTRIBUTE_PREFIX+"device_token", value: token)
    }
    
//    public static func setDeviceToken(_ token:Data) {
//        let tokenStr = token.reduce("", {$0 + String(format: "%02X", $1)})
//        if let prevToken = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+"device_token") {
//            PDYStorage.setString(key: PREV_ATTTRIBUTE_PREFIX+"device_token", value: prevToken)
//        }
//        PDYStorage.setString(key: ATTTRIBUTE_PREFIX+"device_token", value:tokenStr)
//    }
    
    /**
     Get device token
     
     - Returns: A device token string.
     */
    @objc static func getDeviceToken() -> String? {
        if let token = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+"device_token") {
            return token
        }
        return nil
    }
    
    /**
     Set InAppBanner's auto dismiss ability.
     
     */
    @objc static func setPushBannerAutoDismiss(_ auto:Bool) {
        PDYStorage.setBool(key: "PUSHDY_PUSH_BANNER_AUTO_DISMISS", value: auto)
    }
    
    /**
     Check InAppBanner is auto dismiss or not.
     
     - Returns: A boolean value.
     */
    @objc static func isPushBannerAutoDismiss() -> Bool {
        var autoDismiss = true
        if let auto = PDYStorage.getBool(key: "PUSHDY_PUSH_BANNER_AUTO_DISMISS") {
            autoDismiss = auto
        }
        return autoDismiss
    }
    
    /**
     Get InAppBanner's dismiss duration.
     
     - Returns: A duration value.
     */
    @objc static func getPushBannerDismissDuration() -> Double {
        if let duration = PDYStorage.getDouble(key: "PUSHDY_PUSH_BANNER_DISMISS_DURATION") {
            return duration
        }
        return 5
    }
    
    /**
     Set InAppBanner's dismiss duration.
     
     */
    @objc static func setPushBannerDismissDuration(_ duration:Double) {
        PDYStorage.setDouble(key: "PUSHDY_PUSH_BANNER_DISMISS_DURATION", value: duration)
    }
    
    /**
     Get application version
     
     - Returns: A version string
     */
    @objc static func getAppVersion() -> String? {
        if let version = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+"app_version") {
            
            return version
        }
        return nil
    }
    
    /**
     Set application version
    
     */
    @objc static func setAppVersion(_ version:String) {
        if let prevAppVersion = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+"app_version") {
            PDYStorage.setString(key: PREV_ATTTRIBUTE_PREFIX+"app_version", value: prevAppVersion)
        }
        PDYStorage.setString(key: ATTTRIBUTE_PREFIX+"app_version", value: version)
    }
    
    /**
     Get language
     
     - Returns: A language string
     */
    @objc static func getLanguage() -> String? {
        if let lang = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+"language") {
            return lang
        }
        return nil
    }
    
    /**
     Set language
     */
    @objc static func setLanguage(_ lang:String) {
        if let prevLanguage = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+"language") {
            PDYStorage.setString(key: PREV_ATTTRIBUTE_PREFIX+"language", value: prevLanguage)
        }
        PDYStorage.setString(key: ATTTRIBUTE_PREFIX+"language", value: lang)
    }
    
    /**
     Get country
     
     - Returns: A country value
     */
    @objc static func getCountry() -> String? {
        if let country = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+"country") {
            return country
        }
        return nil
    }
    
    /**
     Set country
     */
    @objc static func setCountry(_ country:String) {
        if let prevCountry = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+"country") {
            PDYStorage.setString(key: PREV_ATTTRIBUTE_PREFIX+"country", value: prevCountry)
        }
        PDYStorage.setString(key: ATTTRIBUTE_PREFIX+"country", value: country)
    }
    
    internal static func setFetchedAttributes(_ fetched:Bool) {
        PDYStorage.setBool(key: "PUSHDY_FETCHED_ATTRIBUTES", value:fetched)
    }
    
    internal static func isFetchedAttributes() -> Bool {
        var fetchedAttributes = false
        if let fetched = PDYStorage.getBool(key: "PUSHDY_FETCHED_ATTRIBUTES") {
            fetchedAttributes = fetched
        }
        return fetchedAttributes
    }
    
    internal static func setAttributesSchema(_ attributes:[[String:Any]]) {
        if let jsonStr = attributes.jsonString {
            if let currentJsonStr = PDYStorage.getString(key: "PUSHDY_ATTRIBUTES_SCHEMA") {
                PDYStorage.setString(key: "PUSHDY_PREV_ATTRIBUTES_SCHEMA", value: currentJsonStr)
            }
            PDYStorage.setString(key: "PUSHDY_ATTRIBUTES_SCHEMA", value: jsonStr)
        }
    }
    
    internal static func getAttributesSchema() -> [[String:Any]]? {
        if let jsonStr = PDYStorage.getString(key: "PUSHDY_ATTRIBUTES_SCHEMA") {
            return jsonStr.asArrayOfDictionary()
        }
        return nil
    }
    
    internal static func attributesHasChanged() -> Bool {
        var changed = false
        if let curStr = PDYStorage.getString(key: "PUSHDY_ATTRIBUTES_SCHEMA"), let attrsSchema = curStr.asArrayOfDictionary() {
            if let prevAttrStr = PDYStorage.getString(key: "PUSHDY_PREV_ATTRIBUTES_SCHEMA"), prevAttrStr != curStr {
                changed = true
                return changed
            }
            
            for i in 0..<attrsSchema.count {
                let attribute = attrsSchema[i]
                if let name = attribute["name"] as? String/*, let type = attribute["type"] as? String*/ {
                    if let value = PDYStorage.get(key: ATTTRIBUTE_PREFIX+name), let prevValue = PDYStorage.get(key: PREV_ATTTRIBUTE_PREFIX+name) {
                        if value is String {
                            changed = (value as! String) != (prevValue as! String)
                        }
                        else if value is Bool {
                            changed = (value as! Bool) != (prevValue as! Bool)
                        }
                        else if value is Int {
                            changed = (value as! Int) != (prevValue as! Int)
                        }
                        else if value is Double {
                            changed = (value as! Double) != (prevValue as! Double)
                        }
                        else if value is Array<Any> {
                            if prevValue is Array<Any> {
                                if let valueStr = (value as! Array<Any>).jsonString, let prevValueStr = (prevValue as! Array<Any>).jsonString {
                                    changed = valueStr != prevValueStr
                                }
                            }
                        }
                        else if value is Dictionary<String, Any> {
                            if prevValue is Dictionary<String, Any> {
                                if let valueStr = (value as! Dictionary<String, Any>).jsonString, let prevValueStr = (prevValue as! Dictionary<String, Any>).jsonString {
                                    changed = valueStr != prevValueStr
                                }
                            }
                        }
                    }
                }
                
                if changed {
                    break
                }
            }
        }
        
        return changed
    }
    
    internal static func convertAttributesToParams() -> [String:Any]? {
        var params:[String:Any]? = nil
        if let attrsSchema = getAttributesSchema() {
            params = [String:Any]()
            for i in 0..<attrsSchema.count {
                let attribute = attrsSchema[i]
                if let name = attribute["name"] as? String/*, let type = attribute["type"] as? String*/ {
                    if let value = PDYStorage.get(key: ATTTRIBUTE_PREFIX+name) {
                        params![name] = value
                    }
                }
            }
        }
        return params
    }
    
    internal static func setLocalAttribValuesAfterSubmitted() {
        if let attrsSchema = getAttributesSchema() {
            for i in 0..<attrsSchema.count {
                let attribute = attrsSchema[i]
                if let name = attribute["name"] as? String {
                    if let value = PDYStorage.get(key: ATTTRIBUTE_PREFIX+name) {
                        PDYStorage.set(key: PREV_ATTTRIBUTE_PREFIX+name, value: value)
                    }
                }
            }
        }
    }
    
    internal static func addAttributeIntoSchema(_ attribute:[String:Any]) {
        if let curStr = PDYStorage.getString(key: "PUSHDY_ATTRIBUTES_SCHEMA") {
            if var curAttrSchema = curStr.asArrayOfDictionary() {
                var isContain = false
                for i in 0..<curAttrSchema.count {
                    let item = curAttrSchema[i]
                    if let attrName = attribute["name"] as? String, let itemAttrName = item["name"] as? String, attrName == itemAttrName {
                        if let isDefault = attribute["default"] as? Bool {
                            isContain = isDefault != true
                        }
                        else {
                            isContain = true
                        }
                    }
                }
                
                if isContain == false {
                    PDYStorage.setString(key: "PUSHDY_PREV_ATTRIBUTES_SCHEMA", value: curStr)
                    curAttrSchema.append(attribute)
                    
                    if let jsonStr = curAttrSchema.jsonString {
                        PDYStorage.setString(key: "PUSHDY_ATTRIBUTES_SCHEMA", value: jsonStr)
                    }
                }
            }
        }
    }
}
