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
    
    @IBOutlet weak var facebookPhoto: UIImageView!
    @IBOutlet var spinnerView: UIActivityIndicatorView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var offerSentButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var offerReceivedButton: UIButton!
    
    var sentOffersJSON:JSON! = nil
    var receivedOffersJSON:JSON! = nil
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
    }

    @IBAction func logout(sender: AnyObject) {
        PFFacebookUtils.session()?.closeAndClearTokenInformation()
        PFFacebookUtils.session()?.close()
        FBSession.activeSession().closeAndClearTokenInformation()
        FBSession.activeSession().close()
        FBSession.setActiveSession(nil)
        PFUser.logOut()
    }
    
    override func viewWillAppear(animated: Bool) {
        if PFUser.currentUser() == nil {
            return
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "myWishList") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.viewControllers[0] as! WishListController
            view.loadData(PFUser.currentUser()?.objectId!, hideAddCell: false)
            
        } else if (segue.identifier == "offerSent") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.viewControllers[0] as! OffersController
            view.loadData()
            
        } else if (segue.identifier == "bookmarks") {
            let navi = segue.destinationViewController as! UINavigationController
            navi.navigationBarHidden = false
            let view = navi.viewControllers[0] as! ItemsController
            view.loadData("getBookmarkedItems")
            
        } else if (segue.identifier == "questions") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.viewControllers[0] as! QuestionsController
            view.loadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let userFromCloud = PFCloud.callFunction("getUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!])
        let userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        name.text = userJSON[0]["name"].string
        locationLabel.text = userJSON[0]["location"].string

        facebookPhoto.layer.borderWidth = 1
        facebookPhoto.layer.masksToBounds = true
        facebookPhoto.layer.borderColor = UIColor.blackColor().CGColor
        facebookPhoto.layer.cornerRadius = facebookPhoto.bounds.height / 2
        facebookPhoto.image = UIImage(data: NSData(contentsOfURL: NSURL(string: String(format:"https://graph.facebook.com/%@/picture?width=160&height=160", userJSON[0]["facebookId"].string!))!)!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

