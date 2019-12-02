//
//  PDYNotification.swift
//  PushdyCore
//
//  Created by quandt on 6/26/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation

@objc public class PDYNotification : PDYEntity {
    
    override func router() -> String {
        return "/notification"
    }
    
    @objc public func trackOpened(playerID:String?, notificationID:String, completion:  PDYRequest.CompletionBlock?, failure: PDYRequest.FailureBlock?) throws {
        let request = PDYRequest()
        var params:[String: Any] = ["platform": "ios"]
        if playerID != nil {
            params["player_id"] = playerID!
        }
        try request.put(url: self.url()+"/"+notificationID+"/track", headers: self.headers(), params: params, completion: { (response:AnyObject?) in
            completion?(response as AnyObject)
        }, failure: { (code:Int, message:String?) in
            failure?(code, message)
        })
    }
}
