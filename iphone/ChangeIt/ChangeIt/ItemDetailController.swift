//
//  ItemDetailController.swift
//  ChangeIt
//
//  Created by i818292 on 5/5/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse
import Social

class ItemDetailController: UITableViewController {

    @IBOutlet weak var exchangeImage: UIImageView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet var otherItemImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var makeOfferButton: UIBarButtonItem!
    @IBOutlet weak var questionButton: UIButton!
    var itemJSON:JSON!
    var otherItemJSON:JSON!
    var userJSON:JSON!
    var otherUserJSON:JSON!
    var questionJSON:JSON!
    var otherItemId:String?
    var myItem:Bool! = false
    var acceptable:Bool! = false
    var myItemId:String!
    var horizontalConstraints:[AnyObject]!
    var verticalConstraints:[AnyObject]!
    
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet weak var wishBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        
        photoImage.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("tapDetected"))
        singleTap.numberOfTapsRequired = 1
        otherItemImageView.userInteractionEnabled = true
        otherItemImageView.addGestureRecognizer(singleTap)
        
        self.expandItemImage()
    }

    func loadData(myItem:Bool) {
        self.myItem = myItem
        // check if the offer has been made
        let itemId = self.itemJSON["objectId"].string

        if (self.acceptable == true) {
            PFCloud.callFunctionInBackground("getOfferStatus", withParameters: ["srcItemId":itemId!, "distItemId":self.myItemId!], block:{
                (results:AnyObject?, error: NSError?) -> Void in
                let resultsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                if (resultsJSON.count == 0) {
                    return
                }
                
                if let status = resultsJSON[0]["status"].string {
                    if (status == "Accepted") {
                        self.makeOfferButton.title = "Reject"
                    } else {
                        self.makeOfferButton.title = "Accept"
                    }
                } else {
                    self.makeOfferButton.title = "Accept"
                }
            });
        }
        
        PFQuery(className:"Image").getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.photoImage.image = UIImage(data: imageData!)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.showData()
            })
            
            PFCloud.callFunctionInBackground("getExchangedItemsByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId":itemId!], block:{
                (results:AnyObject?, error: NSError?) -> Void in
                self.collapseItemImage()
                let resultsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                if (resultsJSON.count == 0) {
                    self.otherItemId = nil
                    self.expandItemImage()
                    return
                }
                // each person can only exchange one item
                if (self.makeOfferButton != nil) {
                    if (self.acceptable == false) {
                        self.makeOfferButton.title = "Edit Offer"
                    }
                    self.otherItemId = resultsJSON[0]["item"]["objectId"].string
                    self.otherItemJSON = resultsJSON[0]["item"]
                    
                    PFQuery(className:"Image").getObjectInBackgroundWithId(self.otherItemJSON["photo"].string!, block: {
                        (imageObj:PFObject?, error: NSError?) -> Void in
                        let imageData = (imageObj!["file"] as! PFFile).getData()
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.otherItemImageView.image = UIImage(data: imageData!)
                        })
                    })
                }
            })
        })
        
        
        PFCloud.callFunctionInBackground("isItemBookmarked", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId":itemId!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            let resultsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            if (resultsJSON.count == 0) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.bookmarkBtn.setBackgroundImage(UIImage(named:"Bookmark_Icon-01"), forState: .Normal)
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.bookmarkBtn.setBackgroundImage(UIImage(named:"Bookmarked_Icon"), forState: .Normal)
            })
        })
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if (identifier == "offer" && self.acceptable == true) {
            if (self.makeOfferButton.title == "Accept") {
                PFCloud.callFunctionInBackground("acceptItem", withParameters: ["srcItemId":itemJSON["objectId"].string!, "distItemId":self.myItemId!], block:{
                    (items:AnyObject?, error: NSError?) -> Void in
                    self.makeOfferButton.title = "Reject"
                })
            } else {
                PFCloud.callFunctionInBackground("rejectItem", withParameters: ["srcItemId":itemJSON["objectId"].string!, "distItemId":self.myItemId!], block:{
                    (items:AnyObject?, error: NSError?) -> Void in
                    self.makeOfferButton.title = "Accept"
                })
            }

            return false
        }
        return true
    }
    
    @IBAction func makeOffer(segue:UIStoryboardSegue) {
        let offer = segue.sourceViewController as! MakeOfferController
        let distId = itemJSON["objectId"].string
        
        // don't do anything if no change
        if let id = otherItemId {
            if let srcId = offer.selectedIndexes.first {
                if (srcId == otherItemId) {
                    return
                }
            }
            // remove current offer first
            PFCloud.callFunctionInBackground("unexchangeItem", withParameters: ["srcItemId":offer.currentItemId!, "distItemId":distId!], block:{
                (items:AnyObject?, error: NSError?) -> Void in
            })
        }
        
        // add the new offer based on selection if any
        if (offer.selectedIndexes.count > 0) {
            let srcId = offer.selectedIndexes.first
            PFCloud.callFunctionInBackground("exchangeItem", withParameters: ["srcItemId":srcId!, "distItemId":distId!], block:{
                (items:AnyObject?, error: NSError?) -> Void in                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.makeOfferButton.title = "Edit Offer"
                    self.loadData(false)
                })
            })
        } else {
            self.makeOfferButton.title = "Make Offer"
            self.loadData(false)
        }
    }
    
    @IBAction func socialShare(sender: AnyObject) {
       // var alert:UIAlertController = UIAlertController(title: "Share Item", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let optionMenu = UIAlertController(title: nil, message: "Share On", preferredStyle: .ActionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Facebook", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            //println("share on facebook")
            // Facebook START
            if (SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook))
            {
                // Create the post
                let post = SLComposeViewController(forServiceType: (SLServiceTypeFacebook))
                //
               // NSString  ttt=[mylabelname text]
                //[slComposeViewController setInitialText:[NSString stringWithFormat:@"Posting to Facebook: %@", posttofacebooktext]];
                //
                var f = "I am using BRTTR app and found "
                //p += self.userLabel.text!
                f += self.title!
                f += "... Download the app here."
                post.setInitialText(f)
                post.addImage(self.photoImage.image)
                post.addURL(NSURL(string: "http://www.brttr.com"))
                self.presentViewController(post, animated: true, completion: nil)
            } else {
                // Facebook not available. Show a warning
                let alert = UIAlertController(title: "Facebook", message: "Facebook not available", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            //
        })
        let saveAction = UIAlertAction(title: "Twitter", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            println("share on Twitter")
            // TWITTER START
            if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)) {
                // Create the tweet
                let tweet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                
                var t = "I am using brttr app and found "
                t += self.title!
                t += "... Download the app here."
                
                tweet.setInitialText(t)
                tweet.addImage(self.photoImage.image)
                
                self.presentViewController(tweet, animated: true, completion: nil)
            } else {
                // Twitter not available. Show a warning
                let alert = UIAlertController(title: "Twitter", message: "Twitter not available", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            //
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
        
//        var shareToFacebook : SLComposeViewController =
//        SLComposeViewController(forServiceType: SLServiceTypeFacebook)
//        shareToFacebook.setInitialText("This is dummy text.")
//        self.presentViewController(shareToFacebook, animated: true, completion:nil)
//>>>>>>> Stashed changes
        
        //var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            //UIAlertAction in
        //}
        //alert.addAction(cancelAction)

        //self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func bookmarkItem(sender: AnyObject) {
        let itemId = self.itemJSON["objectId"].string
        PFCloud.callFunctionInBackground("isItemBookmarked", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId":itemId!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            let resultsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            if (resultsJSON.count == 0) {
                PFCloud.callFunctionInBackground("bookmarkItem", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId": (self.itemJSON["objectId"].string)!], block:{
                    (items:AnyObject?, error: NSError?) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.bookmarkBtn.setBackgroundImage(UIImage(named:"Bookmarked_Icon"), forState: .Normal)
                    })
                })
            } else {
                PFCloud.callFunctionInBackground("unbookmarkItem", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId": (self.itemJSON["objectId"].string)!], block:{
                    (items:AnyObject?, error: NSError?) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.bookmarkBtn.setBackgroundImage(UIImage(named:"Bookmark_Icon-01"), forState: .Normal)
                    })
                })
            }
        })
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        println("cancel")
    }
    
    @IBAction func askQuestion(sender: AnyObject) {
        PFCloud.callFunctionInBackground("getUser", withParameters: ["userId":(PFUser.currentUser()?.objectId)!]) {
            (results:AnyObject?, error: NSError?) -> Void in
            let userJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.otherUserJSON = userJSON[0]
            PFCloud.callFunctionInBackground("getAskedQuestionByItem", withParameters: ["userId":(PFUser.currentUser()?.objectId)!, "itemId":self.itemJSON["objectId"].string!], block: {
                (results:AnyObject?, error: NSError?) -> Void in
                let questionsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                if (questionsJSON.count == 0) {
                } else {
                    self.questionJSON = questionsJSON[0]["question"]
                }
                self.performSegueWithIdentifier("messages", sender: self)
            })
        }
    }
    
    func showData() {
        if let i = itemJSON {
        } else {
            return
        }
        self.title = itemJSON["title"].string
        self.descriptionTextView.text = itemJSON["description"].string
        self.userLabel.text = userJSON["name"].string
        
        self.userPhoto.layer.borderWidth = 1
        self.userPhoto.layer.masksToBounds = true
        self.userPhoto.layer.borderColor = UIColor.blackColor().CGColor
        self.userPhoto.layer.cornerRadius = self.userPhoto.bounds.height / 2
        if let data = NSData(contentsOfURL: NSURL(string: String(format:"https://graph.facebook.com/%@/picture?width=80&height=80", userJSON["facebookId"].string!))!) {
            self.userPhoto.image = UIImage(data: data)
        }
        
        if (self.myItem == true) {
            self.makeOfferButton.enabled = false
            self.wishBtn.enabled = false
            self.bookmarkBtn.enabled = false
            self.messageBtn.enabled = false
            self.questionButton.enabled = false
        }
    }
    
    func collapseItemImage() {
        if let x = horizontalConstraints {
            self.photoImage.superview!.removeConstraints(horizontalConstraints)
            horizontalConstraints = nil
        }
        if let y = verticalConstraints {
            self.photoImage.superview!.removeConstraints(verticalConstraints)
            verticalConstraints = nil
        }
        self.photoImage.superview?.updateConstraints()
        
        self.otherItemImageView.hidden = false
        self.exchangeImage.hidden = false
    }
    
    func expandItemImage() {
        let views = Dictionary(dictionaryLiteral: ("item",self.photoImage))
        if let x = horizontalConstraints {
        } else {
            horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[item]|", options: nil, metrics: nil, views: views)
            self.photoImage.superview!.addConstraints(horizontalConstraints)
        }
        
        if let y = verticalConstraints {
        } else {
            verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[item]|", options: nil, metrics: nil, views: views)
            self.photoImage.superview!.addConstraints(verticalConstraints)
        }
        self.photoImage.superview?.updateConstraints()
        
        self.otherItemImageView.hidden = true
        self.exchangeImage.hidden = true
    }
    
    func tapDetected() {
        performSegueWithIdentifier("otherDetail", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "wishList") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.topViewController as! WishListController
            
            view.toolbar.rightBarButtonItem = nil

            view.loadData(self.userJSON["objectId"].string, otherWishlist: true)
            view.title = self.userJSON["name"].string! + "'s Wish List";
            view.enableEdit = false
            
        } else if (segue.identifier == "offer") {
            let view = segue.destinationViewController as! MakeOfferController
            view.currentItemId = self.otherItemId
            view.loadData()
                        
        } else if (segue.identifier == "messages") {
            let view = segue.destinationViewController as! MessagesController
            view.title = self.title
            view.userJSON = self.otherUserJSON
            view.itemJSON = self.itemJSON
            view.questionJSON = self.questionJSON
            view.loadData()
            
        } else if (segue.identifier == "otherDetail") {
            PFCloud.callFunctionInBackground("getUserOfItem", withParameters: ["itemId":(otherItemJSON["objectId"].string)!], block:{
                (user:AnyObject?, error: NSError?) -> Void in
                let userJSON = JSON(data:(user as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                
                let navi = segue.destinationViewController as! UINavigationController
                let detail = navi.topViewController as! ItemDetailController
                detail.userJSON = userJSON[0]
                detail.itemJSON = self.otherItemJSON
                detail.loadData(true)
            });
        }
    }
}
