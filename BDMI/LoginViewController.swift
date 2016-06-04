//
//  LoginViewController.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/28/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit
import TransitionTreasury
import TransitionAnimation
import FlatUIKit

class LoginViewController: BDMIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var loginButton: FUIButton!
    var toViewController : BDMIViewController?
    var session: NSURLSession!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configButton()
    }
    
    
    // MARK: IBActions
    
    @IBAction func loginPressed(sender: AnyObject) {
        if !Reachability.isConnectedToNetwork(){
            showAlertViewWith("Oops", error: "Internet Disconnected", type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
            return
        }
        TMDBClient.sharedInstance.authenticateWithViewController(self) { (success, errorString) in
            performUIUpdatesOnMain {
                if success {
                    self.completeLogin()
                } else {
                    self.displayError(errorString)
                }
            }
        }
    }
    
    @IBAction func cancelBtnClicked(sender: AnyObject) {
        modalDelegate?.modalViewControllerDismiss(callbackData: nil)
    }
    
    
    // MARK: Login
    
    private func completeLogin() {
        if let toVC = toViewController {
            toVC.modalDelegate = modalDelegate
        }
        modalDelegate?.modalViewControllerDismiss(callbackData: nil)
    }
}

// MARK: UI Related Methods
extension LoginViewController {
    
    private func setUIEnabled(enabled: Bool) {
        loginButton.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    private func displayError(errorString: String?) {
        if let errorString = errorString {
            showAlertViewWith("Oops", error: errorString, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: {
                performUIUpdatesOnMain({ 
                    self.modalDelegate?.modalViewControllerDismiss(callbackData: nil)
                })
                }, secondButtonTitle: nil, secondButtonHandler: nil)
        }
    }
    
    private func configButton() {
        loginButton.cornerRadius = 6.0
        loginButton.shadowColor = UIColor.wisteriaColor()
        loginButton.buttonColor = UIColor.amethystColor()
        loginButton.shadowHeight = 3.0
        loginButton.titleLabel?.font = UIFont.boldFlatFontOfSize(16)
    }
}


