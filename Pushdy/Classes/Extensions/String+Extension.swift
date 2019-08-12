//
//  String+Extension.swift
//  Pushdy
//
//  Created by quandt on 8/9/19.
//

import Foundation

@objc extension String {
    func asArrayOfDictionary() -> [[String:Any]]? {
        if let objData = self.data(using: String.Encoding.utf8) {
            let jsonObj = try? JSONSerialization.jsonObject(with: objData, options: JSONSerialization.ReadingOptions.mutableContainers)
            return jsonObj as? [[String:Any]]
        }
        return nil
    }
}
