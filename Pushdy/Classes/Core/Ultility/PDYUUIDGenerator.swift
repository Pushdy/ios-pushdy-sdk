//
//  PDYDeviceUUID.swift
//  Pushdy
//
//  Created by quandt on 6/27/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation
import UIKit
import AdSupport

public class PDYUUIDGenerator {
    var _uuid:String?
    let _uuidKey = "PDYUUIDGenerator_Device_UUID"
    let _userDefauls:UserDefaults = UserDefaults.standard
  
    public static let shared: PDYUUIDGenerator = {
        let instance = PDYUUIDGenerator()
        return instance
    }()
    
    public func uuid() -> String? {
        if (!isValidUUID()) {
            generate()
        }
        return _uuid
    }
    
    func isValidUUID() -> Bool {
        if _uuid == nil || (_uuid != nil && _uuid!.isEmpty) || (_uuid != nil && _uuid!.lowercased() == "unknown") {
            return false
        }
        return true
    }
    
    init() {
        generate()
    }
    
    func generate() {
        // Generate uuid
        _uuid = self.get(key: _uuidKey)
        if (!isValidUUID()) { _uuid = PDYKeychain.getString(key: _uuidKey) }
        if (!isValidUUID()) { _uuid = appleIFV() }
        if (!isValidUUID()) { _uuid = appleIFA() }
        if (!isValidUUID()) { _uuid = randomUUID() }
        
        // Save to userdefault & keychain
        if (isValidUUID()) {
            saveUUID()
        }
    }
    
    // --- Get UUID --- //
    func randomUUID() -> String? {
        return UUID().uuidString
    }
    
    func appleIFA() -> String? {
        var strIDFA : String?
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            strIDFA = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        return strIDFA
    }
    
    func appleIFV() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    // --- User default --- //
    func get(key:String) -> String? {
        return _userDefauls.value(forKey: key) as? String
    }
    
    func set(key:String, value:String) {
        _userDefauls.set(key, forKey: value)
        _userDefauls.synchronize()
    }
    
    // --- Save --- //
    func saveUUID() {
        set(key: _uuidKey, value: _uuid!)
        PDYKeychain.setString(key: _uuidKey, value: _uuid!)
    }
}
