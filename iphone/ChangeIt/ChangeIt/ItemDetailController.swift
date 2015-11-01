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
import MessageUI

class ItemDetailController: UIViewController, MFMailComposeViewControllerDelegate, UIActionSheetDelegate {
    @IBOutlet var backToUserButton: UIBarButtonItem!
    @IBOutlet weak var exchangeImage: UIImageView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet var originalPhotoImage: UIImage!
    @IBOutlet var otherItemImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var makeOfferButton: UIBarButtonItem!
    @IBOutlet weak var questionButton: UIBarButtonItem!
    var itemJSON:JSON!
    var otherItemJSON:JSON!
    var userJSON:JSON!
    var questionJSON:JSON!
    var otherItemId:String!
    var acceptable:Bool! = false
    var fromOffer:Bool! = false
    var myItemId:String!
    var fromOtherItems:Bool! = false
    var horizontalConstraints:[NSLayoutConstraint]!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet weak var wishBtn: UIButton!
    
    @IBOutlet var locationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailButton.hidden = true
        self.phoneButton.hidden = true
        self.acceptBtn.setImage(UIImage(named: "thumb_UP_grey"), forState: .Normal)
        self.rejectBtn.setImage(UIImage(named: "thumb_DN_grey"), forState: .Normal)
        
        photoImage.translatesAutoresizingMaskIntoConstraints = false

        let photoTap = UITapGestureRecognizer(target: self, action: Selector("tapPhotoImage"))
        photoTap.numberOfTapsRequired = 1
        photoImage.userInteractionEnabled = true
        photoImage.addGestureRecognizer(photoTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("tapOtherImage"))
        singleTap.numberOfTapsRequired = 1
        otherItemImageView.userInteractionEnabled = true
        otherItemImageView.addGestureRecognizer(singleTap)
        
        let userTap = UITapGestureRecognizer(target: self, action: Selector("tapOtherUser"))
        userTap.numberOfTapsRequired = 1
        self.userPhoto.userInteractionEnabled = true
        self.userPhoto.addGestureRecognizer(userTap)
        
        self.expandItemImage()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = self.itemJSON {
        } else {
            return
        }
        
        self.acceptBtn.hidden = true
        self.rejectBtn.hidden = true

        self.loadData(false)
        
        if (self.fromOffer == false) {
            if let _ = itemJSON {
                PFCloud.callFunctionInBackground("setExchangeRead", withParameters: ["itemId": itemJSON["objectId"].string!, "userId":self.userJSON["objectId"].string!], block:{
                    (results:AnyObject?, error: NSError?) -> Void in
                })
            }
        }
        
        updateCommunications()
        
        self.emailButton.setImage(UIImage(named: self.emailButton.enabled == true ? "mail_red" : "mail_grey"), forState: .Normal)
        self.phoneButton.setImage(UIImage(named: self.phoneButton.enabled == true ? "phone_red" : "phone_grey"), forState: .Normal)

