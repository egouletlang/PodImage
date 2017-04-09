//
//  PresentationHelper.swift
//  bankroll
//
//  Created by Etienne Goulet-Lang on 7/3/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public class PresentationHelper {
    
    // MARK: - Navigation -
    public class func buildNavBarSpace(_ width: CGFloat) -> UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        button.width = width
        return button
    }
    public class func buildNavBarButton(_ image: UIImage, target: AnyObject?, action: Selector, tintColor: UIColor? = nil) -> UIBarButtonItem {
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(image, for: UIControlState())
        button.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        let ret = UIBarButtonItem(customView: button)
        ret.width = 20
        return ret
    }
    public class func buildNavBarLabel(_ label: String, target: AnyObject?, action: Selector, tintColor: UIColor? = UIColor.white) -> UIBarButtonItem {
        
        let button = UIButton(type: UIButtonType.custom)
        button.setTitle(label, for: UIControlState())
        button.setTitleColor(tintColor, for: UIControlState())
        button.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        button.sizeToFit()
        
        let ret = UIBarButtonItem(customView: button)
        ret.width = button.frame.width
        return ret
    }
    
    open class func collectText(title: String, subTitle: String? = nil, viewController: UIViewController, callback: @escaping (String)->Void) {
        let alert = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            if let q = alert.textFields?.first?.text {
                callback(q)
            }
        })
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Alert -
    public class func displayAlert<T>(
        _ viewController: UIViewController,
        labels: [String],
        vals: [String: T],
        styles: [String: UIAlertActionStyle] = ["Cancel": .cancel],
        withTitle: String? = nil,
        withMessage: String? = nil,
        callback: @escaping (_ key: String, _ val: T)->Void) {
        self.displayAlert(viewController, labels: labels, styles:styles, withTitle: withTitle, withMessage: withMessage) { (index) in
            if let key = labels.get(index),
                let val = vals[key] {
                callback(key, val)
            }
        }
    }
    
    public class func displayAlert(
        _ viewController: UIViewController,
        labels: [String],
        styles: [String: UIAlertActionStyle] = [:],
        withTitle: String? = nil,
        withMessage: String? = nil,
        callback: @escaping (_ index: Int)->Void) {
        let alert = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
        
        let dismiss = {
            ThreadHelper.checkedExecuteOnMainThread() {
                alert.dismiss(animated: true, completion: nil)
            }
        }
        
        for i in 0 ..< labels.count {
            alert.addAction(UIAlertAction(title: labels[i], style: styles[labels[i]] ?? .default) { (action: UIAlertAction) -> Void in
                if let index = alert.actions.index(of: action) {
                    callback(index)
                }
                dismiss()
                })
        }
        
        ThreadHelper.checkedExecuteOnMainThread() {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Handle Share Options -
    public class func displayActionSheet<T>(
        _ viewController: UIViewController,
        labels: [String],
        vals: [T],
        withTitle: String? = nil,
        withMessage: String? = nil,
        withCancel: Bool=true,
        withCancelCallback: (()->Void)?=nil,
        callback: @escaping (_ key: String, _ val: T)->Void) {
        displayActionSheet(viewController, labels: labels, withTitle: withTitle, withMessage: withMessage, withCancel: withCancel) { (index) in
            if let key = labels.get(index),
                let val = vals.get(index) {
                callback(key, val)
            } else if index == -1 {
                withCancelCallback?()
            }
        }
    }
    
    public class func displayActionSheet(
        _ viewController: UIViewController,
        labels: [String],
        withTitle: String? = nil,
        withMessage: String? = nil,
        withCancel: Bool=true,
        callback: @escaping (_ index: Int)->Void) {
        let actionSheet: UIAlertController! // = UIAlertController(title: withTitle, message: withMessage, preferredStyle: UIAlertControllerStyle.ActionSheet)
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            actionSheet = UIAlertController(title: withTitle, message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        } else {
            actionSheet = UIAlertController(title: withTitle, message: withMessage, preferredStyle: UIAlertControllerStyle.actionSheet)
        }
        let dismiss = {
            ThreadHelper.checkedExecuteOnMainThread() {
                actionSheet.dismiss(animated: true, completion: nil)
            }
        }
        
        for i in 0 ..< labels.count {
            actionSheet.addAction(UIAlertAction(title: labels[i], style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
                if let index = actionSheet.actions.index(of: action) {
                    callback(index)
                }
                dismiss()
                })
        }
        if withCancel {
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)  { (_) -> Void in
                callback(-1)
                dismiss()
                })
        }
        
        ThreadHelper.checkedExecuteOnMainThread() {
            viewController.present(actionSheet, animated: true, completion: nil)
        }
    }
}
