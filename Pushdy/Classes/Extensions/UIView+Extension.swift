//
//  UIView+Extension.swift
//  Pushdy
//
//  Created by quandt on 6/26/17.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import UIKit

@objc extension UIView {
    @available(iOS 9.0, *)
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }
    
    @available(iOS 9.0, *)
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }else {
            return self.leftAnchor
        }
    }
    
    @available(iOS 9.0, *)
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }else {
            return self.rightAnchor
        }
    }
    
    @available(iOS 9.0, *)
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
    
    class func instantiate(forClass: AnyClass) -> UIView {
        let bundle = Bundle(for: forClass)
        return instantiate(forClass: forClass, bundle: bundle)
    }
    
    class func instantiate(forClass: AnyClass, bundle:Bundle?) -> UIView {
        let xibName = String(describing: forClass)
        return UINib(nibName: xibName, bundle: bundle).instantiate(withOwner:nil, options: nil)[0] as! UIView
    }
    
    class func instantiate(xibName: String) -> UIView {
        return UINib(nibName: xibName, bundle: nil).instantiate(withOwner:nil, options: nil)[0] as! UIView
    }
    
    class func instantiate<T>(xibName: String, withType type:T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(xibName, owner: nil, options: nil)?.first as? T {
            return view
        }
        
        fatalError("Could not load view with type " + String(describing:type))
    }
    
    class func instantiate<T>(forClass: AnyClass, withType type:T.Type) -> T {
        let xibName = String(describing: forClass)
        if let view = Bundle.main.loadNibNamed(xibName, owner: nil, options: nil)?.first as? T {
            return view
        }
        
        fatalError("Could not load view with type " + String(describing:type))
    }
    
    @IBInspectable var shadowOffset: CGSize{
        get{
            return self.layer.shadowOffset
        }
        set{
            self.layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor{
        get{
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set{
            self.layer.shadowColor = newValue.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat{
        get{
            return self.layer.shadowRadius
        }
        set{
            self.layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float{
        get{
            return self.layer.shadowOpacity
        }
        set{
            self.layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat{
        get{
            return self.layer.cornerRadius
        }
        set{
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor{
        get{
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set{
            self.layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat{
        get{
            return self.layer.borderWidth
        }
        set{
            self.layer.borderWidth = newValue
        }
    }
}
