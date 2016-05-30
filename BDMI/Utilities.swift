//
//  Utilities.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import Foundation
import JCAlertView
import NVActivityIndicatorView

struct Utilities {
    
    
    static let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    static let session = NSURLSession.sharedSession()
    static let userDefault = NSUserDefaults.standardUserDefaults()
    
    
    //MARK: Networking Methods
    static func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    
    //MARK: AlertViewType
    enum AlertViewType {
        case AlertViewWithOneButton
        case AlertViewWithTwoButtons
    }
}


//MARK: GCD block
func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}

//MARK: AlertView
func showAlertViewWith(title: String, error: String, type: Utilities.AlertViewType, firstButtonTitle: String?, firstButtonHandler: (() -> Void)?, secondButtonTitle: String?, secondButtonHandler: (() -> Void)? ) {
    switch type {
    case .AlertViewWithOneButton:
        JCAlertView.showOneButtonWithTitle(title, message: error, buttonType: .Default, buttonTitle: firstButtonTitle, click: firstButtonHandler)
        break
    case .AlertViewWithTwoButtons:
        JCAlertView.showTwoButtonsWithTitle(title, message: error, buttonType: .Default, buttonTitle: firstButtonTitle, click: firstButtonHandler, buttonType: .Cancel, buttonTitle: secondButtonTitle, click: secondButtonHandler)
        break
    }
}



//MARK: ActivityIndeicator View
extension NVActivityIndicatorView {
    class func showHUDAddedTo(view: UIView) {
        let hud = NVActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100), type: .BallSpinFadeLoader, color: UIColor.grayColor(), padding: 20)
        hud.center = view.center
        hud.hidesWhenStopped = true
        view.addSubview(hud)
        hud.startAnimation()
    }
    
    class func hideHUDForView(view: UIView) {
        if let hud = HUDForView(view) {
            hud.hidesWhenStopped = true
            hud.stopAnimation()
            hud.removeFromSuperview()
        }
    }
    
    private class func HUDForView(view: UIView) -> NVActivityIndicatorView? {
        let subviewEnum = view.subviews.reverse()
        for subview in subviewEnum {
            if subview.isKindOfClass(self) {
                return subview as? NVActivityIndicatorView
            }
        }
        return nil
    }
}
