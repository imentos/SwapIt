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
        let itemJSON = itemsJSON[indexPath.row]["src"]
        
        PFQuery(className:"Image").getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            let imageView = cell.viewWithTag(101) as! UIImageView
            imageView.image = UIImage(data: imageData!)
        })
        
        let label = cell.viewWithTag(102) as! UILabel
        label.text = itemJSON["title"].string
        
        let offersCountLabel = cell.viewWithTag(103) as! UILabel
        offersCountLabel.text = String(itemsJSON[indexPath.row]["count"].int!)

        PFCloud.callFunctionInBackground("getQuestionsCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            let questionsCountLabel = cell.viewWithTag(104) as! UILabel
            questionsCountLabel.text = String(countJSON[0].int!)
        })
        
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
            details.title = offerJSON["src"]["title"].string!
            details.itemId = offerJSON["src"]["objectId"].string!
            details.itemImageId = offerJSON["src"]["photo"].string!
            details.loadData()
        }
    }

}
