//
//  PDYNotification.swift
//  PushdyCore
//
//  Created by quandt on 6/26/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation

@objc public class PDYNotification : PDYRequestObject {
    
    override func router() -> String {
        return "/notification"
    }
    
    @objc public func trackOpened(notificationID:String, completion:  PDYRequest.CompletionBlock?, failure: PDYRequest.FailureBlock?) throws {
        let request = PDYRequest()
        try request.put(url: self.url()+"/"+notificationID+"/track", headers: self.headers(), params: nil, completion: { (response:AnyObject?) in
            completion?(response as AnyObject)
        }, failure: { (code:Int, message:String?) in
            failure?(code, message)
        })
    }
}
