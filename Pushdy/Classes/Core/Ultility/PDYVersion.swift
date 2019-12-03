//
//  PDYVersion.swift
//  Pushdy
//
//  Created by quandt on 10/3/18.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import UIKit

@objc public class PDYVersion : NSObject {
    @objc public class func equal(_ version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,
                                                              options: NSString.CompareOptions.numeric) == ComparisonResult.orderedSame
    }
    
    @objc public class func greaterThan(_ version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,
                                                              options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending
    }
    
    @objc public class func greaterThanOrEqual(_ version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,
                                                              options: NSString.CompareOptions.numeric) != ComparisonResult.orderedAscending
    }
    
    @objc public class func lessThan(_ version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,
                                                              options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending
    }
    
    @objc public class func lessThanOrEqual(_ version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,
                                                              options: NSString.CompareOptions.numeric) != ComparisonResult.orderedDescending
    }
}
