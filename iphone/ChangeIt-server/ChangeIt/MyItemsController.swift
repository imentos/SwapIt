//
//  MyItemsController.swift
//  ChangeIt
//
//  Created by i818292 on 5/13/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class MyItemsController: UITableViewController {
    var itemsJSON:JSON = nil
    var cellMap:[String:UITableViewCell] = [String:UITableViewCell]()

    @IBAction func addItem(segue:UIStoryboardSegue) {
        loadData()
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refreshControlValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
        loadData()
        
        updateTotalUnreadCount()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateOfferReceived:", name: UPDATE_OFFER_RECEIVED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateOfferSent:", name: UPDATE_OFFER_SENT, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMessages:", name: UPDATE_MESSAGES, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateOfferReceived:", name: UPDATE_REPLIES, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func refreshControlValueChanged(sender:AnyObject) {
        loadData()
        
        self.updateTotalUnreadCount()
    }
    
    func updateOfferReceived(notification: NSNotification) {
        if let itemId:String = notification.userInfo!["item"] as? String {
            if let cell = cellMap[itemId] {
                updateOfferReceivedInCell(cell, itemId:itemId)
            }
        }
        updateTotalUnreadCount()
    }
    
    func updateOfferSent(notification: NSNotification) {
        if let itemId:String = notification.userInfo!["item"] as? String {
            if let cell = cellMap[itemId] {
                updateOfferSentInCell(cell, itemId:itemId)
            }
        }
    }
    
    func updateOfferReceivedInCell(cell:UITableViewCell, itemId:String) {
        PFCloud.callFunctionInBackground("getReceivedCountOfItem", withParameters: ["itemId": itemId], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            let offersCountLabel = cell.viewWithTag(103) as! UILabel
            offersCountLabel.text = "\(countJSON[0].int!)"
            
            // update unread item
            var unreadOffers = 0
            let newoffersCountLabel = cell.viewWithTag(113) as! UILabel
            newoffersCountLabel.hidden = true
            PFCloud.callFunctionInBackground("getUnreadExchangesCountOfItem", withParameters: ["itemId": itemId], block: {
                (result:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    return
                }
                
                let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                unreadOffers = countJSON[0].int!
                if (unreadOffers > 0) {
                    newoffersCountLabel.text = "\(countJSON[0].int!) /"
                    newoffersCountLabel.hidden = false
                } else {
                    newoffersCountLabel.hidden = true
                }
            })
        })
    }
    
    func updateMessages(notification: NSNotification) {
        if let itemId:String = notification.userInfo!["item"] as? String {
            if let cell = cellMap[itemId] {
                updateQuestionInCell(cell, itemId: itemId)
            }
        }
        updateTotalUnreadCount()
    }
    
    func updateQuestionInCell(cell:UITableViewCell, itemId:String) {
        PFCloud.callFunctionInBackground("getQuestionsCountOfItem", withParameters: ["itemId": itemId], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            let questionsCountLabel = cell.viewWithTag(105) as! UILabel
            questionsCountLabel.text = "\(countJSON[0].int!)"
            
            // update unread messages
            var unreadQuestions = 0
            let newquestionsCountLabel = cell.viewWithTag(115) as! UILabel
            newquestionsCountLabel.hidden = true
            PFCloud.callFunctionInBackground("getUnreadQuestionsCountOfItem", withParameters: ["itemId": itemId], block: {
                (result:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    return
                }
                
                let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                unreadQuestions = countJSON[0].int!
                if (unreadQuestions > 0) {
                    newquestionsCountLabel.text = "\(countJSON[0].int!) /"
                    newquestionsCountLabel.hidden = false
                } else {
                    newquestionsCountLabel.hidden = true
                }
            })
        })
    }
    
    func updateOfferSentInCell(cell:UITableViewCell, itemId:String) {
        PFCloud.callFunctionInBackground("getExchangesCountOfItem", withParameters: ["itemId": itemId], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            let offersCountLabel = cell.viewWithTag(104) as! UILabel
            offersCountLabel.text = "\(countJSON[0].int!)"
        })
    }

    func updateTotalUnreadCount() {
        var totalUnread:Int = 0
        PFCloud.callFunctionInBackground("getUnreadQuestionsCount", withParameters:["userId": (PFUser.currentUser()?.objectId)!], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                self.refreshControl!.endRefreshing()
                return
            }
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            totalUnread += countJSON[0].int!

            PFCloud.callFunctionInBackground("getUnreadExchangesCount", withParameters:["userId": (PFUser.currentUser()?.objectId)!], block: {
                (result:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    self.refreshControl!.endRefreshing()
                    return
                }

                let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                totalUnread += countJSON[0].int!
                
                let app:AppDelegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!
                app.updateTabBadge(2, value: totalUnread == 0 ? nil : "")
                
                self.refreshControl!.endRefreshing()
            })
        })
    }
    
    func loadData() {
        let spinner = createSpinner(self.view)
        PFCloud.callFunctionInBackground("getItemsByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!], block: {
            (items:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                spinner.stopAnimating()
                return
            }
            self.itemsJSON = JSON(data:(items as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.tableView.reloadData()
            spinner.stopAnimating()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath) 
        let itemJSON = itemsJSON[indexPath.row]
        let itemId = (itemJSON["objectId"].string)!
        cellMap[itemId] = cell
        
        createImageQuery().getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            do {            let imageData = try (imageObj!["file"] as! PFFile).getData()
            let imageView = cell.viewWithTag(101) as! UIImageView
            imageView.image = UIImage(data: imageData)
            } catch {}
        })
        
        let label = cell.viewWithTag(102) as! UILabel
        label.text = itemJSON["title"].string
        
        updateOfferReceivedInCell(cell, itemId: itemId)
        updateOfferSentInCell(cell, itemId: itemId)
        updateQuestionInCell(cell, itemId: itemId)
        
//        PFCloud.callFunctionInBackground("getReceivedCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
//            (result:AnyObject?, error: NSError?) -> Void in
//            if let error = error {
//                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
//                return
//            }
//            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//            let offersCountLabel = cell.viewWithTag(103) as! UILabel
//            offersCountLabel.text = "\(countJSON[0].int!)"
//        })
//
//        PFCloud.callFunctionInBackground("getExchangesCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
//            (result:AnyObject?, error: NSError?) -> Void in
//            if let error = error {
//                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
//                return
//            }
//            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//            let offersCountLabel = cell.viewWithTag(104) as! UILabel
//            offersCountLabel.text = "\(countJSON[0].int!)"
//        })
//        
//        PFCloud.callFunctionInBackground("getQuestionsCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
//            (result:AnyObject?, error: NSError?) -> Void in
//            if let error = error {
//                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
//                return
//            }
//            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//            let questionsCountLabel = cell.viewWithTag(105) as! UILabel
//            questionsCountLabel.text = "\(countJSON[0].int!)"
//        })
//        
//        updateUnread(itemJSON, cell: cell)
        return cell
    }

    func updateUnread(itemJSON:JSON, cell:UITableViewCell) {
        var unreadQuestions = 0
        var unreadOffers = 0
        let newoffersCountLabel = cell.viewWithTag(113) as! UILabel
        let newquestionsCountLabel = cell.viewWithTag(115) as! UILabel
        newoffersCountLabel.hidden = true
        newquestionsCountLabel.hidden = true
        
        PFCloud.callFunctionInBackground("getUnreadQuestionsCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            unreadQuestions = countJSON[0].int!
            if (unreadQuestions > 0) {
                newquestionsCountLabel.text = "\(countJSON[0].int!) /"
                newquestionsCountLabel.hidden = false
            } else {
                newquestionsCountLabel.hidden = true
            }
            
            PFCloud.callFunctionInBackground("getUnreadExchangesCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
                (result:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    return
                }
                
                let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                unreadOffers = countJSON[0].int!
                if (unreadOffers > 0) {
                    newoffersCountLabel.text = "\(countJSON[0].int!) /"
                    newoffersCountLabel.hidden = false
                } else {
                    newoffersCountLabel.hidden = true
                }
            })
        })
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            let alert:UIAlertController = UIAlertController(title: "Alert", message: "Are you sure you want to delete this item?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                let spinner = createSpinner(self.view)
                let itemJSON = self.itemsJSON[indexPath.row]
                PFCloud.callFunctionInBackground("deleteItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
                    (result:AnyObject?, error: NSError?) -> Void in
                    if let error = error {
                        NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                        spinner.stopAnimating()
                        return
                    }
                    PFCloud.callFunctionInBackground("deleteUnusedQuestions", withParameters: nil, block: {
                        (result:AnyObject?, error: NSError?) -> Void in
                        if let error = error {
                            NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                            spinner.stopAnimating()
                            return
                        }
                        self.loadData()
                        spinner.stopAnimating()
                    })
                })
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (itemsJSON == nil) {
            return 0
        }
        return itemsJSON.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detail") {
            let tableView = self.view as! UITableView
            let itemJSON = itemsJSON[(tableView.indexPathForSelectedRow?.row)!]
            
            let detail = segue.destinationViewController as! MyItemDetailController
            detail.title = itemJSON["title"].string!
            detail.itemJSON = itemJSON
        }
    }

}
