//
//  PDYKeychain.swift
//  Pushdy
//
//  Created by quandt on 6/27/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation
import Security

let kSecClassGenericPasswordValue = String(format: kSecClassGenericPassword as String)
let kSecClassValue = String(format: kSecClass as String)
let kSecAttrServiceValue = String(format: kSecAttrService as String)
let kSecValueDataValue = String(format: kSecValueData as String)
let kSecMatchLimitValue = String(format: kSecMatchLimit as String)
let kSecReturnDataValue = String(format: kSecReturnData as String)
let kSecMatchLimitOneValue = String(format: kSecMatchLimitOne as String)
let kSecAttrAccountValue = String(format: kSecAttrAccount as String)

public class PDYKeychain {
    public class func setString(key: String, value: String) {
        if let dataFromString = value.data(using: String.Encoding.utf8) {
            let keychainQuery = [
                kSecClassValue: kSecClassGenericPasswordValue,
                kSecAttrServiceValue: key,
                kSecValueDataValue: dataFromString
                ] as CFDictionary
            SecItemDelete(keychainQuery)
            SecItemAdd(keychainQuery, nil)
        }
    }
    
    public class func getString(key: String) -> String? {
        let keychainQuery = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: key,
            kSecReturnDataValue: kCFBooleanTrue,
            kSecMatchLimitValue: kSecMatchLimitOneValue
            ] as  CFDictionary
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var passcode: String?
        if (status == errSecSuccess) {
            if let retrievedData = dataTypeRef as? Data,
                let result = String(data: retrievedData, encoding: String.Encoding.utf8) {
                passcode = result as String
            }
        }
        else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        return passcode
    }
    
    public class func getBool(key:String) -> Bool? {
        if let value = getString(key: key), let nsValue = value as? NSString {
            return nsValue.boolValue
        }
        return nil
    }
    
    public class func setBool(key:String, value:Bool) {
        let valueStr = String(value)
        setString(key: key, value: valueStr)
    }
    
    public class func getInt(key:String) -> Int? {
        if let value = getString(key: key), let nsValue = value as? NSString {
            return nsValue.integerValue
        }
        return nil
    }
    
    public class func setInt(key:String, value:Int) {
        let valueStr = String(value)
        setString(key: key, value: valueStr)
    }
    
    public class func getDouble(key:String) -> Double? {
        if let value = getString(key: key), let nsValue = value as? NSString {
            return nsValue.doubleValue
        }
        return nil
    }
    
    public class func setDouble(key:String, value:Double) {
        let valueStr = String(value)
        setString(key: key, value: valueStr)
    }
    
    public class func getFloat(key:String) -> Float? {
        if let value = getString(key: key), let nsValue = value as? NSString {
            return nsValue.floatValue
        }
        return nil
    }
    
    public class func setFloat(key:String, value:Float) {
        let valueStr = String(value)
        setString(key: key, value: valueStr)
    }
    
    
}
