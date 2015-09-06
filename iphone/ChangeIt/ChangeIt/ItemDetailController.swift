//
//  ItemDetailController.swift
//  ChangeIt
//
//  Created by i818292 on 5/5/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class ItemDetailController: UITableViewController {

    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var makeOfferButton: UIBarButtonItem!
    @IBOutlet weak var questionButton: UIButton!
    var itemJSON:JSON!
    var userJSON:JSON!
    var disabledItemId:String?
    
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet weak var wishBtn: UIButton!
    @IBAction func makeOffer(segue:UIStoryboardSegue) {
        let offer = segue.sourceViewController as! MakeOfferController
        let offerJSON:JSON = offer.selectedItem!
        
        let srcId = offerJSON["objectId"].string
        let distId = itemJSON["objectId"].string
        PFCloud.callFunctionInBackground("exchangeItem", withParameters: ["srcItemId":srcId!, "distItemId":distId!], block:{
            (items:AnyObject?, error: NSError?) -> Void in
            
            if (self.makeOfferButton.title == "Edit Offer") {
                PFCloud.callFunctionInBackground("unexchangeItem", withParameters: ["srcItemId":offer.disabledItemId!, "distItemId":distId!], block:{
                    (items:AnyObject?, error: NSError?) -> Void in
                })
            }
            self.disabledItemId = srcId
            self.makeOfferButton.title = "Edit Offer"
        })
    }

    @IBAction func bookmarkItem(sender: AnyObject) {
        PFCloud.callFunctionInBackground("bookmarkItem", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId": (self.itemJSON["objectId"].string)!], block:{
            (items:AnyObject?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.bookmarkBtn.setBackgroundImage(UIImage(named:"Bookmarked_Icon"), forState: .Normal)
                self.bookmarkBtn.enabled = false
            })
        })
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        println("cancel")
    }
    @IBAction func askQuestion(sender: AnyObject) {
        performSegueWithIdentifier("askQuestion", sender: self)
    }
    
    @IBAction func sendQuestion(segue:UIStoryboardSegue) {
        let view = segue.sourceViewController as! AddQuestionController
        let uuid = NSUUID().UUIDString
        
        PFCloud.callFunctionInBackground("addQuestion", withParameters: ["text": view.questionTextView.text, "objectId": uuid], block:{
            (items:AnyObject?, error: NSError?) -> Void in
            let itemId = self.itemJSON["objectId"].string
            PFCloud.callFunctionInBackground("askItemQuestionByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId": itemId!, "questionId": uuid], block:{
                (items:AnyObject?, error: NSError?) -> Void in
            })
        })
    }
    
    func loadData(myItem:Bool) {
        // check if the offer has been made
        let itemId = self.itemJSON["objectId"].string
        PFCloud.callFunctionInBackground("getExchangedItemsByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId":itemId!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            let resultsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            if (resultsJSON.count == 0) {
                return
            }
            // each person can only exchange one item
            if (self.makeOfferButton != nil) {
                self.makeOfferButton.title = "Edit Offer"
                self.disabledItemId = resultsJSON[0]["item"]["objectId"].string
            }
        })

        PFQuery(className:"Image").getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.photoImage.image = UIImage(data: imageData!)
        })
        
        PFCloud.callFunctionInBackground("isItemBookmarked", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId":itemId!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            let resultsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            if (resultsJSON.count == 0) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.bookmarkBtn.setBackgroundImage(UIImage(named:"Bookmark_Icon-01"), forState: .Normal)
                    self.bookmarkBtn.enabled = true
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.bookmarkBtn.setBackgroundImage(UIImage(named:"Bookmarked_Icon"), forState: .Normal)
                self.bookmarkBtn.enabled = false
            })
        })
        
        self.showData(myItem)
    }
    
    func showData(myItem:Bool) {
        self.title = itemJSON["title"].string
        self.descriptionTextView.text = itemJSON["description"].string
        self.userLabel.text = userJSON["name"].string
        
        self.userPhoto.layer.borderWidth = 1
        self.userPhoto.layer.masksToBounds = true
        self.userPhoto.layer.borderColor = UIColor.blackColor().CGColor
        self.userPhoto.layer.cornerRadius = self.userPhoto.bounds.height / 2
        self.userPhoto.image = UIImage(data: NSData(contentsOfURL: NSURL(string: String(format:"https://graph.facebook.com/%@/picture?width=80&height=80", userJSON["facebookId"].string!))!)!)
        
        if (myItem) {
            self.makeOfferButton.enabled = false
            self.wishBtn.enabled = false
            self.bookmarkBtn.enabled = false
            self.messageBtn.enabled = false
            self.questionButton.enabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
    }

    override func viewDidAppear(animated: Bool) {
        loadData(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showUserWishList") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.childViewControllers[0] as! WishListController
            
            view.toolbar.rightBarButtonItem = nil

            view.loadData(self.userJSON["objectId"].string, hideAddCell: true)
            view.title = self.userJSON["name"].string! + "'s Wish List";
            view.enableEdit = false
            
        } else if (segue.identifier == "offer") {
            let view = segue.destinationViewController as! MakeOfferController
            view.disabledItemId = self.disabledItemId
            view.loadData()
            
        } else if (segue.identifier == "askQuestion") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.childViewControllers[0] as! AddQuestionController
            view.userJSON = self.userJSON
            view.itemImage = self.photoImage.image!
        }
    }
}
