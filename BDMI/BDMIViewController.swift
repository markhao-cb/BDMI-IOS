//
//  BDMIViewController.swift
//  BDMI
//
//  Created by Yu Qi Hao on 6/3/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit
import TransitionTreasury
import TransitionAnimation

class BDMIViewController: UIViewController, ModalTransitionDelegate {
    
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    var placeHolderLabel: UILabel?
    weak var modalDelegate: ModalViewControllerDelegate?
    
    func invokeLoginVCFrom(viewController: BDMIViewController, toViewController: BDMIViewController?) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        loginVC.modalDelegate = viewController
        if let toVC = toViewController {
            loginVC.toViewController = toVC
        }
        viewController.tr_presentViewController(loginVC, method: TRPresentTransitionMethod.PopTip(visibleHeight: 200))
    }
}
