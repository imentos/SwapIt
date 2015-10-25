//
//  AppDelegate.swift
//  ChangeIt
//
//  Created by i818292 on 4/22/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import ParseCrashReporting
//import Instabug

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
//        Parse.enableLocalDatastore()
        
//        ParseCrashReporting.enable()
        
        // Initialize Parse.
        Parse.setApplicationId("AyaLli8Wgpr6AS56sQiHn9fONdtdt7R18jckKsCp",
            clientKey: "nQdUigj9cxaQ4Ns6oPEwB1au7rlCdYBTR7bjGW7X")
        
        // [Optional] Track statistics around application opens.
        //PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        PFFacebookUtils.initializeFacebook()
        
        // global style
        self.window!.tintColor = UIColor(red:0.851, green:0.047, blue:0.314, alpha:1)
        UITableViewCell.appearance().selectionStyle = .None
        
        // instabug
        Instabug.startWithToken("09d7d874a8efe64a9a186afc07982018", captureSource: IBGCaptureSourceUIKit, invocationEvent: IBGInvocationEventShake)
        
        // notification
        let notificationType: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            handleRemoteNofication(userInfo)
        }
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation["user"] = PFUser.currentUser()
        installation.saveInBackgroundWithBlock { (result, error) -> Void in
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    func updateTabBadge(index:Int, value:String?) {
        let main:MainController = self.window?.rootViewController as! MainController
        main.selectedIndex = index
        if let tabItems = main.tabBar.items {
            if let item:UITabBarItem = tabItems[index] {
                item.badgeValue = value
            }
        }
    }
    
    func handleRemoteNofication(userInfo:NSDictionary) {
        if let type:String = userInfo["type"] as? String {
            print("type:\(type)")
            if (type == "message") {
                updateTabBadge(0, value:"")
            } else if (type == "offer") {
                updateTabBadge(2, value:"")
            }
        }
    }
    
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        handleRemoteNofication(userInfo)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, withSession:PFFacebookUtils.session())
    }

}

