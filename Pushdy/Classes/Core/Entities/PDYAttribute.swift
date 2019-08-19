//
//  PDYAttribute.swift
//  PushdyCore
//
//  Created by quandt on 6/26/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation

@objc public class AttributeType : NSObject {
    public static let kBoolean:String = "boolean"
    public static let kArray:String = "array"
    public static let kString:String = "string"
    public static let kNumber:String = "number"
    
    private override init() {
        
    }
}

@objc public class PDYAttribute : PDYRequestObject {
    
    public var types:[String] = [
        AttributeType.kBoolean,
        AttributeType.kString,
        AttributeType.kArray,
        AttributeType.kNumber
    ]
    
    override func router() -> String {
        return "/attribute"
    }
    
    @objc public func get(completion:  PDYRequest.CompletionBlock?, failure: PDYRequest.FailureBlock?) throws {
        let request = PDYRequest()
        try request.get(url: self.url(), headers: self.headers(), params: nil, completion: { (response:AnyObject?) in
            completion?(response as AnyObject)
        }, failure: { (code:Int, message:String?) in
            failure?(code, message)
        })
    }
    
    @objc public func add(name:String, type:String, label:String?, completion:  PDYRequest.CompletionBlock?, failure: PDYRequest.FailureBlock?) throws {
        if !self.types.contains(type) {
            let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "The \"type\" parameter is not valid"])
            throw error
        }
        var params:[String:Any] = [
            PDYParam.Name: name,
            PDYParam.Typee: type
        ]
        if let _ = label {
            params[PDYParam.Label] = label!
        }
        
        let newParams = self.defaultParams().merging(params) { (_, new) in new }
        
        let request = PDYRequest()
        try request.post(url: self.url(), headers: self.headers(), params: newParams, completion: { (response:AnyObject?) in
            completion?(response as AnyObject)
        }, failure: { (code:Int, message:String?) in
            failure?(code, message)
        })
    }
    
    @objc public func edit(name:String, newName:String?, label:String?, completion:  PDYRequest.CompletionBlock?, failure: PDYRequest.FailureBlock?) throws {
        var params:[String:Any] = [
            PDYParam.Name: name
        ]
        if let _ = newName {
            params[PDYParam.NewName] = newName!
        }
        if let _ = label {
            params[PDYParam.Label] = label!
        }
        let newParams = self.defaultParams().merging(params) { (_, new) in new }
        let request = PDYRequest()
        try request.put(url: self.url(), headers: self.headers(), params: newParams, completion: { (response:AnyObject?) in
            completion?(response as AnyObject)
        }, failure: { (code:Int, message:String?) in
            failure?(code, message)
        })
    }
    
    @objc public func delete(name:String, completion:  PDYRequest.CompletionBlock?, failure: PDYRequest.FailureBlock?) throws {
        let params:[String:Any] = [
            PDYParam.Name: name
        ]
        let newParams = self.defaultParams().merging(params) { (_, new) in new }
        let request = PDYRequest()
        try request.delete(url: self.url(), headers: self.headers(), params: newParams, completion: { (response:AnyObject?) in
            completion?(response as AnyObject)
        }, failure: { (code:Int, message:String?) in
            failure?(code, message)
        })
    }
}
