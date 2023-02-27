//
//  PDYEvent.swift
//  Pushdy
//
//  Created by tanpm on 2/24/23.
//  Copyright © 2023 Pushdy. All rights reserved.
//

import Foundation

@objc public class PDYEvent : PDYEntity {
    static var DEBUG: Bool = false
    static var LOG_TAG: String = "PDYEvent"
    
    override func router() -> String {
        return "/track"
    }

    @objc public func pushPendingEvents(events: [NSObject], application_id: String, playerID: String?, completion:  PDYRequest.CompletionBlock?, failure: PDYRequest.FailureBlock?) throws {
        let request = PDYRequest()

        let params:[String: Any] = [
            "events": events,
            "application_id": application_id
            
        ]
        if PDYEvent.DEBUG {
            print("\(PDYEvent.LOG_TAG): pushPendingEvents: events: \(events)")
        }
        
        if PDYEvent.DEBUG {
            print("\(PDYEvent.LOG_TAG): pushPendingEvents: events: \(params), \(application_id) to \(try self.url())")
        }
        
        let newParams = self.defaultParams().merging(params) { (_, new) in new }
        if PDYEvent.DEBUG {
            print("\(PDYEvent.LOG_TAG): pushPendingEvents: newParams: \(newParams), \(application_id) to \(try self.url())")
        }

        try request.post(url: self.url(), headers: self.headers(), params: newParams, completion: { (response:AnyObject?) in
            completion?(response as AnyObject)
        }, failure: { (code:Int, message:String?) in
            failure?(code, message)
        })
    }
}
