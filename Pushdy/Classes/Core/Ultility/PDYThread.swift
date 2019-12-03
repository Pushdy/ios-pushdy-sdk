//
//  PDYThread.swift
//  Pushdy
//
//  Created by quandt on 6/27/17.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import UIKit

@objc public class PDYThread: NSObject {
    public typealias ExecuteBlock = () -> Void
    
    @objc public class func perform(onBackGroundThread bgBlock: ExecuteBlock?, then uiBlock: ExecuteBlock?) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Do background tasks
            bgBlock?()
            
            // Do ui tasks
            DispatchQueue.main.async {
                uiBlock?()
            }
        }
    }
    
    @objc public class func perform(onUIThread uiBlock:@escaping ExecuteBlock) {
        // Do ui tasks
        DispatchQueue.main.async {
            uiBlock()
        }
    }
    
    @objc public class func perform(onBackgroundThread bgBlock:@escaping ExecuteBlock) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Do background tasks
            bgBlock()
        }
    }
    
    @objc public class func perform(onBackGroundThread bgBlock: ExecuteBlock?, after delay:Double, then uiBlock: ExecuteBlock?) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline:.now() + delay) {
            // Do background tasks
            bgBlock?()
            
            // Do ui tasks
            DispatchQueue.main.async {
                uiBlock?()
            }
        }
    }
    
    @objc public class func perform(onBackGroundThread bgBlock: ExecuteBlock?, after delay:Double) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline:.now() + delay) {
            // Do background tasks
            bgBlock?()
        }
    }
    
}
