//
//  AppDelegate.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/28/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit
import MAThemeKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let stack = CoreDataStack(modelName: "Model")!
    
    func checkIfFirstLaunch() {
        if (Utilities.userDefault.boolForKey("HasLaunchedBefore")) {
            print("App has launched before")
        } else {
            print("This is the first launch ever!")
            Utilities.userDefault.setBool(true, forKey: "HasLaunchedBefore")
            Utilities.userDefault.synchronize()
        }
    }
    
    func setTheme() {
        MAThemeKit.setupThemeWithPrimaryColor(MAThemeKit.colorWithR(33, g: 7, b: 67), secondaryColor: UIColor.whiteColor(), fontName: "AppleSDGothicNeo-Bold", lightStatusBar: false)
        MAThemeKit.customizeSegmentedControlWithMainColor(MAThemeKit.colorWithR(102, g: 51, b: 153), secondaryColor: UIColor.whiteColor())
        MAThemeKit.customizeTabBarColor(UIColor.whiteColor(), textColor: MAThemeKit.colorWithR(102, g: 51, b: 153), fontName: "AppleSDGothicNeo-Regular", fontSize: 13)
    }
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        checkIfFirstLaunch()
        return true
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        stack.autoSave(60)
        setTheme()
        
        if case let userID as Int = Utilities.userDefault.valueForKey("UserID"), case let sessionID as String =  Utilities.userDefault.valueForKey("SessionID"), case let requestToken as String = Utilities.userDefault.valueForKey("RequestToken"){
            TMDBClient.sharedInstance.userID = userID
            TMDBClient.sharedInstance.sessionID = sessionID
            TMDBClient.sharedInstance.requestToken = requestToken
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        do {
            try stack.saveContext()
        } catch {
            print("Error while saving.")
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        do {
            try stack.saveContext()
        } catch {
            print("Error while saving.")
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

