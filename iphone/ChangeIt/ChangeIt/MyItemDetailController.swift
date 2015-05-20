//
//  MyItemDetailController.swift
//  ChangeIt
//
//  Created by i818292 on 5/19/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class MyItemDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var questionsJSON:JSON = nil
    var offeredItemsJSON:JSON = nil
    var itemId:String = ""
    var itemImageId:String = ""
    
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var detailTable: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBAction func indexChanged(sender: AnyObject) {
        self.detailTable.reloadData()
    }
    
    @IBOutlet var testLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadData() {
        PFCloud.callFunctionInBackground("getQuestionedItemsByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId":itemId], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            self.questionsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.segmentedControl.setTitle(String(format:"Messages (%d)", self.questionsJSON.count), forSegmentAtIndex: 1)
        })
        
        PFCloud.callFunctionInBackground("getOfferedItemsByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId":itemId], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            if (results == nil) {
                self.offeredItemsJSON = JSON([])
                return
            }
            self.offeredItemsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.detailTable.reloadData()
            self.segmentedControl.setTitle(String(format:"Offers Received (%d)", self.offeredItemsJSON.count), forSegmentAtIndex: 0)
        })
        
        PFQuery(className:"Image").getObjectInBackgroundWithId(itemImageId, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.itemImageView.image = UIImage(data: imageData!)
        })

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (segmentedControl.selectedSegmentIndex == 0) {
            if (offeredItemsJSON == nil) {
                return 0
            }
            return offeredItemsJSON.count
        } else {
            if (questionsJSON == nil) {
                return 0
            }
            return questionsJSON.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myItemDetail", forIndexPath: indexPath) as! UITableViewCell
        
        if (segmentedControl.selectedSegmentIndex == 0) {
            let offeredItemJSON = offeredItemsJSON[indexPath.row]
            
            PFQuery(className:"Image").getObjectInBackgroundWithId(offeredItemJSON["item"]["photo"].string!, block: {
                (imageObj:PFObject?, error: NSError?) -> Void in
                let imageData = (imageObj!["file"] as! PFFile).getData()
                
                let photo = cell.viewWithTag(101) as! UIImageView
                photo.image = UIImage(data: imageData!)
            })
            
            let title = cell.viewWithTag(102) as! UILabel
            title.text = offeredItemJSON["item"]["title"].string

            let name = cell.viewWithTag(103) as! UILabel
            name.text = offeredItemJSON["user"]["name"].string

        } else {
            let questionJSON = questionsJSON[indexPath.row]
            
            let photo = cell.viewWithTag(101) as! UIImageView
            photo.image = nil
            
            let title = cell.viewWithTag(102) as! UILabel
            title.text = questionJSON["question"]["text"].string

            let name = cell.viewWithTag(103) as! UILabel
            name.text = questionJSON["user"]["name"].string
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let tableView = self.view as! UITableView
//        let itemJSON = offerJSON["dst"]
//        
//        // get user info based on item
//        let user = PFCloud.callFunction("getUserOfItem", withParameters: ["itemId":(itemJSON["objectId"].string)!])
//        let userJSON = JSON(data:(user as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//        
//        let detail = segue.destinationViewController as! OfferDetailController
//        detail.userJSON = userJSON[0]
//        detail.itemJSON = itemJSON
//        detail.otherItemJSON = offerJSON["src"]
    }

}
