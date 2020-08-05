//
//  PDYNotificationView.swift
//  Pushdy
//
//  Created by quandt on 6/28/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation
import UIKit


public typealias PDYActionBlock = () -> Void
@objc public protocol PDYPushBannerActionProtocol {
    func show(_ data:[String:Any], onTap:@escaping PDYActionBlock)
}

@objc public class PDYNotificationView: UIView, PDYPushBannerActionProtocol {
    let PADDING = 10
    let ContentViewWidth = 275
    let ContentViewOriginX = 80
  
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var contentLabel:UILabel?
    @IBOutlet weak var iconIV:UIImageView?
    @IBOutlet weak var contentView: UIView!
  
    @IBOutlet weak var heightTitleConstaint:NSLayoutConstraint?
    @IBOutlet weak var heightIconConstaint:NSLayoutConstraint?
    @IBOutlet weak var widthIconConstaint:NSLayoutConstraint?
    @IBOutlet weak var leadingContentConstaint:NSLayoutConstraint?
    
    var actionBlock:PDYActionBlock?
    
    private static var _customMediaKey:String? = nil
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc public static func setCustomMediaKey(_ key:String) {
        PDYNotificationView._customMediaKey = key
    }
    
    @objc public func setData(_ data:[String: Any]) {
        if let aps = data["aps"] as? [String:Any], let alert = aps["alert"] as? [String:Any] {
            if let title = alert["title"] as? String, !title.isEmpty {
                showTitle(title: title)
            }
            else {
                hideTitle()
            }
            
            if let content = alert["body"] as? String, !content.isEmpty {
                showBody(content: content)
            }
            else {
              hideBody()
            }
        }
        else {
            self.titleLabel?.text = ""
            self.contentLabel?.text = ""
        }
        
        let mediaKey = PDYNotificationView._customMediaKey == nil ? "_nms_image" : PDYNotificationView._customMediaKey!
        if let icon = data[mediaKey] as? UIImage {
          self.showIconIV(image: icon)
        }
        else if let icon = data[mediaKey] as? String, !icon.isEmpty, icon.starts(with: "http") {
            if let url = URL(string: icon) {
                self.iconIV?.setImageUrl(url, placeholder: nil, completion: { (image:UIImage) in
                    PDYThread.perform(onUIThread: {
                      self.showIconIV(image: image)
                    })
                }, failure: { (error:Error) in
                    PDYThread.perform(onUIThread: {
                      self.hideIconIV()
                    })
                })
            }
            else {
              self.hideIconIV()
            }
        }
        else {
          self.hideIconIV()
        }
        
    }
  
    @objc public func hideIconIV() {
      self.iconIV?.image = nil
      self.contentView.frame = CGRect(
        x: PADDING,
        y: 0,
        width: ContentViewWidth + ContentViewOriginX - PADDING,
        height: 90
      )
    }

    @objc public func showIconIV(image: UIImage) {
      self.iconIV?.image = image
      self.contentView.frame = CGRect(
        x: ContentViewOriginX,
        y: 0,
        width: ContentViewWidth,
        height: 90
      )
    }
  
    @objc public func showTitle(title: String) {
      self.titleLabel?.text = title
      self.heightTitleConstaint?.constant = 21
      self.heightIconConstaint?.constant = 21
      
      // move body down
      // set body line height to 3
    }

    @objc public func hideTitle() {
      self.titleLabel?.text = ""
      self.heightTitleConstaint?.constant = 0
      self.heightIconConstaint?.constant = 0
      
      // move body up
      // set body line height to 4
    }
  
    @objc public func showBody(content: String) {
      self.contentLabel?.text = content
      // set title line height to 1
    }

    @objc public func hideBody() {
      self.contentLabel?.text = ""
      // set title line height to 3
      self.heightTitleConstaint?.constant = 21 * 3
    }

    @objc public func close() {
        let statusHeight = UIApplication.shared.statusBarFrame.height
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(x: 0, y: -self.frame.size.height-statusHeight, width: self.frame.size.width, height: self.frame.size.height)
            self.alpha = 0.0
        }) { (completed:Bool) in
            self.removeFromSuperview()
        }
    }
    
    @objc public func show(_ data:[String:Any], onTap:@escaping PDYActionBlock) {
        if let window = UIApplication.shared.delegate?.window {
            let statusHeight = UIApplication.shared.statusBarFrame.height
            window?.addSubview(self)
            self.setData(data)
            self.actionBlock = onTap
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            UIView.animate(withDuration: 0.25, animations: {
                // Cannot set it to 90 so I set it by this hard code
                let frameFixedHeight = 90
                self.frame = CGRect(x: 0, y: statusHeight, width: self.frame.size.width, height: CGFloat(frameFixedHeight))
                self.alpha = 1.0
            }) { (completed:Bool) in
                if (Pushdy.isPushBannerAutoDismiss()) {
                    self.perform(#selector(PDYNotificationView.close), with: nil, afterDelay: TimeInterval(Pushdy.getPushBannerDismissDuration()))
                }
            }
        }
    }
    
    @IBAction func closePopup() {
        self.close()
    }
    
    @IBAction func tapPopup() {
        self.close()
        self.actionBlock?()
    }
}
