//
//  PDYPlayer.swift
//  PushdyCore
//
//  Created by quandt on 6/26/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation

@objc public class PDYPlayer : PDYRequestObject {
    
    override func router() -> String {
        return "/player"
    }
    
    @objc public func add(params:[String:Any]?, completion:  PDYRequest.CompletionBlock?, failure: PDYRequest.FailureBlock?) throws {
        let request = PDYRequest()
        let newParams = params != nil ? self.defaultParams().merging(params!) { (_, new) in new } : self.defaultParams()
        try request.post(url: self.url(), headers: self.headers(), params: newParams, completion: { (response:AnyObject?) in
            completion?(response as AnyObject)
        }, failure: { (code:Int, message:String?) in
            failure?(code, message)
        })
    }
    
    @objc public func edit(playerID:String, params:[String:Any], completion:  PDYRequest.CompletionBlock?, failure: PDYRequest.FailureBlock?) throws {
        let request = PDYRequest()
        try request.put(url: self.url()+"/"+playerID, headers: self.headers(), params: params, completion: { (response:AnyObject?) in
            completion?(response as AnyObject)
        }, failure: { (code:Int, message:String?) in
            failure?(code, message)
        })
    }
    
    @objc public func newSession(playerID:String, completion:  PDYRequest.CompletionBlock?, failure: PDYRequest.FailureBlock?) throws {
        let request = PDYRequest()
        try request.post(url: self.url()+"/"+playerID+"/on_session", headers: self.headers(), params: nil, completion: { (response:AnyObject?) in
            completion?(response as AnyObject)
        }, failure: { (code:Int, message:String?) in
            failure?(code, message)
        })
    }
}
