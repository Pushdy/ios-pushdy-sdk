//
//  PDYStorage.swift
//  Pushdy
//
//  Created by quandt on 6/27/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation

@objc public class PDYStorage : NSObject {
    public static func get(key:String) -> Any? {
        if let value = UserDefaults.standard.object(forKey: key) {
            return value
        }
        return nil
    }
    
    public static func set(key:String, value:Any) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public static func getBool(key:String, includeInKeyChain:Bool = false) -> Bool? {
        if let value = UserDefaults.standard.object(forKey: key), let boolValue = value as? Bool {
            return boolValue
        }
        
        if includeInKeyChain {
            return PDYKeychain.getBool(key: key)
        }
        return nil
    }
    
    public static func setBool(key:String, value:Bool, includeInKeyChain:Bool = false) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        
        if includeInKeyChain {
            PDYKeychain.setBool(key: key, value: value)
        }
    }
    
    public static func getInt(key:String, includeInKeyChain:Bool = false) -> Int? {
        if let value = UserDefaults.standard.object(forKey: key), let intValue = value as? Int {
            return intValue
        }
        if includeInKeyChain {
            return PDYKeychain.getInt(key: key)
        }
        return nil
    }
    
    public static func setInt(key:String, value:Int, includeInKeyChain:Bool = false) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        
        if includeInKeyChain {
            PDYKeychain.setInt(key: key, value: value)
        }
    }
    
    public static func getDouble(key:String, includeInKeyChain:Bool = false) -> Double? {
        if let value = UserDefaults.standard.object(forKey: key), let doubleValue = value as? Double {
            return doubleValue
        }
        
        if includeInKeyChain {
            return PDYKeychain.getDouble(key: key)
        }
        return nil
    }
    
    public static func setDouble(key:String, value:Double, includeInKeyChain:Bool = false) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        
        if includeInKeyChain {
            PDYKeychain.setDouble(key: key, value: value)
        }
    }
    
    public static func getFloat(key:String, includeInKeyChain:Bool = false) -> Float? {
        if let value = UserDefaults.standard.object(forKey: key), let floatValue = value as? Float {
            return floatValue
        }
        if includeInKeyChain {
            return PDYKeychain.getFloat(key: key)
        }
        return nil
    }
    
    public static func setFloat(key:String, value:Float, includeInKeyChain:Bool = false) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        
        if includeInKeyChain {
            PDYKeychain.setFloat(key: key, value: value)
        }
    }
    
    public static func getString(key:String, includeInKeyChain:Bool = false) -> String? {
        if let value = UserDefaults.standard.object(forKey: key), let stringValue = value as? String {
            return stringValue
        }
        
        if includeInKeyChain {
            return PDYKeychain.getString(key: key)
        }
        return nil
    }
    
    public static func setString(key:String, value:String, includeInKeyChain:Bool = false) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        
        if includeInKeyChain {
            PDYKeychain.setString(key: key, value: value)
        }
    }
}
