//
//  Swizzling.swift
//  Pushdy
//
//  Created by quandt on 6/28/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation
import UIKit

public extension Pushdy {
    internal static func getClassWithProtocolInHierarchy(_ searchClass : AnyClass, protocolToFind : Protocol) -> AnyClass? {
        
        if !class_conformsToProtocol(searchClass, protocolToFind) {
            if searchClass.superclass() == nil { return nil}
            let foundClass : AnyClass? = getClassWithProtocolInHierarchy(searchClass.superclass()!, protocolToFind: protocolToFind)
            if foundClass != nil { return foundClass}
            return searchClass
        }
        return searchClass
    }
    
    internal static func injectSelector(_ newClass : AnyClass, newSel : Selector, addToClass : AnyClass, makeLikeSel : Selector) {
        var newMeth = class_getInstanceMethod(newClass, newSel)
        let imp = method_getImplementation(newMeth!)
        let methodTypeEncoding = method_getTypeEncoding(newMeth!)
        let successful = class_addMethod(addToClass, makeLikeSel, imp, methodTypeEncoding)
        if !successful {
            class_addMethod(addToClass, newSel, imp, methodTypeEncoding)
            newMeth = class_getInstanceMethod(addToClass, newSel)
            let orgMeth = class_getInstanceMethod(addToClass, makeLikeSel)
            method_exchangeImplementations(orgMeth!, newMeth!)
        }
    }
    
}
