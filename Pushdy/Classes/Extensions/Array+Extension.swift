//
//  Array+Extension.swift
//  Pushdy
//
//  Created by quandt on 8/9/19.
//

import Foundation
extension Array where Element: Any {
//    func asArrayDictionary() throws -> [[String: Any]] {
//        var data: [[String: Any]] = []
//        for element in self {
//            if let itemDict = element as? [String:Any] {
//                data.append(itemDict)
//            }
//        }
//        return data
//    }
//
    var jsonString: String? {
        if let arrayDictionary = (self as AnyObject) as? [[String: Any]] {
            do {
                let data = try JSONSerialization.data(withJSONObject: arrayDictionary, options: .prettyPrinted)
                if let string = String(data: data, encoding: String.Encoding.utf8) {
                    return string
                }
            } catch {
                print("Array jsonString error: \(error)")
            }
        }
        return nil
    }
}

//extension Encodable {
//    func asDictionary() throws -> [String: Any] {
//        let data = try JSONEncoder().encode(self)
//        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
//            throw NSError()
//        }
//        return dictionary
//    }
//}
