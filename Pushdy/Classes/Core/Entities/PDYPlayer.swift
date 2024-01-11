//
//  PDYPlayer.swift
//  Pushdy
//
//  Created by quandt on 6/26/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation

@objc public class PDYPlayer : PDYEntity {
    
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

    // TODO: Throw error
    @objc public func trackOpened(playerID:String?, notificationIds:[String], completion:  PDYRequest.CompletionBlock?, failure: PDYRequest.FailureBlock?) throws {
      if notificationIds.isEmpty {
        print("ERROR: PDYNotification: notificationIDs list is empty")
        return
      }
      if playerID == nil {
        print("ERROR: PDYNotification: playerID isBlank")
        return
      }
      
      let request = PDYRequest()
      let params:[String: Any] = [
        "platform": "ios",
        "notifications": notificationIds,
      ]
    
      let reqUrl = try self.url() + "/" + playerID! + "/track"
      try request.put(url: reqUrl, headers: self.headers(), params: params, completion: { (response:AnyObject?) in
          completion?(response as AnyObject)
      }, failure: { (code:Int, message:String?) in
          failure?(code, message)
      })
    }
    
    @objc public func subscribe(applicationID: String?, playerID: String?, completion:  PDYRequest.CompletionBlock?, failure: PDYRequest.FailureBlock? ) throws {
        if applicationID == nil {
          print("ERROR: PDYNotification: applicationID list is empty")
          return
        }
        if playerID == nil {
          print("ERROR: PDYNotification: playerID isBlank")
          return
        }
        let request = PDYRequest()
        let reqUrl = try self.baseUrl() + "/application/" + applicationID! + "/player/" + playerID! + "/subscribe"
        let params:[String: Any] = [:]
        NSLog("[Pushdy] subscribe: \(reqUrl)")
        try request.post(url: reqUrl, headers: self.headers(), params: params, completion: { (response:AnyObject?) in
            completion?(response as AnyObject)
        }, failure: { (code:Int, message:String?) in
            failure?(code, message)
        })
    }

    @objc public func trackBanner(applicationId: String?, playerID: String?, data: Any?, completion:  PDYRequest.CompletionBlock?, failure: PDYRequest.FailureBlock? ) throws {
        let request = PDYRequest();
        let reqUrl = try self.baseUrl() + "/application/" + applicationId! + "/player/" + playerID! + "/subscribe"
        try request.post(url: reqUrl, headers: self.headers(), params: data, completion: { (response:AnyObject?) in
            completion?(response as AnyObject)
        }, failure: { (code:Int, message:String?) in
            failure?(code, message)
        })
    }
}
