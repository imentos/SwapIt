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
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let userFromCloud = PFCloud.callFunction("getUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!])
        let userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        name.text = userJSON[0]["name"].string
        locationLabel.text = userJSON[0]["location"].string
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

