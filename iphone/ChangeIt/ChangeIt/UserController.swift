//
//  FirstViewController.swift
//  ChangeIt
//
//  Created by i818292 on 4/22/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class UserController: UIViewController {
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet var spinnerView: UIActivityIndicatorView!
    @IBOutlet weak var offerSentButton: UIButton!
    @IBOutlet weak var offerReceivedButton: UIButton!
    
    var sentOffersJSON:JSON! = nil
    var receivedOffersJSON:JSON! = nil
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
    }
    
    @IBAction func logout(sender: AnyObject) {
        let currentInstall = PFInstallation.currentInstallation()
        currentInstall["user"] = NSNull()
        
        currentInstall.save()
        PFUser.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let main = UIApplication.sharedApplication().keyWindow?.rootViewController as! MainController
        main.showLoginPage()
    }
    
    override func viewDidAppear(animated: Bool) {
        if let user = PFUser.currentUser() {
            let userFromCloud = PFCloud.callFunction("getUser", withParameters: ["userId": user.objectId!])
            let userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            title = userJSON[0]["name"].string
            
            if (PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!)) {
                userPhoto.layer.borderWidth = 1
                userPhoto.layer.masksToBounds = true
                userPhoto.layer.borderColor = UIColor.blackColor().CGColor
                userPhoto.layer.cornerRadius = userPhoto.bounds.height / 2
                if let image = NSData(contentsOfURL: NSURL(string: String(format:"https://graph.facebook.com/%@/picture?width=160&height=160", userJSON[0]["facebookId"].string!))!) {
                    userPhoto.image = UIImage(data: image)
                }
            } else {
                userPhoto.image = UIImage(named: "bottom_User_Inactive")
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "myWishList") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.viewControllers[0] as! WishListController
            view.title = "Wish List"
            view.loadData(PFUser.currentUser()?.objectId!, otherWishlist: false)
            
        } else if (segue.identifier == "offerSent") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.viewControllers[0] as! OffersController
            view.title = "Offers Sent"
            view.loadData()
            
        } else if (segue.identifier == "bookmarks") {
            let navi = segue.destinationViewController as! UINavigationController
            navi.navigationBarHidden = false
            let view = navi.viewControllers[0] as! ItemsController
            view.title = "Bookmarks"
            view.bookmarkMode = true
            view.loadDataByFunction("getBookmarkedItems", limit:view.ITEMS_PER_PAGE) { (results) -> Void in
            }
            
        } else if (segue.identifier == "questions") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.viewControllers[0] as! QuestionsController
            view.title = "Questions Asked"
            view.loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

