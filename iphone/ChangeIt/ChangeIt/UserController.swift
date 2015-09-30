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
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet var spinnerView: UIActivityIndicatorView!
    @IBOutlet weak var offerSentButton: UIButton!
    @IBOutlet weak var offerReceivedButton: UIButton!
    
    var sentOffersJSON:JSON! = nil
    var receivedOffersJSON:JSON! = nil
    var userJSON:JSON!
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = false
    }
    
    @IBAction func unwindToUser(segue:UIStoryboardSegue) {
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = false
    }

    @IBAction func saveEmail(segue:UIStoryboardSegue) {
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = false
        
        let view = segue.sourceViewController as! UserEmailController
        let email = view.emailText.text
        PFCloud.callFunctionInBackground("updateUserEmail", withParameters: ["userId":(PFUser.currentUser()?.objectId)!, "email": email], block:{
            (userFromCloud:AnyObject?, error: NSError?) -> Void in
            
            self.loadData()
        })
    }
    
    @IBAction func savePhone(segue:UIStoryboardSegue) {
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = false
        
        let view = segue.sourceViewController as! UserPhoneController
        let phone = view.phoneText.text
        PFCloud.callFunctionInBackground("updateUserPhone", withParameters: ["userId":(PFUser.currentUser()?.objectId)!, "phone": phone], block:{
            (userFromCloud:AnyObject?, error: NSError?) -> Void in
            
            self.loadData()
        })
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
        loadData()
    }
    
    func loadData() {
        if let user = PFUser.currentUser() {
            PFCloud.callFunctionInBackground("getUser", withParameters: ["userId": user.objectId!], block:{
                (userFromCloud:AnyObject?, error: NSError?) -> Void in
                self.userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)[0]
                self.title = self.userJSON["name"].string
                self.nameLabel.text = self.userJSON["name"].string
                
                if (PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!)) {
                    self.userPhoto.layer.borderWidth = 1
                    self.userPhoto.layer.masksToBounds = true
                    self.userPhoto.layer.borderColor = UIColor.blackColor().CGColor
                    self.userPhoto.layer.cornerRadius = self.userPhoto.bounds.height / 2
                    if let image = NSData(contentsOfURL: NSURL(string: String(format:"https://graph.facebook.com/%@/picture?width=160&height=160", self.userJSON["facebookId"].string!))!) {
                        self.userPhoto.image = UIImage(data: image)
                    }
                } else {
                    self.userPhoto.image = UIImage(named: "bottom_User_Inactive")
                }
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBarHidden = false
        
        if (segue.identifier == "wishList") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.viewControllers[0] as! WishListController
            view.title = "Wish List"
            view.loadData(PFUser.currentUser()?.objectId!, otherWishlist: false)
            
        } else if (segue.identifier == "offerSent") {
            let view = segue.destinationViewController as! OffersController
            view.title = "Offers Sent"
            view.loadData()
            
        } else if (segue.identifier == "bookmarks") {
            let view = segue.destinationViewController as! ItemsController
            view.title = "Bookmarks"
            view.bookmarkMode = true
            view.loadDataByFunction("getBookmarkedItems", limit:view.ITEMS_PER_PAGE) { (results) -> Void in
            }
            
        } else if (segue.identifier == "questions") {
            let view = segue.destinationViewController as! QuestionsController
            view.title = "Questions Asked"
            view.loadData()
        
        } else if (segue.identifier == "email") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.topViewController as! UserEmailController
            view.email = self.userJSON["email"].string

        } else if (segue.identifier == "phone") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.topViewController as! UserPhoneController
            view.phone = self.userJSON["phone"].string
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

