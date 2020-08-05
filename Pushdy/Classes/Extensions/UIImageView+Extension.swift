//
//  UIImageView+Extension.swift
//  Pushdy
//
//  Created by quandt on 8/5/19.
//

import UIKit


enum MyError: Error {
    case runtimeError(String)
}

@objc extension UIImageView {
    public func setImageUrl(_ url: URL, placeholder:UIImage?, completion:((UIImage) -> Void)?, failure:((Error) -> Void)?) {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        if self.image == nil{
            if let _ = placeholder {
                self.image = placeholder
            }
            self.addSubview(activityIndicator)
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                failure?(error!)
                return
            }
            
            if let data = data {
              let image = UIImage(data: data)
              DispatchQueue.main.async(execute: { () -> Void in
                  activityIndicator.removeFromSuperview()
                  self.image = image
              })
              if let image = image {
                completion?(image)
              } else {
                failure?(MyError.runtimeError("Cannot convert data to UIImage"))
              }
            } else {
              failure?(MyError.runtimeError("Image Data is empty"))
            }
        }).resume()
    }
    
    public func setImageUrl(_ url: URL, completion:@escaping ((UIImage) -> Void), failure:@escaping ((Error) -> Void)) {
        self.setImageUrl(url, placeholder: nil, completion: completion, failure: failure)
    }
    
    public func setImageUrl(_ url: URL) {
        self.setImageUrl(url, placeholder: nil, completion: nil, failure: nil)
    }
    
    public func setImageUrl(_ url: URL, placeholder:UIImage?) {
        self.setImageUrl(url, placeholder: placeholder, completion: nil, failure: nil)
    }
}
