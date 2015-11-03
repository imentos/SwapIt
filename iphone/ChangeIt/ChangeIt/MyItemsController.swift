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

    @IBAction func addItem(segue:UIStoryboardSegue) {
        loadData()
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
        
        updateTotalUnreadCount()
    }
    
    func updateTotalUnreadCount() {
        var totalUnread:Int = 0
        PFCloud.callFunctionInBackground("getUnreadQuestionsCount", withParameters:["userId": (PFUser.currentUser()?.objectId)!], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            totalUnread += countJSON[0].int!

            PFCloud.callFunctionInBackground("getUnreadExchangesCount", withParameters:["userId": (PFUser.currentUser()?.objectId)!], block: {
                (result:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    return
                }

                let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                totalUnread += countJSON[0].int!
                
                let app:AppDelegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!
                app.updateTabBadge(2, value: totalUnread == 0 ? nil : "")
            })
        })
    }
    
    func loadData() {
        PFCloud.callFunctionInBackground("getItemsByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!], block: {
            (items:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            self.itemsJSON = JSON(data:(items as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath) 
        let itemJSON = itemsJSON[indexPath.row]
        
        createImageQuery().getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            let imageView = cell.viewWithTag(101) as! UIImageView
            imageView.image = UIImage(data: imageData!)
        })
        
        let label = cell.viewWithTag(102) as! UILabel
        label.text = itemJSON["title"].string
        
        PFCloud.callFunctionInBackground("getReceivedCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            let offersCountLabel = cell.viewWithTag(103) as! UILabel
            offersCountLabel.text = "\(countJSON[0].int!)"
        })

        PFCloud.callFunctionInBackground("getExchangesCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            let offersCountLabel = cell.viewWithTag(104) as! UILabel
            offersCountLabel.text = "\(countJSON[0].int!)"
        })
        
        PFCloud.callFunctionInBackground("getQuestionsCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            let questionsCountLabel = cell.viewWithTag(105) as! UILabel
            questionsCountLabel.text = "\(countJSON[0].int!)"
        })
        
        updateUnread(itemJSON, cell: cell)
        return cell
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
                let itemJSON = self.itemsJSON[indexPath.row]
                PFCloud.callFunctionInBackground("deleteItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
                    (result:AnyObject?, error: NSError?) -> Void in
                    if let error = error {
                        NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                        return
                    }
                    PFCloud.callFunctionInBackground("deleteUnusedQuestions", withParameters: nil, block: {
                        (result:AnyObject?, error: NSError?) -> Void in
                        if let error = error {
                            NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                            return
                        }
                        self.loadData()
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
        //self.tabBarController?.tabBar.hidden = true

        if (segue.identifier == "detail") {
            let tableView = self.view as! UITableView
            let itemJSON = itemsJSON[(tableView.indexPathForSelectedRow?.row)!]
            
            let detail = segue.destinationViewController as! MyItemDetailController
            detail.title = itemJSON["title"].string!
            detail.itemJSON = itemJSON
        }
    }

}
