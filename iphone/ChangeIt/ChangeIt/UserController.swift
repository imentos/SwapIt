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
            view.loadData(PFUser.currentUser()?.objectId!)
            
        } else if (segue.identifier == "offerSent") {
            //updateSentOffers()
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.viewControllers[0] as! OffersController
            view.loadData()
            
        }
    }

//    func updateSentOffers() {
//        let offers = PFCloud.callFunction("getSentOffersByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!])
//        if (offers == nil) {
//            return
//        }
//        sentOffersJSON = JSON(data:(offers as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//        self.offerSentButton.setTitle("Offer Sent " + String(sentOffersJSON.count), forState: UIControlState.Normal)
//        self.spinnerView.stopAnimating()
//    }
//    
//    func updateReceivedOffers() {
//        let offers = PFCloud.callFunction("getReceivedOffersByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!])
//        if (offers == nil) {
//            return
//        }
//        receivedOffersJSON = JSON(data:(offers as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//        self.offerReceivedButton.setTitle("Offer Received " + String(receivedOffersJSON.count), forState: UIControlState.Normal)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let userFromCloud = PFCloud.callFunction("getUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!])
        let userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        name.text = userJSON[0]["name"].string
        locationLabel.text = userJSON[0]["location"].string
        
//        self.spinnerView.startAnimating()
//        self.spinnerView.hidden = false
//
//        dispatch_async(dispatch_get_main_queue()) {
//            self.updateSentOffers()
//            self.updateReceivedOffers()
//            
//            self.spinnerView.stopAnimating()
//            self.spinnerView.hidden = true
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

