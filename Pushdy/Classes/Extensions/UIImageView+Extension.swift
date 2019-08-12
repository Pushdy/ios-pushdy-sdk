//
//  UIImageView+Extension.swift
//  Pushdy
//
//  Created by quandt on 8/5/19.
//

import UIKit

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
            
            let image = UIImage(data: data!)
            DispatchQueue.main.async(execute: { () -> Void in
                activityIndicator.removeFromSuperview()
                self.image = image
            })
            completion?(image!)
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
