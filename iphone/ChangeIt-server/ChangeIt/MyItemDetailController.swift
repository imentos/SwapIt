//
//  MyItemDetailController.swift
//  ChangeIt
//
//  Created by i818292 on 5/19/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

extension UIImage {
    func grayScaleImage() -> UIImage {
        let imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
        let colorSpace = CGColorSpaceCreateDeviceGray();
        
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        let context = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace!, .allZeros);
        CGContextDrawImage(context, imageRect, self.CGImage!);
        
        let imageRef = CGBitmapContextCreateImage(context);
        let newImage = UIImage(CGImage: imageRef!)
        return newImage
    }
}

class MyItemDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var questionsJSON:JSON!
    var receivedItemsJSON:JSON!
    var offeredItemsJSON:JSON!
    var itemJSON:JSON!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var detailTable: UITableView!
    @IBOutlet var testLabel: UILabel!
    @IBOutlet var segmentedControl: ADVSegmentedControl!
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        // TODO: figure out why I did this?
//        PFCloud.callFunctionInBackground("getItem", withParameters: ["itemId":itemJSON["objectId"].string!], block:{
//            (results:AnyObject?, error: NSError?) -> Void in
//            if let error = error {
//                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
//                return
//            }
//            let r = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//            if (r.count == 0) {
//                return
//            }
//            self.itemJSON = r[0]
//            self.title = self.itemJSON["title"].string!
//        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.addTarget(self, action: "segmentValueChanged:", forControlEvents: .ValueChanged)
        segmentedControl.items = ["Offers Received", "Offers Sent", "Questions Asked"]
        segmentedControl.icons = ["segmented_icons_dn_red", "segmented_icons_up_red", "segmented_icons_message_red"]
        segmentedControl.otherIcons = ["segmented_icons_dn_white", "segmented_icons_up_white", "segmented_icons_message_white"]
        segmentedControl.font = UIFont.systemFontOfSize(10)
        
        loadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateOfferReceived:", name: UPDATE_OFFER_RECEIVED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateOfferSent:", name: UPDATE_OFFER_SENT, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMessages:", name: UPDATE_MESSAGES, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateOfferReceived:", name: UPDATE_REPLIES, object: nil)
    }
    
    func updateOfferReceived(notification: NSNotification) {
        let spinner = createSpinner(self.view)
        PFCloud.callFunctionInBackground("getReceivedItems", withParameters: ["itemId":itemJSON["objectId"].string!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                spinner.stopAnimating()
                return
            }
            self.receivedItemsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.detailTable.reloadData()
            self.segmentedControl.setTitle(String(format:"%02d", self.receivedItemsJSON.count), forSegmentAtIndex: 0)
            spinner.stopAnimating()
        })
    }
    
    func updateOfferSent(notification: NSNotification) {
        let spinner = createSpinner(self.view)
        PFCloud.callFunctionInBackground("getOfferedItems", withParameters: ["itemId":self.itemJSON["objectId"].string!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                spinner.stopAnimating()
                return
            }
            self.offeredItemsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            //                self.editButton.enabled = self.offeredItemsJSON.count == 0 && self.receivedItemsJSON.count == 0
            self.detailTable.reloadData()
            
            self.segmentedControl.setTitle(String(format:"%02d", self.offeredItemsJSON.count), forSegmentAtIndex: 1)
            spinner.stopAnimating()
        })
    }
    
    func updateMessages(notification: NSNotification) {
        let spinner = createSpinner(self.view)
        PFCloud.callFunctionInBackground("getQuestionedItems", withParameters: ["itemId":itemJSON["objectId"].string!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                spinner.stopAnimating()
                return
            }
            self.questionsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.segmentedControl.setTitle(String(format:"%02d", self.questionsJSON.count), forSegmentAtIndex: 2)
            spinner.stopAnimating()
        })
    }
    
    func loadData() {
        let spinner = createSpinner(self.view)
        PFCloud.callFunctionInBackground("getQuestionedItems", withParameters: ["itemId":itemJSON["objectId"].string!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                spinner.stopAnimating()
                return
            }
            self.questionsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.segmentedControl.setTitle(String(format:"%02d", self.questionsJSON.count), forSegmentAtIndex: 2)
            spinner.stopAnimating()
            })
        })

        spinner.startAnimating()
        PFCloud.callFunctionInBackground("getReceivedItems", withParameters: ["itemId":itemJSON["objectId"].string!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                spinner.stopAnimating()
                return
            }
            self.receivedItemsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.detailTable.reloadData()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.segmentedControl.setTitle(String(format:"%02d", self.receivedItemsJSON.count), forSegmentAtIndex: 0)
            })
            PFCloud.callFunctionInBackground("getOfferedItems", withParameters: ["itemId":self.itemJSON["objectId"].string!], block:{
                (results:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    spinner.stopAnimating()
                    return
                }
                self.offeredItemsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//                self.editButton.enabled = self.offeredItemsJSON.count == 0 && self.receivedItemsJSON.count == 0
                self.detailTable.reloadData()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.segmentedControl.setTitle(String(format:"%02d", self.offeredItemsJSON.count), forSegmentAtIndex: 1)
                })
                spinner.stopAnimating()
            })
        })
        
        createImageQuery().getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            do {
            let imageData = try (imageObj!["file"] as! PFFile).getData()
            self.itemImageView.image = UIImage(data: imageData)
            } catch {}
        })

    }
    
    func segmentValueChanged(sender: AnyObject?){
        self.detailTable.reloadData()
    }
    
    @IBAction func indexChanged(sender: AnyObject) {
        self.detailTable.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (segmentedControl.selectedSegmentIndex == 0) {
            self.performSegueWithIdentifier("offerReceived", sender: self)
            
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            self.performSegueWithIdentifier("offerSent", sender: self)
            
        } else {
            self.performSegueWithIdentifier("messages", sender: self)
            
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (segmentedControl.selectedSegmentIndex == 0) {
            if let _ = receivedItemsJSON {
                if (receivedItemsJSON.count == 0) {
                    return 1
                }
                return receivedItemsJSON.count
            }
            return 0

        } else if (segmentedControl.selectedSegmentIndex == 1) {
            if let _ = offeredItemsJSON {
                if (offeredItemsJSON.count == 0) {
                    return 1
                }
                return offeredItemsJSON.count
            }
            return 0
            
        } else {
            if let _ = questionsJSON {
                if (questionsJSON.count == 0) {
                    return 1
                }
                return questionsJSON.count
            }
            return 0

        }
    }
    
    func updatePhotoConstraints(photo:UIImageView, value:CGFloat) {
        for c in photo.constraints {
            if (c.identifier == "imageWidth") {
                c.constant = value
            } else if (c.identifier == "imageHeight") {
                c.constant = value
            }
        }
        photo.updateConstraints()
    }
    
    func updateViewConstraints(photo:UIView, value:CGFloat) {
        for c in photo.constraints {
            if (c.identifier == "imageTop") {
                c.constant = value
            } else if (c.identifier == "imageLeading") {
                c.constant = value
            }
        }
        photo.updateConstraints()
    }
    
    func noDataCell(tableView: UITableView, msg:String, indexPath: NSIndexPath)->UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("noDataCell", forIndexPath: indexPath)
        let title = cell.viewWithTag(201) as! UILabel
        title.text = msg
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (segmentedControl.selectedSegmentIndex == 0 && receivedItemsJSON.count == 0) {
            return noDataCell(tableView, msg:"This item has not received any offers yet.", indexPath:indexPath)
        } else if (segmentedControl.selectedSegmentIndex == 1 && offeredItemsJSON.count == 0) {
            return noDataCell(tableView, msg:"You have not offered this item to anyone yet.", indexPath:indexPath)
        } else if (segmentedControl.selectedSegmentIndex == 2 && questionsJSON.count == 0) {
            return noDataCell(tableView, msg:"There are no questions about this item.", indexPath:indexPath)
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("myItemDetail", forIndexPath: indexPath)
        let photo = cell.viewWithTag(101) as! UIImageView
        let title = cell.viewWithTag(102) as! UILabel
        let name = cell.viewWithTag(103) as! UILabel
        let status = cell.viewWithTag(105) as! UILabel
        let statusIcon = cell.viewWithTag(106) as! UIImageView
        let newQuestionIcon = cell.viewWithTag(107) as! UIImageView
        
        status.text = ""
        statusIcon.image = nil
        
        if (segmentedControl.selectedSegmentIndex == 0) {
            let itemJSON = receivedItemsJSON[indexPath.row]
            
            updatePhotoConstraints(photo, value:100.0)
            updateViewConstraints(cell.contentView, value:-8.0)
            photo.layer.cornerRadius = 0
            photo.layer.borderWidth = 0
            
            createImageQuery().getObjectInBackgroundWithId(itemJSON["item"]["photo"].string!, block: {
                (imageObj:PFObject?, error: NSError?) -> Void in
                do {
                let imageData = try (imageObj!["file"] as! PFFile).getData()
                photo.image = UIImage(data: imageData)
                } catch {}
                
                if (itemJSON["exchange"]["status"] != nil) {
                    if (itemJSON["exchange"]["status"].string! == "Accepted") {
                        status.text = "Interested"
                        statusIcon.image = UIImage(named:"offer_accepted")
                    }
                    
                    if (itemJSON["exchange"]["status"].string! == "Rejected") {
                        status.text = "Not Interested"
                        statusIcon.image = UIImage(named:"offer_rejected")
                        
                        photo.image = photo.image?.grayScaleImage()
                        title.textColor = UIColor.lightGrayColor()
                    }
                }
            })
            title.text = itemJSON["item"]["title"].string
            name.text = itemJSON["user"]["name"].string
            if (itemJSON["exchange"]["read"].bool!) {
                statusIcon.image = nil
            } else {
                statusIcon.image = UIImage(named: "offer_new")
            }
            
            PFCloud.callFunctionInBackground("getUnreadReceivedQuestionsCountOfItem", withParameters: ["itemId":self.itemJSON["objectId"].string!, "otherItemId":itemJSON["item"]["objectId"].string!], block:{
                (result:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    return
                }

                let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                let unreadQuestions = countJSON[0].int!
                if (unreadQuestions > 0) {
                    newQuestionIcon.image = UIImage(named: "message_new")
                } else {
                    newQuestionIcon.image = nil
                }
            })
        
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            let itemJSON = offeredItemsJSON[indexPath.row]
            
            updatePhotoConstraints(photo, value:100.0)
            updateViewConstraints(cell.contentView, value:-8.0)
            photo.layer.cornerRadius = 0
            photo.layer.borderWidth = 0
            
            createImageQuery().getObjectInBackgroundWithId(itemJSON["item"]["photo"].string!, block: {
                (imageObj:PFObject?, error: NSError?) -> Void in
                do {
                let imageData = try (imageObj!["file"] as! PFFile).getData()
                photo.image = UIImage(data: imageData)
                } catch {}
                
                if (itemJSON["exchange"]["status"] != nil) {
                    if (itemJSON["exchange"]["status"].string! == "Accepted") {
                        status.text = "Interested"
                        statusIcon.image = UIImage(named:"offer_accepted")
                    }

                    if (itemJSON["exchange"]["status"].string! == "Rejected") {
                        status.text = "Not Interested"
                        statusIcon.image = UIImage(named:"offer_rejected")
                        
                        photo.image = photo.image?.grayScaleImage()
                        title.textColor = UIColor.lightGrayColor()
                    }
                }
            })
            title.text = itemJSON["item"]["title"].string
            name.text = itemJSON["user"]["name"].string
            
            PFCloud.callFunctionInBackground("getUnreadReceivedQuestionsCountOfItem", withParameters: ["itemId":itemJSON["item"]["objectId"].string!, "otherItemId":self.itemJSON["objectId"].string!], block:{
                (result:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    return
                }
                
                let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                let unreadQuestions = countJSON[0].int!
                if (unreadQuestions > 0) {
                    newQuestionIcon.image = UIImage(named: "message_new")
                } else {
                    newQuestionIcon.image = nil
                }
            })
            
        } else if (segmentedControl.selectedSegmentIndex == 2) {
            let questionJSON = questionsJSON[indexPath.row]
            
            updatePhotoConstraints(photo, value:60.0)
            updateViewConstraints(cell.contentView, value:10.0)
            cell.contentView.layoutIfNeeded()            
            displayUserPhoto(photo, userJSON: questionJSON["user"])

            title.text = questionJSON["question"]["text"].string
            name.text = questionJSON["user"]["name"].string
            if (questionJSON["link"]["read"].bool!) {
                statusIcon.image = nil
            } else {
                statusIcon.image = UIImage(named: "offer_new")
            }

        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "offerSent") {
            let indexPath = detailTable.indexPathForSelectedRow
            let index = indexPath!.row
            let itemJSON = segmentedControl.selectedSegmentIndex == 0 ? receivedItemsJSON[index] : offeredItemsJSON[index]
            
            let detail = segue.destinationViewController as! ItemDetailController
            detail.itemJSON = itemJSON["item"]
            detail.userJSON = itemJSON["user"]
            detail.fromOffer = true
            detail.loadData()
            
        } else if (segue.identifier == "offerReceived") {
            let indexPath = detailTable.indexPathForSelectedRow
            let index = indexPath!.row
            let itemJSON = segmentedControl.selectedSegmentIndex == 0 ? receivedItemsJSON[index] : offeredItemsJSON[index]
            
            let detail = segue.destinationViewController as! ItemDetailController
            detail.itemJSON = itemJSON["item"]
            detail.userJSON = itemJSON["user"]
            detail.fromOffer = false
            detail.loadData()
            
        } else if (segue.identifier == "messages") {
            let indexPath = detailTable.indexPathForSelectedRow
            let index = indexPath!.row
            let questionJSON = self.questionsJSON[index]
            
            let messages = segue.destinationViewController as! MessagesController
            messages.title = self.title
            messages.questionJSON = questionJSON["question"]
            messages.userJSON = questionJSON["user"]
            messages.itemJSON = itemJSON
            
        } else if (segue.identifier == "edit") {
            let item = segue.destinationViewController as! AddItemController
            item.title = "Edit Item"
            item.itemJSON = self.itemJSON
            item.navigationItem.rightBarButtonItem = item.saveButton
        }
    }
}