        updateLocation()
    }
    
    func updateLocation() {
        self.locationLabel.text = ""
        let query = PFQuery(className:"Item")
        query.whereKey("neo4jId", equalTo: self.itemJSON["objectId"].string!)
        query.cachePolicy = .CacheElseNetwork
        query.findObjectsInBackgroundWithBlock({
            (results, error) -> Void in
            if error == nil {
                for object in results! {
                    let descLocation = object["currentLocation"] as! PFGeoPoint
                    print(descLocation)
                    let loc = CLLocation(latitude: descLocation.latitude, longitude: descLocation.longitude)
                    self.locationToAddress(loc)
                }
            }
        })
    }
    
    func locationToAddress(loc:CLLocation) {
        CLGeocoder().reverseGeocodeLocation(loc) { (placemarks, err) -> Void in
            if placemarks!.count > 0 {
                let placemark = placemarks![0] as CLPlacemark
                self.locationLabel.text = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.ISOcountryCode!)"
                
            } else {
                print("No Placemarks!")
            }
        }
    }
    
    @IBAction func usePhone(sender: AnyObject) {
        if let phone = self.userJSON["phone"].string {
            print(phone)

            if let phoneCallURL = NSURL(string: "tel://\(phone)") {
                let application:UIApplication = UIApplication.sharedApplication()
                if (application.canOpenURL(phoneCallURL)) {
                    application.openURL(phoneCallURL);
                }
            }
        }
    }
    
    @IBAction func useEmail(sender: AnyObject) {
        if let email = self.userJSON["email"].string {
            print(email)
            
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([self.userJSON["email"].string!])
        mailComposerVC.setSubject("Sending you an in-app e-mail...")
        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func updateCommunications() {
        if let _ = itemJSON {
        } else {
            return
        }
        if (self.itemJSON["communication"].string!.isEmpty == true) {
            self.emailButton.enabled = false
            self.phoneButton.enabled = false
            return
        }
        let communications = Set<String>(self.itemJSON["communication"].string!.componentsSeparatedByString(","))
        
        self.emailButton.enabled = false
        self.phoneButton.enabled = false
        if let _ = self.userJSON["email"].string {
            self.emailButton.enabled = communications.contains("email")
        }
        if let _ = self.userJSON["phone"].string {
            self.phoneButton.enabled = communications.contains("phone")
        }
    }
    
    func confirmAcceptOffer() {
        let actionSheet = UIActionSheet(title: "Are you sure you are interested in this offer?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Yes, I am interested.")
        actionSheet.tag = 1
        actionSheet.showInView(self.view)
    }

    @IBAction func acceptOffer(sender: AnyObject) {
        let itemId = self.itemJSON["objectId"].string
        PFCloud.callFunctionInBackground("getOfferStatus", withParameters: ["srcItemId":itemId!, "distItemId":self.myItemId!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            let resultsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            if let status = resultsJSON[0]["status"].string {
                if (status == "Accepted") {
                    let alert = UIAlertView(title: "Brttr", message: "You have already informed that you are interested in this offer. Try to send a message to the user and initiate communication.", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    
                } else {
                    self.confirmAcceptOffer()
                }
            } else {
                self.confirmAcceptOffer()
            }
        })
    }
    
    func confirmRejectOffer() {
        let actionSheet = UIActionSheet(title: "Are you sure you are not interested in this offer?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Yes, I am not interested.")
        actionSheet.tag = 0
        actionSheet.showInView(self.view)
    }
    
    @IBAction func rejectOffer(sender: AnyObject) {
        let itemId = self.itemJSON["objectId"].string
        PFCloud.callFunctionInBackground("getOfferStatus", withParameters: ["srcItemId":itemId!, "distItemId":self.myItemId!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            let resultsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            if let status = resultsJSON[0]["status"].string {
                if (status == "Rejected") {
                    let alert = UIAlertView(title: "Brttr", message: "You have informed the user that you are not interested in this offer.", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    
                } else {
                    self.confirmRejectOffer()
                }
            } else {
                self.confirmRejectOffer()
            }
        })        
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            if (actionSheet.tag == 0) {
                PFCloud.callFunctionInBackground("rejectItem", withParameters: ["srcItemId":itemJSON["objectId"].string!, "distItemId":self.myItemId!], block:{
                    (items:AnyObject?, error: NSError?) -> Void in
                    
                    self.acceptBtn.setImage(UIImage(named: "thumb_UP_grey"), forState: .Normal)
                    self.rejectBtn.setImage(UIImage(named: "thumb_DN_red"), forState: .Normal)
                    
                    // remove connection
                    PFCloud.callFunctionInBackground("unexchangeItem", withParameters: ["srcItemId":self.myItemId!, "distItemId":self.itemJSON["objectId"].string!], block:{
                        (items:AnyObject?, error: NSError?) -> Void in
                        
                        self.performSegueWithIdentifier("cancel", sender: self)
                    })
                })
                
            } else if (actionSheet.tag == 1) {
                PFCloud.callFunctionInBackground("acceptItem", withParameters: ["srcItemId":self.itemJSON["objectId"].string!, "distItemId":self.myItemId!], block:{
                    (items:AnyObject?, error: NSError?) -> Void in
                    
                    self.acceptBtn.setImage(UIImage(named: "thumb_UP_red"), forState: .Normal)
                    self.rejectBtn.setImage(UIImage(named: "thumb_DN_grey"), forState: .Normal)
                })
                
            }
        }
    }
    
    func loadData(myItem:Bool) {
        // check if the offer has been made
        let itemId = self.itemJSON["objectId"].string
        
        createImageQuery().getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.photoImage.image = UIImage(data: imageData!)
            self.originalPhotoImage = UIImage(data: imageData!)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.showData(myItem)
            })
            
            // TODO: reduce calls
            // check if any received item
            PFCloud.callFunctionInBackground("getReceivedItemsByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId":itemId!], block:{
                (results:AnyObject?, error: NSError?) -> Void in
                if let _ = results {
                } else {
                    return
                }
                let resultsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                self.acceptable = resultsJSON.count > 0 && self.fromOffer == false
                self.myItemId = resultsJSON[0]["item"]["objectId"].string
                
                // for offer received
                if (self.acceptable == true) {
                    self.makeOfferButton.title = ""
                    self.acceptBtn.hidden = false
                    self.rejectBtn.hidden = false
                    self.acceptBtn.setImage(UIImage(named: "thumb_UP_grey"), forState: .Normal)
                    self.rejectBtn.setImage(UIImage(named: "thumb_DN_grey"), forState: .Normal)
 
                    PFCloud.callFunctionInBackground("getOfferStatus", withParameters: ["srcItemId":itemId!, "distItemId":self.myItemId!], block:{
                        (results:AnyObject?, error: NSError?) -> Void in
                        let resultsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                        if (resultsJSON.count == 0) {
                            return
                        }
                        
                        self.emailButton.hidden = false
                        self.phoneButton.hidden = false
                        
                       if let status = resultsJSON[0]["status"].string {
                            if (status == "Accepted") {
                                self.acceptBtn.setImage(UIImage(named: "thumb_UP_red"), forState: .Normal)
                                self.rejectBtn.setImage(UIImage(named: "thumb_DN_grey"), forState: .Normal)
                                
                            } else {
                                self.acceptBtn.setImage(UIImage(named: "thumb_UP_grey"), forState: .Normal)
                                self.rejectBtn.setImage(UIImage(named: "thumb_DN_red"), forState: .Normal)
                            }
                        } else {
                            self.acceptBtn.setImage(UIImage(named: "thumb_UP_grey"), forState: .Normal)
                            self.rejectBtn.setImage(UIImage(named: "thumb_DN_grey"), forState: .Normal)
                        }
                    });
                }
                
                PFCloud.callFunctionInBackground(self.acceptable == true ? "getReceivedItemsByUser" : "getExchangedItemsByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId":itemId!], block:{
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
                        
                        // for offer sent
                        if (self.acceptable == false) {
                            self.makeOfferButton.title = "Edit Offer"
                        }
                        self.otherItemId = resultsJSON[0]["item"]["objectId"].string
                        self.otherItemJSON = resultsJSON[0]["item"]
                        
                        createImageQuery().getObjectInBackgroundWithId(self.otherItemJSON["photo"].string!, block: {
                            (imageObj:PFObject?, error: NSError?) -> Void in
                            let imageData = (imageObj!["file"] as! PFFile).getData()
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.otherItemImageView.image = self.photoImage.image
                                self.photoImage.image = UIImage(data: imageData!)
                            })
                        })
                    }
                })
            })
        })
        
        PFCloud.callFunctionInBackground("isItemBookmarked", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId":itemId!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            let resultsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            if (resultsJSON.count == 0) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.bookmarkBtn.setImage(UIImage(named:"Bookmark_Icon-01"), forState: .Normal)
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.bookmarkBtn.setImage(UIImage(named:"Bookmarked_Icon"), forState: .Normal)
            })
        })
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return true
    }
    
    func sendNewOfferNotification() {
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: PFUser(withoutDataWithObjectId: self.userJSON["objectId"].string!))
        let push = PFPush()
        push.setQuery(pushQuery)
        PFCloud.callFunctionInBackground("getUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!], block:{
            (userFromCloud:AnyObject?, error: NSError?) -> Void in
            let userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)[0]
            let name = userJSON["name"].string!
            let item = self.itemJSON["title"].string!
            let alert = "Your item \"\(item)\" got an offer from \(name)"
            push.setData(["alert": alert, "type": "offer", "from": (PFUser.currentUser()?.objectId)!, "to": self.userJSON["objectId"].string!])
            push.sendPushInBackgroundWithBlock({ (result, error) -> Void in
                if let _ = error {
                    print(error)
                }
            })
        })
    }
    
    @IBAction func makeOffer(segue:UIStoryboardSegue) {
        let offer = segue.sourceViewController as! MakeOfferController
        let distId = itemJSON["objectId"].string
        
        // don't do anything if no change
        if let _ = otherItemId {
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
                    
                    self.sendNewOfferNotification()
                })
            })
        } else {
            self.makeOfferButton.title = "Make Offer"
            self.loadData(false)
        }
    }
    
    @IBAction func socialShare(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Share On", preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: "Facebook", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            if (SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook))
            {
                // Create the post
                let post = SLComposeViewController(forServiceType: (SLServiceTypeFacebook))
                let text = "I found '\(self.title!)' on BRTTR www.brttr.com - A social platform to barter goods and services."
                post.setInitialText(text)
                post.addImage(self.originalPhotoImage)
                post.addURL(NSURL(string: "http://www.brttr.com"))
                self.presentViewController(post, animated: true, completion: nil)
            } else {
                // Facebook not available. Show a warning
                let alert = UIAlertController(title: "Facebook", message: "Facebook not available", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
        let saveAction = UIAlertAction(title: "Twitter", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("share on Twitter")
            // TWITTER START
            if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)) {
                // Create the tweet
                let tweet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                let text = "I found '\(self.title!)' on BRTTR www.brttr.com - A social platform to barter goods and services."
                tweet.setInitialText(text)
                tweet.addImage(self.originalPhotoImage)
                
                self.presentViewController(tweet, animated: true, completion: nil)
            } else {
                // Twitter not available. Show a warning
                let alert = UIAlertController(title: "Twitter", message: "Twitter not available", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
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
                        self.bookmarkBtn.setImage(UIImage(named:"Bookmarked_Icon"), forState: .Normal)
                    })
                })
            } else {
                PFCloud.callFunctionInBackground("unbookmarkItem", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId": (self.itemJSON["objectId"].string)!], block:{
                    (items:AnyObject?, error: NSError?) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.bookmarkBtn.setImage(UIImage(named:"Bookmark_Icon-01"), forState: .Normal)

                    })
                })
            }
        })
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        print("cancel")
    }
    
    @IBAction func askQuestion(sender: AnyObject) {
        // switch question when offer received 
        PFCloud.callFunctionInBackground("getAskedQuestionByItem", withParameters: ["userId":self.acceptable == true ? self.userJSON["objectId"].string! : (PFUser.currentUser()?.objectId)!, "itemId":self.acceptable == true ? self.otherItemId : self.itemJSON["objectId"].string!], block: {
            (results:AnyObject?, error: NSError?) -> Void in
            let questionsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            if (questionsJSON.count == 0) {
            } else {
                self.questionJSON = questionsJSON[0]["question"]
            }
            self.performSegueWithIdentifier("messages", sender: self)
        })
    }
    
    func showData(myItem:Bool) {
        if let _ = itemJSON {
        } else {
            return
        }
        self.title = itemJSON["title"].string
        self.descriptionTextView.text = itemJSON["description"].string
        self.userLabel.text = userJSON["name"].string
        
        displayUserPhoto(self.userPhoto, userJSON: self.userJSON)
        
        if (myItem == true) {
            self.makeOfferButton.enabled = false
            self.wishBtn.enabled = false
            self.bookmarkBtn.enabled = false
            self.messageBtn.enabled = false
            self.questionButton.enabled = false
        }
    }
    
    func collapseItemImage() {
        if let _ = horizontalConstraints {
            self.photoImage.superview!.removeConstraints(horizontalConstraints)
            horizontalConstraints = nil
        }
        self.photoImage.superview?.updateConstraints()
        
        self.otherItemImageView.hidden = false
        self.exchangeImage.hidden = false
        self.view.insertSubview(exchangeImage, aboveSubview: otherItemImageView)
    }
    
    func expandItemImage() {
        let views = Dictionary(dictionaryLiteral: ("item",self.photoImage))
        if let _ = horizontalConstraints {
        } else {
            horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[item]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            self.photoImage.superview!.addConstraints(horizontalConstraints)
        }
        self.photoImage.superview?.updateConstraints()
        
        self.otherItemImageView.hidden = true
        self.exchangeImage.hidden = true
    }
    
    func tapOtherUser() {
        if (fromOtherItems == true) {
            return
        }
        
        performSegueWithIdentifier("otherItems", sender: self)
    }
    
    func tapPhotoImage() {
        let imageInfo = JTSImageInfo()
        imageInfo.image = self.photoImage.image
        imageInfo.referenceRect = self.photoImage.frame;
        imageInfo.referenceView = self.photoImage.superview;
        imageInfo.referenceContentMode = self.photoImage.contentMode;
        imageInfo.referenceCornerRadius = self.photoImage.layer.cornerRadius;
        
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Scaled)
        imageViewer.showFromViewController(self, transition: JTSImageViewControllerTransition.FromOriginalPosition)
    }
    
    func tapOtherImage() {
//        performSegueWithIdentifier("otherDetail", sender: self)
        let imageInfo = JTSImageInfo()
        imageInfo.image = self.otherItemImageView.image
        imageInfo.referenceRect = self.otherItemImageView.frame;
        imageInfo.referenceView = self.otherItemImageView.superview;
        imageInfo.referenceContentMode = self.otherItemImageView.contentMode;
        imageInfo.referenceCornerRadius = self.otherItemImageView.layer.cornerRadius;
        
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Scaled)
        imageViewer.showFromViewController(self, transition: JTSImageViewControllerTransition.FromOriginalPosition)
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
            view.userJSON = self.userJSON
            view.itemJSON = self.itemJSON
            view.questionJSON = self.questionJSON
            view.loadData()
            
            // TODO: remove it
//        } else if (segue.identifier == "otherDetail") {
//            PFCloud.callFunctionInBackground("getUserOfItem", withParameters: ["itemId":(otherItemJSON["objectId"].string)!], block:{
//                (user:AnyObject?, error: NSError?) -> Void in
//                let userJSON = JSON(data:(user as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//                
//                let detail = segue.destinationViewController as! ItemDetailController
//                detail.userJSON = userJSON[0]
//                detail.itemJSON = self.otherItemJSON
//                detail.loadData(true)
//            });
            
        } else if (segue.identifier == "otherItems") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.topViewController as! OtherItemsController
//            view.title = self.title
            view.userJSON = self.userJSON
            view.loadData()
        }
    }
}
