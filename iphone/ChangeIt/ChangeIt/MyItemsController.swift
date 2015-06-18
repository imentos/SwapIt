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
    
    @IBAction func cancelItem(segue:UIStoryboardSegue) {
    }
    
    func updateUnread(itemJSON:JSON, cell:UITableViewCell) {
        var unreadQuestions = 0
        var unreadOffers = 0
        PFCloud.callFunctionInBackground("getUnreadQuestionsCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            if (result == nil) {
                return;
            }
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            let newquestionsCountLabel = cell.viewWithTag(110) as! UILabel
            unreadQuestions = countJSON[0].int!
            if (unreadQuestions > 0) {
                newquestionsCountLabel.text = String(format: "(%d new)", countJSON[0].int!)
            } else {
                newquestionsCountLabel.text = "";
            }
            
            PFCloud.callFunctionInBackground("getUnreadExchangesCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
                (result:AnyObject?, error: NSError?) -> Void in
                if (result == nil) {
                    return;
                }
                let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                let newoffersCountLabel = cell.viewWithTag(111) as! UILabel
                unreadOffers = countJSON[0].int!
                if (unreadOffers > 0) {
                    newoffersCountLabel.text = String(format: "(%d new)", countJSON[0].int!)
                } else {
                    newoffersCountLabel.text = "";
                }
                
                if (unreadOffers + unreadQuestions > 0) {
                    cell.backgroundColor = UIColor(red:0.851, green:0.047, blue:0.314, alpha:0.2)
                } else {
                    cell.backgroundColor = UIColor.clearColor()
                }

            })
        })
    }
    
    @IBAction func back(segue:UIStoryboardSegue) {
        let indexPath = self.tableView.indexPathForSelectedRow()
        let cell = tableView.cellForRowAtIndexPath(indexPath!)
        let itemJSON = itemsJSON[indexPath!.row]
        updateUnread(itemJSON, cell: cell!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }

    func loadData() {
        PFCloud.callFunctionInBackground("getItemsWithOffersByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!], block: {
            (items:AnyObject?, error: NSError?) -> Void in
            self.itemsJSON = JSON(data:(items as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath) as! UITableViewCell
        let itemJSON = itemsJSON[indexPath.row]
        
        PFQuery(className:"Image").getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            let imageView = cell.viewWithTag(101) as! UIImageView
            imageView.image = UIImage(data: imageData!)
        })
        
        let label = cell.viewWithTag(102) as! UILabel
        label.text = itemJSON["title"].string
        
        PFCloud.callFunctionInBackground("getQuestionsCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            let questionsCountLabel = cell.viewWithTag(104) as! UILabel
            questionsCountLabel.text = String(countJSON[0].int!)
        })
        
        PFCloud.callFunctionInBackground("getExchangesCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            let offersCountLabel = cell.viewWithTag(103) as! UILabel
            offersCountLabel.text = String(countJSON[0].int!)
        })

        updateUnread(itemJSON, cell: cell)
        return cell
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (itemsJSON == nil) {
            return 0
        }
        return itemsJSON.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.destinationViewController is MyItemDetailController) {
            let tableView = self.view as! UITableView
            let offerJSON = itemsJSON[(tableView.indexPathForSelectedRow()?.row)!]
            
            let details = segue.destinationViewController as! MyItemDetailController
            details.title = offerJSON["title"].string!
            details.itemId = offerJSON["objectId"].string!
            details.itemImageId = offerJSON["photo"].string!
            details.loadData()
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
            
//            self.navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "Arrow_Icon"), style: .Plain, target: nil, action: nil)//: "123", style: .Plain, target: nil, action: nil)
        }
    }

}
