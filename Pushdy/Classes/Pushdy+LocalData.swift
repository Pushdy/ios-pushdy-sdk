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
    internal static let CHANGED_ATTRIBUTES_STACK = "PUSHDY_CHANGED_ATTRIBUTES_STACK"
    internal static let ATTRIBUTES_SCHEMA = "PUSHDY_ATTRIBUTES_SCHEMA"
    internal static let PREV_ATTRIBUTES_SCHEMA = "PUSHDY_PREV_ATTRIBUTES_SCHEMA"
    
    
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
    @objc static func getPlayerID() -> String? {
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
        if let deviceID = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+PDYParam.DeviceID) {
            return deviceID
        }
        return PDYDeviceInfo.deviceID()
    }
    
    /**
     Set device id instead of Pushdy's device id
     
     */
    @objc static func setDeviceID(_ deviceID:String) {
        _deviceID = deviceID
        if let prevDeviceID = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+PDYParam.DeviceID) {
            PDYStorage.setString(key: PREV_ATTTRIBUTE_PREFIX+PDYParam.DeviceID, value: prevDeviceID)
        }
        PDYStorage.setString(key: ATTTRIBUTE_PREFIX+PDYParam.DeviceID, value: deviceID)
    }
    
    /**
     Set device token
     
     */
    internal static func setDeviceToken(_ token:String) {
        NSLog("deviceToken %@", token);
        if let prevToken = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+PDYParam.DeviceToken) {
            PDYStorage.setString(key: PREV_ATTTRIBUTE_PREFIX+PDYParam.DeviceToken, value: prevToken)
        }
        PDYStorage.setString(key: ATTTRIBUTE_PREFIX+PDYParam.DeviceToken, value: token)
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
        if let token = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+PDYParam.DeviceToken) {
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
        if let version = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+PDYParam.AppVersion) {
            
            return version
        }
        return nil
    }
    
    /**
     Set application version
    
     */
    @objc static func setAppVersion(_ version:String) {
        if let prevAppVersion = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+PDYParam.AppVersion) {
            PDYStorage.setString(key: PREV_ATTTRIBUTE_PREFIX+PDYParam.AppVersion, value: prevAppVersion)
        }
        PDYStorage.setString(key: ATTTRIBUTE_PREFIX+PDYParam.AppVersion, value: version)
    }
    
    /**
     Get language
     
     - Returns: A language string
     */
    @objc static func getLanguage() -> String? {
        if let lang = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+PDYParam.Language) {
            return lang
        }
        return nil
    }
    
    /**
     Set language
     */
    @objc static func setLanguage(_ lang:String) {
        if let prevLanguage = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+PDYParam.Language) {
            PDYStorage.setString(key: PREV_ATTTRIBUTE_PREFIX+PDYParam.Language, value: prevLanguage)
        }
        PDYStorage.setString(key: ATTTRIBUTE_PREFIX+PDYParam.Language, value: lang)
    }
    
    /**
     Get country
     
     - Returns: A country value
     */
    @objc static func getCountry() -> String? {
        if let country = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+PDYParam.Country) {
            return country
        }
        return nil
    }
    
    /**
     Set country
     */
    @objc static func setCountry(_ country:String) {
        if let prevCountry = PDYStorage.getString(key: ATTTRIBUTE_PREFIX+PDYParam.Country) {
            PDYStorage.setString(key: PREV_ATTTRIBUTE_PREFIX+PDYParam.Country, value: prevCountry)
        }
        PDYStorage.setString(key: ATTTRIBUTE_PREFIX+PDYParam.Country, value: country)
    }
    
    internal static func setFetchedAttributes(_ fetched:Bool) {
        PDYStorage.setBool(key: "PUSHDY_FETCHED_ATTRIBUTES", value:fetched)
    }
    
    internal static func isFetchedAttributes() -> Bool {
        return true
        //var fetchedAttributes = false
        //if let fetched = PDYStorage.getBool(key: "PUSHDY_FETCHED_ATTRIBUTES") {
        //    fetchedAttributes = fetched
        //}
        //return fetchedAttributes
    }
    
    internal static func setAttributesSchema(_ attributes:[[String:Any]]) {
        if let jsonStr = attributes.jsonString {
            if let currentJsonStr = PDYStorage.getString(key: ATTRIBUTES_SCHEMA) {
                PDYStorage.setString(key: PREV_ATTRIBUTES_SCHEMA, value: currentJsonStr)
            }
            PDYStorage.setString(key: ATTRIBUTES_SCHEMA, value: jsonStr)
        }
    }
    
    internal static func getAttributesSchema() -> [[String:Any]]? {
        if let jsonStr = PDYStorage.getString(key: ATTRIBUTES_SCHEMA) {
            return jsonStr.asArrayOfDictionary()
        } else {
            PDYStorage.setString(key: ATTRIBUTES_SCHEMA, value: ###"[{"name":"device_name","type":"string","label":"Device Name","default":false},{"name":"network_carrier","type":"string","label":"Network Carrier","default":false},{"name":"registered_at","type":"number","label":"Registered Date","default":false},{"name":"pv_schedule","type":"number","label":"Số lần xem mục Lịch đấu","default":false},{"name":"pv_highlight_video","type":"number","label":"Số lần xem mục Video highlight","default":false},{"name":"device_type","type":"string","label":"Device Type","default":true},{"name":"device_id","type":"string","label":"Device Id","default":true},{"name":"device_token","type":"string","label":"Device Token","default":true},{"name":"device_os","type":"string","label":"Device Os","default":true},{"name":"device_model","type":"string","label":"Device Model","default":true},{"name":"app_version","type":"string","label":"App Version","default":true},{"name":"mobile_number","type":"string","label":"Mobile Number","default":true},{"name":"language","type":"string","label":"Language","default":true},{"name":"country","type":"string","label":"Country","default":true},{"name":"name","type":"string","label":"Name","default":true},{"name":"gender","type":"string","label":"Gender","default":true},{"name":"custom_user_id","type":"string","label":"Custom User_id","default":true},{"name":"utm_source","type":"array","label":"Utm Source","default":true},{"name":"utm_campaign","type":"array","label":"Utm Campaign","default":true},{"name":"utm_medium","type":"array","label":"Utm Medium","default":true},{"name":"utm_term","type":"array","label":"Utm Term","default":true},{"name":"utm_content","type":"array","label":"Utm Content","default":true}]"###)

            if let jsonStr2 = PDYStorage.getString(key: ATTRIBUTES_SCHEMA) {
                return jsonStr2.asArrayOfDictionary()
            }
        }
        return nil
    }
    
    internal static func isAttributeChanged(_ name:String, newValue value:Any) -> Bool {
        var changed:Bool = false
        if let value = getAttributeValue(name) {
            if let prevValue = getPrevAttributeValue(name) {
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
            else {
                changed = true
            }
        }
        else {
            changed = true
        }
        return changed
    }
    
    /** Old detect change method
    internal static func attributesHasChanged() -> Bool {
        var changed = false
        if let curStr = PDYStorage.getString(key: ATTRIBUTES_SCHEMA), let attrsSchema = curStr.asArrayOfDictionary() {
            if let prevAttrStr = PDYStorage.getString(key: PREV_ATTRIBUTES_SCHEMA), prevAttrStr != curStr {
                changed = true
                return changed
            }
            
            for i in 0..<attrsSchema.count {
                let attribute = attrsSchema[i]
                if let name = attribute["name"] as? String/*, let type = attribute["type"] as? String*/ {
                    if let value = PDYStorage.get(key: ATTTRIBUTE_PREFIX+name) {
                        if let prevValue = PDYStorage.get(key: PREV_ATTTRIBUTE_PREFIX+name) {
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
                        else {
                            changed = true
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
    **/
    internal static func attributesHasChanged() -> Bool {
        var changed = false
        if let changedStack = getChangedStack() {
            changed = !changedStack.isEmpty
        }
        return changed
    }
    
    /** Old convertAttributesToParams
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
    **/
    internal static func convertAttributesToParams() -> [String:Any]? {
        if let changedStack = getChangedStack() {
            var params:[String:Any] = [String:Any]()
            for (key, value) in changedStack {
                let isValidType = isValidAttributeType(key, value: value)
                if isValidType {
                    params[key] = value
                }
            }
            return params
        }
        return nil
    }
    
    internal static func clearChangedStack() {
        PDYStorage.remove(key: CHANGED_ATTRIBUTES_STACK)
    }
    
    internal static func getChangedStack() -> [String:Any]? {
        return PDYStorage.get(key: CHANGED_ATTRIBUTES_STACK) as? [String:Any]
    }
    
    internal static func pushToChangedStack(_ name:String, value:Any) {
        // Don't check valid when push into stack, will check when submit
//        let isValidType = isValidAttributeType(name, value: value)
//        if isValidType == false { return }
//
        var changedStack:[String:Any]?
        if var stack = PDYStorage.get(key: CHANGED_ATTRIBUTES_STACK) as? [String:Any] {
            changedStack = stack
        }
        else {
            changedStack = [String:Any]()
        }
        changedStack?[name] = value
        PDYStorage.set(key: CHANGED_ATTRIBUTES_STACK, value: changedStack!)
    }
    
    internal static func hasAttribute(_ name:String) -> [String:Any]? {
        var attribute:[String:Any]?
        if let curStr = PDYStorage.getString(key: ATTRIBUTES_SCHEMA) {
            if var curAttrSchema = curStr.asArrayOfDictionary() {
                for i in 0..<curAttrSchema.count {
                    let item = curAttrSchema[i]
                    if let itemAttrName = item["name"] as? String, name == itemAttrName {
                        attribute = item
                    }
                    if attribute != nil { break }
                }
            }
        }
        return attribute
    }
    
    internal static func isValidAttributeType(_ name:String, value:Any) -> Bool {
        var isValid = false
        if let attribute = hasAttribute(name), let type = attribute["type"] as? String {
            if (type == AttributeType.kString && value is String) ||
                (type == AttributeType.kArray && value is Array<Any>) ||
                (type == AttributeType.kNumber && (value is Int || value is Double)) ||
                (type == AttributeType.kBoolean && value is Bool) {
                isValid = true
            }
        }
        return isValid
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
        if let curStr = PDYStorage.getString(key: ATTRIBUTES_SCHEMA) {
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
                    PDYStorage.setString(key: PREV_ATTRIBUTES_SCHEMA, value: curStr)
                    curAttrSchema.append(attribute)
                    
                    if let jsonStr = curAttrSchema.jsonString {
                        PDYStorage.setString(key: ATTRIBUTES_SCHEMA, value: jsonStr)
                    }
                }
            }
        }
    }
    
    internal static func getAttributeValue(_ name:String) -> Any? {
        return PDYStorage.get(key: ATTTRIBUTE_PREFIX+name)
    }
    
    internal static func setAttributeValue(_ name:String, value:Any) {
        return PDYStorage.set(key: ATTTRIBUTE_PREFIX+name, value: value)
    }
    
    internal static func getPrevAttributeValue(_ name:String) -> Any? {
        return PDYStorage.get(key: PREV_ATTTRIBUTE_PREFIX+name)
    }
    
    internal static func setPrevAttributeValue(_ name:String, value:Any) {
        return PDYStorage.set(key: PREV_ATTTRIBUTE_PREFIX+name, value: value)
    }
    
    
}
