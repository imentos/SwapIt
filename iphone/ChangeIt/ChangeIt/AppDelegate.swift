//
//  AppDelegate.swift
//  ChangeIt
//
//  Created by i818292 on 4/22/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        //Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("AyaLli8Wgpr6AS56sQiHn9fONdtdt7R18jckKsCp",
            clientKey: "nQdUigj9cxaQ4Ns6oPEwB1au7rlCdYBTR7bjGW7X")
        
        // [Optional] Track statistics around application opens.
        //PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        PFFacebookUtils.initializeFacebook()
        
        let tab = self.window!.rootViewController as! UITabBarController
        tab.selectedIndex = 1
        
        loginFB()
        
        // global style
        self.window!.tintColor = UIColor(red:0.851, green:0.047, blue:0.314, alpha:1)
        
        return true
    }

    func loginFB() {
        let permissions = ["public_profile"]
        PFFacebookUtils.logInWithPermissions(permissions, block: {
            (user: PFUser?, error: NSError?) -> Void in
            println(user?.objectId)
            if let user = user {
                if user.isNew {
                    println("User signed up and logged in through Facebook!")
                } else {
                    println("User logged in through Facebook!")
                }
                
                var req = FBRequest.requestForMe()
                req.startWithCompletionHandler{
                    (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                    var resultdict = result as! NSDictionary
                    println("Result Dict: \(resultdict)")
                    println(resultdict["name"])
                    let name = resultdict["name"] as! String
                    var location = ""
                    if resultdict["location"] != nil {
                        let loc = resultdict["location"] as! NSDictionary
                        location = loc["name"] as! String
                    }
                    
                    let userFromCloud = PFCloud.callFunction("getUser", withParameters: ["userId": user.objectId!])
                    let userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                    if userJSON.count == 0 {
                        PFCloud.callFunction("addUser", withParameters: ["name": name, "objectId": user.objectId!])
                        
                    } else {
                        PFCloud.callFunction("updateUser", withParameters: ["name": name, "objectId": user.objectId!, "location": location])
                    }
                    
                    let tab = self.window!.rootViewController as! UITabBarController
                    let navi = tab.selectedViewController as! UINavigationController
                    let items = navi.viewControllers[0] as! ItemsController
                    items.loadData()
                }                
                
            } else {
                println("Uh oh. The user cancelled the Facebook login.")
            }
        })
        
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

