//
//  PDYPlist.swift
//  PushdyCore
//
//  Created by quandt on 6/26/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation

internal enum PDYPlist {
    
    case dictionary(NSDictionary)
    case Array(NSArray)
    case Value(Any)
    case none
    
    public init(_ dict: NSDictionary) {
        self = .dictionary(dict)
    }
    
    public init(_ array: NSArray) {
        self = .Array(array)
    }
    
    public init(_ value: Any?) {
        self = PDYPlist.wrap(value)
    }
    
}


// MARK:- initialize from a path
extension PDYPlist {
    
    public init(path: String) {
        if let dict = NSDictionary(contentsOfFile: path) {
            self = .dictionary(dict)
        }
        else if let array = NSArray(contentsOfFile: path) {
            self = .Array(array)
        }
        else {
            self = .none
        }
    }
    
}


// MARK:- private helpers
extension PDYPlist {
    
    /// wraps a given object to a Plist
    fileprivate static func wrap(_ object: Any?) -> PDYPlist {
        
        if let dict = object as? NSDictionary {
            return .dictionary(dict)
        }
        if let array = object as? NSArray {
            return .Array(array)
        }
        if let value = object {
            return .Value(value)
        }
        return .none
    }
    
    /// tries to cast to an optional T
    fileprivate func cast<T>() -> T? {
        switch self {
        case let .Value(value):
            return value as? T
        default:
            return nil
        }
    }
}

// MARK:- subscripting
extension PDYPlist {
    
    /// index a dictionary
    public subscript(key: String) -> PDYPlist {
        switch self {
            
        case let .dictionary(dict):
            let v = dict.object(forKey: key)
            return PDYPlist.wrap(v)
            
        default:
            return .none
        }
    }
    
    /// index an array
    public subscript(index: Int) -> PDYPlist {
        switch self {
        case let .Array(array):
            if index >= 0 && index < array.count {
                return PDYPlist.wrap(array[index])
            }
            return .none
            
        default:
            return .none
        }
    }
    
}


// MARK:- Value extraction
extension PDYPlist {
    
    public var string: String?       { return cast() }
    public var int: Int?             { return cast() }
    public var double: Double?       { return cast() }
    public var float: Float?         { return cast() }
    public var date: Date?         { return cast() }
    public var data: Data?         { return cast() }
    public var number: NSNumber?     { return cast() }
    public var bool: Bool?           { return cast() }
    
    
    // unwraps and returns the underlying value
    public var value: Any? {
        switch self {
        case let .Value(value):
            return value
        case let .dictionary(dict):
            return dict
        case let .Array(array):
            return array
        case .none:
            return nil
        }
    }
    
    // returns the underlying array
    public var array: NSArray? {
        switch self {
        case let .Array(array):
            return array
        default:
            return nil
        }
    }
    
    // returns the underlying dictionary
    public var dict: NSDictionary? {
        switch self {
        case let .dictionary(dict):
            return dict
        default:
            return nil
        }
    }
    
}


// MARK:- CustomStringConvertible
extension PDYPlist : CustomStringConvertible {
    public var description:String {
        switch self {
        case let .Array(array): return "(array \(array))"
        case let .dictionary(dict): return "(dict \(dict))"
        case let .Value(value): return "(value \(value))"
        case .none: return "(none)"
        }
    }
}
