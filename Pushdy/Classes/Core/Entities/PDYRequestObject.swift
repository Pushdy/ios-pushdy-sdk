//
//  PDYObject.swift
//  PushdyCore
//
//  Created by quandt on 6/26/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation

@objc public class PDYRequestObject : NSObject {
    var clientKey:String?
    var deviceID:String?
    
    private override init() {
        
    }
    
    @objc public init(clientKey:String, deviceID:String?) {
        self.clientKey = clientKey
        self.deviceID = deviceID
    }
    
    @objc public convenience init(clientKey:String) {
        self.init(clientKey:clientKey, deviceID:nil)
    }
    
    func url() throws -> String {
        return try self.baseUrl()+self.router()
    }
    
    func baseUrl() throws -> String {
        return "https://api.pushdi.com"
//        var bundle:Bundle?
//        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
//            bundle = Bundle(for: type(of: self))
//        }
//        else {
//            bundle = Bundle(identifier: "com.pushdy.PushdySDK")
//        }
//        
//        if let _ = bundle {
//            let config = PDYPlist(bundle!.infoDictionary)
//            if let url = config["BASE_API_URL"].string {
//                return url
//            } else {
//                let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "\(NSStringFromClass(type(of: self))):\(#function):: BASE_API_URL not set. Please set configuration first"])
//                throw error
//            }
//        }
//        
//        let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "\(NSStringFromClass(type(of: self))):\(#function):: No bundle found"])
//        throw error
    }
    
    func router() -> String {
        return ""
    }
    
    func headers() throws -> [String:String] {
        if let clientKey = self.clientKey {
            return [PDYParam.ClientKey : clientKey]
        } else {
            let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "\(NSStringFromClass(type(of: self))):\(#function):: client-key is not set. Please set configuration first"])
            throw error
        }
        
    }
    
    func defaultParams() -> [String:Any] {
        var params = [
            PDYParam.AppVersion : PDYDeviceInfo.appVersion(),
            PDYParam.DeviceModel : PDYDeviceInfo.deviceModel(),
            PDYParam.DeviceType : PDYDeviceInfo.deviceType(),
            PDYParam.DeviceOS : PDYDeviceInfo.deviceOS(),
            PDYParam.Platform : PDYDeviceInfo.platform(),
            PDYParam.DeviceID : self.deviceID ?? PDYDeviceInfo.deviceID()
        ]
        
        if let country  = PDYDeviceInfo.country() {
            params[PDYParam.Country] = country
        }
        
        if let language = PDYDeviceInfo.language() {
            params[PDYParam.Language] = language
        }
        
        return params
    }
    
    
}
