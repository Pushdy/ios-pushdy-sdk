//
//  PDYDeviceInfo.swift
//  PushdyCore
//
//  Created by quandt on 6/26/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation
import UIKit

public class PDYDeviceInfo {
    public static func deviceID() -> String {
        if let uuid = PDYUUIDGenerator.shared.uuid() {
            return uuid
        }
        return ""
    }
    
    public static func deviceType() -> String {
        return "ios"
    }
    
    public static func platform() -> String {
        return "ios"
    }
    
    public static func appVersion() -> String {
        var bundle:Bundle?
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            bundle = Bundle(for:  self)
        }
        else {
            bundle = Bundle.main
        }
        if let dictionary = bundle?.infoDictionary {
            if let version = dictionary["CFBundleShortVersionString"] as? String {
                return version
            }
        }
        return "1.0"
    }
    
    public static func deviceOS() -> String {
        return UIDevice.current.systemVersion
    }
    
    public static func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    
    public static func language() -> String? {
        return Locale.current.languageCode
    }
    
    public static func country() -> String? {
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            return countryCode
        }
        return nil
    }
    
    
    
}
