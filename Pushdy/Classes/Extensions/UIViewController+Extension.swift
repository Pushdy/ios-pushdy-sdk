//
//  UIViewController+Extension.swift
//  Pushdy
//
//  Created by quandt on 8/5/19.
//

import UIKit

@objc extension UIViewController {
    public class func topViewController() -> UIViewController {
        return UIViewController.topViewController(withRoot: (UIApplication.shared.keyWindow?.rootViewController)!)
    }
    
    public class func topViewController(withRoot rootViewController:UIViewController) -> UIViewController {
        if rootViewController is UITabBarController {
            let tabBarController = rootViewController as! UITabBarController
            if let selectedController = tabBarController.selectedViewController {
                return self.topViewController(withRoot:selectedController)
            }
        }
        else if rootViewController is UINavigationController {
            let navigationController = rootViewController as! UINavigationController
            if let visibleController = navigationController.visibleViewController {
                return self.topViewController(withRoot:visibleController)
            }
        }
        else if let presentedController = rootViewController.presentedViewController {
            return self.topViewController(withRoot:presentedController)
        }
        return rootViewController
    }
    
    var prevViewController: UIViewController? {
        if let controllersOnNavStack = self.navigationController?.viewControllers, controllersOnNavStack.count >= 2 {
            let n = controllersOnNavStack.count
            return controllersOnNavStack[n - 2]
        }
        return nil
    }
    
    func isVisible() -> Bool {
        return self.isViewLoaded && self.view.window != nil
    }
}

