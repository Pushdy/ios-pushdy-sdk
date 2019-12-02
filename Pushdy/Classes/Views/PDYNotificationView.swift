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
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var contentLabel:UILabel?
    @IBOutlet weak var iconIV:UIImageView?
    
    @IBOutlet weak var heightTitleConstaint:NSLayoutConstraint?
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
                self.titleLabel?.text = title
                self.heightTitleConstaint?.constant = 21
            }
            else {
                self.titleLabel?.text = ""
                self.heightTitleConstaint?.constant = 0
            }
            
            if let content = alert["body"] as? String, !content.isEmpty {
                self.contentLabel?.text = content
            }
            else {
                self.contentLabel?.text = ""
            }
        }
        else {
            self.titleLabel?.text = ""
            self.heightTitleConstaint?.constant = 0
            self.contentLabel?.text = ""
        }
        
        let mediaKey = PDYNotificationView._customMediaKey == nil ? "_nms_image" : PDYNotificationView._customMediaKey!
        if let icon = data[mediaKey] as? UIImage {
            self.iconIV?.image = icon
            self.widthIconConstaint?.constant = 44
            self.leadingContentConstaint?.constant = 12
        }
        else if let icon = data[mediaKey] as? String, !icon.isEmpty, icon.starts(with: "http") {
            if let url = URL(string: icon) {
                self.iconIV?.setImageUrl(url, placeholder: nil, completion: { (image:UIImage) in
                    PDYThread.perform(onUIThread: {
                        self.iconIV?.image = image
                        self.widthIconConstaint?.constant = 44
                        self.leadingContentConstaint?.constant = 12
                    })
                }, failure: { (error:Error) in
                    PDYThread.perform(onUIThread: {
                      self.iconIV?.image = nil
                      self.widthIconConstaint?.constant = 0
                      self.leadingContentConstaint?.constant = 0
                    })
                })
            }
            else {
                self.iconIV?.image = nil
                self.widthIconConstaint?.constant = 0
                self.leadingContentConstaint?.constant = 0
            }
        }
        else {
            self.iconIV?.image = nil
            self.widthIconConstaint?.constant = 0
            self.leadingContentConstaint?.constant = 0
        }
        
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
                self.frame = CGRect(x: 0, y: statusHeight, width: self.frame.size.width, height: self.frame.size.height)
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
