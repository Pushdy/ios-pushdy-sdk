//
//  Dictionary+Extension.swift
//  Pushdy
//
//  Created by quandt on 8/9/19.
//

import Foundation

@objc extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    var jsonString: String? {
        if let dict = (self as AnyObject) as? [String:Any] {
            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                if let string = String(data: data, encoding: String.Encoding.utf8) {
                    return string
                }
            } catch {
                print("Dictionary jsonString error: \(error)")
            }
        }
        return nil
    }
}
